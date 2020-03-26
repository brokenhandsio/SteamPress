import Vapor
import Authentication

struct LoginController: RouteCollection {

    // MARK: - Properties
    private let pathCreator: BlogPathCreator

    // MARK: - Initialiser
    init(pathCreator: BlogPathCreator) {
        self.pathCreator = pathCreator
    }

    // MARK: - Route setup
    func boot(routes: RoutesBuilder) throws {
        routes.get("login", use: loginHandler)
        routes.post("login", use: loginPostHandler)

        let redirectMiddleware = BlogLoginRedirectAuthMiddleware(pathCreator: pathCreator)
        let protectedRoutes = routes.grouped(redirectMiddleware)
        protectedRoutes.post("logout", use: logoutHandler)
        protectedRoutes.get("resetPassword", use: resetPasswordHandler)
        protectedRoutes.post("resetPassword", use: resetPasswordPostHandler)
    }

    // MARK: - Route handlers
    func loginHandler(_ req: Request) throws -> EventLoopFuture<View> {
        let loginRequied = (try? req.query.get(Bool.self, at: "loginRequired")) != nil
        let presenter = try req.make(BlogPresenter.self)
        return try presenter.loginView(on: req, loginWarning: loginRequied, errors: nil, username: nil, usernameError: false, passwordError: false, rememberMe: false, pageInformation: req.pageInformation())
    }

    func loginPostHandler(_ req: Request) throws -> EventLoopFuture<Response> {
        let loginData = try req.content.decode(LoginData.self)
        var loginErrors = [String]()
        var usernameError = false
        var passwordError = false

        if loginData.username == nil {
            loginErrors.append("You must supply your username")
            usernameError = true
        }

        if loginData.password == nil {
            loginErrors.append("You must supply your password")
            passwordError = true
        }

        if !loginErrors.isEmpty {
            let presenter = try req.make(BlogPresenter.self)
            return try presenter.loginView(on: req, loginWarning: false, errors: loginErrors, username: loginData.username, usernameError: usernameError, passwordError: passwordError, rememberMe: loginData.rememberMe ?? false, pageInformation: req.pageInformation()).encode(for: req)
        }

        guard let username = loginData.username, let password = loginData.password else {
            throw Abort(.internalServerError)
        }

        if let rememberMe = loginData.rememberMe, rememberMe {
            try req.session()["SteamPressRememberMe"] = "YES"
        } else {
            try req.session()["SteamPressRememberMe"] = nil
        }

        let userRepository = try req.make(BlogUserRepository.self)
        return userRepository.getUser(username: username, on: req).flatMap { user in
            let verifier = try req.make(PasswordVerifier.self)
            guard let user = user, try verifier.verify(password, created: user.password) else {
                let loginError = ["Your username or password is incorrect"]
                let presenter = try req.make(BlogPresenter.self)
                return try presenter.loginView(on: req, loginWarning: false, errors: loginError, username: loginData.username, usernameError: false, passwordError: false, rememberMe: loginData.rememberMe ?? false, pageInformation: req.pageInformation()).encode(for: req)
            }
            try user.authenticateSession(on: req)
            return req.future(req.redirect(to: self.pathCreator.createPath(for: "admin")))
        }
    }

    func logoutHandler(_ request: Request) throws -> Response {
        try request.unauthenticateBlogUserSession()
        return request.redirect(to: pathCreator.createPath(for: pathCreator.blogPath))
    }

    func resetPasswordHandler(_ req: Request) throws -> EventLoopFuture<View> {
        let presenter = try req.make(BlogAdminPresenter.self)
        return try presenter.createResetPasswordView(on: req, errors: nil, passwordError: nil, confirmPasswordError: nil, pageInformation: req.adminPageInfomation())
    }

    func resetPasswordPostHandler(_ req: Request) throws -> EventLoopFuture<Response> {
        let data = try req.content.decode(ResetPasswordData.self)

        var resetPasswordErrors = [String]()
        var passwordError: Bool?
        var confirmPasswordError: Bool?

        guard let password = data.password, let confirmPassword = data.confirmPassword else {

            if data.password == nil {
                resetPasswordErrors.append("You must specify a password")
                passwordError = true
            }

            if data.confirmPassword == nil {
                resetPasswordErrors.append("You must confirm your password")
                confirmPasswordError = true
            }

            let presenter = try req.make(BlogAdminPresenter.self)
            let view = try presenter.createResetPasswordView(on: req, errors: resetPasswordErrors, passwordError: passwordError, confirmPasswordError: confirmPasswordError, pageInformation: req.adminPageInfomation())
            return try view.encode(for: req)
        }

        if password != confirmPassword {
            resetPasswordErrors.append("Your passwords must match!")
            passwordError = true
            confirmPasswordError = true
        }

        if password.count < 10 {
            passwordError = true
            resetPasswordErrors.append("Your password must be at least 10 characters long")
        }

        guard resetPasswordErrors.isEmpty else {
            let presenter = try req.make(BlogAdminPresenter.self)
            let view = try presenter.createResetPasswordView(on: req, errors: resetPasswordErrors, passwordError: passwordError, confirmPasswordError: confirmPasswordError, pageInformation: req.adminPageInfomation())
            return try view.encode(for: req)
        }

        let user = try req.requireAuthenticated(BlogUser.self)
        let hasher = try req.make(PasswordHasher.self)
        user.password = try hasher.hash(password)
        user.resetPasswordRequired = false
        let userRespository = try req.make(BlogUserRepository.self)
        let redirect = req.redirect(to: pathCreator.createPath(for: "admin"))
        return userRespository.save(user, on: req).transform(to: redirect)
    }
}
