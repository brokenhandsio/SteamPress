import Vapor
import HTTP
import Routing
import AuthProvider
import Foundation
import Fluent
import Validation
import Cookies

struct BlogController {

    // MARK: - Properties
    fileprivate let searchPath = "search"
    fileprivate let drop: Droplet
    fileprivate let pathCreator: BlogPathCreator
    fileprivate let viewFactory: BlogLeafViewFactory
    fileprivate let log: LogProtocol

    // MARK: - Initialiser
    init(drop: Droplet, pathCreator: BlogPathCreator, viewFactory: BlogLeafViewFactory) {
        self.drop = drop
        self.pathCreator = pathCreator
        self.viewFactory = viewFactory
        self.log = drop.log
    }

    // MARK: - Add routes
    func addRoutes() {
        drop.group(pathCreator.blogPath ?? "") { index in
            index.get(handler: indexHandler)
            index.get(searchPath, handler: searchHandler)
        }

        self.addAdminRoutes()
    }

    private func addAdminRoutes() {
        let router = drop.grouped(pathCreator.blogPath ?? "", "admin")

        router.get("login", handler: loginHandler)
        router.post("login", handler: loginPostHandler)
        router.get("logout", handler: logoutHandler)

        let protect = BlogLoginRedirectAuthMiddleware(pathCreator: pathCreator)
        let routerSecure = router.grouped(protect)
        routerSecure.get(handler: adminHandler)

        routerSecure.get("resetPassword", handler: resetPasswordHandler)
        routerSecure.post("resetPassword", handler: resetPasswordPostHandler)
    }

    // MARK: - Route Handlers
    func indexHandler(request: Request) throws -> ResponseRepresentable {
        let tags = try BlogTag.all()
        let links = try BlogLink.all()
        let authors = try BlogUser.all()
        let paginatedBlogPosts = try BlogPost.makeQuery().filter(BlogPost.Properties.published, true).sort(BlogPost.Properties.created, .descending).paginate(for: request)

        return try viewFactory.blogIndexView(uri: request.getURIWithHTTPSIfReverseProxy(), paginatedPosts: paginatedBlogPosts, tags: tags, links: links, authors: authors, loggedInUser: try? request.user())
    }
    
    func searchHandler(request: Request) throws -> ResponseRepresentable {
        guard let searchTerm = request.query?["term"]?.string, searchTerm != "" else {
            return try viewFactory.searchView(uri: request.getURIWithHTTPSIfReverseProxy(), searchTerm: nil, foundPosts: nil, emptySearch: true, user: try? request.user())
        }
        
        let posts = try BlogPost.makeQuery().filter(BlogPost.Properties.published, true).or { orGroup in
            try orGroup.filter(BlogPost.Properties.title, .contains, searchTerm)
            try orGroup.filter(BlogPost.Properties.contents, .contains, searchTerm)
        }
        .sort(BlogPost.Properties.created, .descending).paginate(for: request)
        
        return try viewFactory.searchView(uri: request.uri, searchTerm: searchTerm, foundPosts: posts, emptySearch: false, user: try? request.user())
    }

    // MARK: - Login Handlers
    func loginHandler(_ request: Request) throws -> ResponseRepresentable {
        let loginRequired = request.uri.query == "loginRequired"
        return try viewFactory.createLoginView(loginWarning: loginRequired, errors: nil, username: nil, password: nil)
    }

    func loginPostHandler(_ request: Request) throws -> ResponseRepresentable {
        let rawUsername = request.data["inputUsername"]?.string
        let rawPassword = request.data["inputPassword"]?.string
        let rememberMe = request.data["remember-me"]?.string != nil

        var loginErrors: [String] = []

        if rawUsername == nil {
            loginErrors.append("You must supply your username")
        }

        if rawPassword == nil {
            loginErrors.append("You must supply your password")
        }

        if !loginErrors.isEmpty {
            return try viewFactory.createLoginView(loginWarning: false, errors: loginErrors, username: rawUsername, password: rawPassword)
        }

        guard let username = rawUsername, let password = rawPassword else {
            throw Abort.badRequest
        }

        let passwordCredentials = Password(username: username.lowercased(), password: password)

        if rememberMe {
            request.storage["remember_me"] = true
        } else {
            request.storage.removeValue(forKey: "remember_me")
        }

        do {
            let user = try BlogUser.authenticate(passwordCredentials)
            request.auth.authenticate(user)
            return Response(redirect: pathCreator.createPath(for: "admin"))
        } catch {
            log.debug("Got error logging in \(error)")
            let loginError = ["Your username or password was incorrect"]
            return try viewFactory.createLoginView(loginWarning: false, errors: loginError, username: username, password: "")
        }
    }

    func logoutHandler(_ request: Request) throws -> ResponseRepresentable {
        try request.auth.unauthenticate()
        return Response(redirect: pathCreator.createPath(for: pathCreator.blogPath))
    }

    // MARK: - Admin Handler
    func adminHandler(_ request: Request) throws -> ResponseRepresentable {
        return try viewFactory.createBlogAdminView(errors: nil, user: try request.user())
    }

    // MARK: - Password handlers
    func resetPasswordHandler(_ request: Request) throws -> ResponseRepresentable {
        return try viewFactory.createResetPasswordView(errors: nil, passwordError: nil, confirmPasswordError: nil, user: request.user())
    }

    func resetPasswordPostHandler(_ request: Request) throws -> ResponseRepresentable {
        let rawPassword = request.data["inputPassword"]?.string
        let rawConfirmPassword = request.data["inputConfirmPassword"]?.string
        var resetPasswordErrors: [String] = []
        var passwordError: Bool?
        var confirmPasswordError: Bool?

        guard let password = rawPassword, let confirmPassword = rawConfirmPassword else {
            if rawPassword == nil {
                resetPasswordErrors.append("You must specify a password")
                passwordError = true
            }

            if rawConfirmPassword == nil {
                resetPasswordErrors.append("You must confirm your password")
                confirmPasswordError = true
            }

            // Return if we have any missing fields
            return try viewFactory.createResetPasswordView(errors: resetPasswordErrors, passwordError: passwordError, confirmPasswordError: confirmPasswordError, user: request.user())
        }

        if password != confirmPassword {
            resetPasswordErrors.append("Your passwords must match!")
            passwordError = true
            confirmPasswordError = true
        }

        // Check password is valid
        let validPassword = password.passes(PasswordValidator())
        if !validPassword {
            resetPasswordErrors.append("Your password must contain a lowercase letter, an upperacase letter, a number and a symbol")
            passwordError = true
        }

        if !resetPasswordErrors.isEmpty {
            return try viewFactory.createResetPasswordView(errors: resetPasswordErrors, passwordError: passwordError, confirmPasswordError: confirmPasswordError, user: request.user())
        }

        let user = try request.user()

        user.password = try BlogUser.passwordHasher.make(password)
        user.resetPasswordRequired = false
        try user.save()

        return Response(redirect: pathCreator.createPath(for: "admin"))
    }
}

