import Vapor
import HTTP
import Routing
import MarkdownProvider

struct BlogAuthorsController {

    fileprivate let drop: Droplet
    fileprivate let pathCreator: BlogPathCreator
    fileprivate let viewFactory: ViewFactory

    fileprivate let authorsPath = "authors"
    fileprivate let enableAuthorsPages: Bool

    // MARK: - Initialiser
    init(drop: Droplet, pathCreator: BlogPathCreator, viewFactory: ViewFactory, enableAuthorsPages: Bool) {
        self.drop = drop
        self.pathCreator = pathCreator
        self.viewFactory = viewFactory
        self.enableAuthorsPages = enableAuthorsPages
    }

    // MARK: - Add routes
    func addRoutes() {
        drop.group(pathCreator.blogPath ?? "") { index in

            if enableAuthorsPages {
                index.get(authorsPath, String.parameter, handler: authorViewHandler)
                index.get(authorsPath, handler: allAuthorsViewHandler)
            }
        }

        self.addAdminRoutes()
    }

    private func addAdminRoutes() {
        let router = drop.grouped(pathCreator.blogPath ?? "", "admin")
        let protect = BlogLoginRedirectAuthMiddleware(pathCreator: pathCreator)
        let routerSecure = router.grouped(protect)

        routerSecure.get("createUser", handler: createUserHandler)
        routerSecure.post("createUser", handler: createUserPostHandler)
        routerSecure.get("users", BlogUser.parameter, "edit", handler: editUserHandler)
        routerSecure.post("users", BlogUser.parameter, "edit", handler: editUserPostHandler)
        routerSecure.get("users", BlogUser.parameter, "delete", handler: deleteUserPostHandler)
    }

    func authorViewHandler(request: Request) throws -> ResponseRepresentable {
        let authorUsername: String = try request.parameters.next()

        guard let author = try BlogUser.makeQuery().filter(BlogUser.Properties.username, authorUsername).first() else {
            throw Abort.notFound
        }

        let posts = try author.sortedPosts().paginate(for: request)

        return try viewFactory.profileView(uri: request.getURIWithHTTPSIfReverseProxy(), author: author, paginatedPosts: posts, loggedInUser: try? request.user())
    }

    func allAuthorsViewHandler(request: Request) throws -> ResponseRepresentable {
        return try viewFactory.allAuthorsView(uri: request.getURIWithHTTPSIfReverseProxy(), allAuthors: BlogUser.all(), user: try? request.user())
    }

    func createUserHandler(_ request: Request) throws -> ResponseRepresentable {
        return try viewFactory.createUserView(editing: false, errors: nil, name: nil, username: nil, passwordError: nil, confirmPasswordError: nil, resetPasswordRequired: nil, userId: nil, profilePicture: nil, twitterHandle: nil, biography: nil, tagline: nil, loggedInUser: request.user())
    }

    func createUserPostHandler(_ request: Request) throws -> ResponseRepresentable {

        let rawName = request.data["inputName"]?.string
        let rawUsername = request.data["inputUsername"]?.string
        let rawPassword = request.data["inputPassword"]?.string
        let rawConfirmPassword = request.data["inputConfirmPassword"]?.string
        let rawPasswordResetRequired = request.data["inputResetPasswordOnLogin"]?.string
        let resetPasswordRequired = rawPasswordResetRequired != nil
        let profilePicture = request.data["inputProfilePicture"]?.string
        let tagline = request.data["inputTagline"]?.string
        let biography = request.data["inputBiography"]?.string
        let twitterHandle = request.data["inputTwitterHandle"]?.string

        let (createUserRawErrors, passwordRawError, confirmPasswordRawError) = validateUserSaveDataExists(edit: false, name: rawName, username: rawUsername, password: rawPassword, confirmPassword: rawConfirmPassword, profilePicture: profilePicture)

        // Return if we have any missing fields
        if !(createUserRawErrors?.isEmpty ?? true) {
            return try viewFactory.createUserView(editing: false, errors: createUserRawErrors, name: rawName, username: rawUsername, passwordError: passwordRawError, confirmPasswordError: confirmPasswordRawError, resetPasswordRequired: resetPasswordRequired, userId: nil, profilePicture: profilePicture, twitterHandle: twitterHandle, biography: biography, tagline: tagline, loggedInUser: request.user())
        }

        guard let name = rawName, let username = rawUsername?.lowercased(), let password = rawPassword, let confirmPassword = rawConfirmPassword else {
            throw Abort.badRequest
        }

        let (createUserErrors, passwordError, confirmPasswordError) = validateUserSaveData(edit: false, name: name, username: username, password: password, confirmPassword: confirmPassword)

        if !(createUserErrors?.isEmpty ?? true) {
            return try viewFactory.createUserView(editing: false, errors: createUserErrors, name: name, username: username, passwordError: passwordError, confirmPasswordError: confirmPasswordError, resetPasswordRequired: resetPasswordRequired, userId: nil, profilePicture: profilePicture, twitterHandle: twitterHandle, biography: biography, tagline: tagline, loggedInUser: request.user())
        }

        // We now have valid data
        let hashedPassword = try BlogUser.passwordHasher.make(password)
        let newUser = BlogUser(name: name, username: username.lowercased(), password: hashedPassword, profilePicture: profilePicture, twitterHandle: twitterHandle, biography: biography, tagline: tagline)

        if resetPasswordRequired {
            newUser.resetPasswordRequired = true
        }

        do {
            try newUser.save()
        } catch {
            return try viewFactory.createUserView(editing: false, errors: ["There was an error creating the user. Please try again"], name: name, username: username, passwordError: passwordError, confirmPasswordError: confirmPasswordError, resetPasswordRequired: resetPasswordRequired, userId: nil, profilePicture: profilePicture, twitterHandle: twitterHandle, biography: biography, tagline: tagline, loggedInUser: request.user())
        }

        return Response(redirect: pathCreator.createPath(for: "admin"))

    }

    func editUserHandler(request: Request) throws -> ResponseRepresentable {
        let user = try request.parameters.next(BlogUser.self)
        return try viewFactory.createUserView(editing: true, errors: nil, name: user.name, username: user.username, passwordError: nil, confirmPasswordError: nil, resetPasswordRequired: nil, userId: user.id, profilePicture: user.profilePicture, twitterHandle: user.twitterHandle, biography: user.biography, tagline: user.tagline, loggedInUser: request.user())
    }

    func editUserPostHandler(request: Request) throws -> ResponseRepresentable {
        let user = try request.parameters.next(BlogUser.self)
        let rawName = request.data["inputName"]?.string
        let rawUsername = request.data["inputUsername"]?.string
        let rawPassword = request.data["inputPassword"]?.string
        let rawConfirmPassword = request.data["inputConfirmPassword"]?.string
        let rawPasswordResetRequired = request.data["inputResetPasswordOnLogin"]?.string
        let resetPasswordRequired = rawPasswordResetRequired != nil
        let profilePicture = request.data["inputProfilePicture"]?.string
        let tagline = request.data["inputTagline"]?.string
        let biography = request.data["inputBiography"]?.string
        let twitterHandle = request.data["inputTwitterHandle"]?.string

        let (saveUserRawErrors, passwordRawError, confirmPasswordRawError) = validateUserSaveDataExists(edit: true, name: rawName, username: rawUsername, password: rawPassword, confirmPassword: rawConfirmPassword, profilePicture: profilePicture)

        // Return if we have any missing fields
        if !(saveUserRawErrors?.isEmpty ?? true) {
            return try viewFactory.createUserView(editing: true, errors: saveUserRawErrors, name: rawName, username: rawUsername, passwordError: passwordRawError, confirmPasswordError: confirmPasswordRawError, resetPasswordRequired: resetPasswordRequired, userId: user.id, profilePicture: profilePicture, twitterHandle: twitterHandle, biography: biography, tagline: tagline, loggedInUser: request.user())
        }

        guard let name = rawName, let username = rawUsername else {
            throw Abort.badRequest
        }

        let (saveUserErrors, passwordError, confirmPasswordError) = validateUserSaveData(edit: true, name: name, username: username, password: rawPassword, confirmPassword: rawConfirmPassword, previousUsername: user.username)

        if !(saveUserErrors?.isEmpty ?? true) {
            return try viewFactory.createUserView(editing: true, errors: saveUserErrors, name: name, username: username, passwordError: passwordError, confirmPasswordError: confirmPasswordError, resetPasswordRequired: resetPasswordRequired, userId: user.id, profilePicture: profilePicture, twitterHandle: twitterHandle, biography: biography, tagline: tagline, loggedInUser: request.user())
        }

        // We now have valid data
        guard let userId = user.id, let userToUpdate = try BlogUser.find(userId) else {
            throw Abort.badRequest
        }
        userToUpdate.name = name
        userToUpdate.username = username
        userToUpdate.profilePicture = profilePicture
        userToUpdate.twitterHandle = twitterHandle
        userToUpdate.biography = biography
        userToUpdate.tagline = tagline

        if resetPasswordRequired {
            userToUpdate.resetPasswordRequired = true
        }

        if let password = rawPassword {
            userToUpdate.password = try BlogUser.passwordHasher.make(password)
        }

        try userToUpdate.save()
        return Response(redirect: pathCreator.createPath(for: "admin"))
    }

    func deleteUserPostHandler(request: Request) throws -> ResponseRepresentable {
        let user = try request.parameters.next(BlogUser.self)
        // Check we have at least one user left
        let users = try BlogUser.all()
        if users.count <= 1 {
            return try viewFactory.createBlogAdminView(errors: ["You cannot delete the last user"], user: try request.user())
        }
            // Make sure we aren't deleting ourselves!
        else if try request.user().id == user.id {
            return try viewFactory.createBlogAdminView(errors: ["You cannot delete yourself whilst logged in"], user: try request.user())
        } else {
            try user.delete()
            return Response(redirect: pathCreator.createPath(for: "admin"))
        }
    }

    private func validateUserSaveDataExists(edit: Bool, name: String?, username: String?, password: String?, confirmPassword: String?, profilePicture: String?) -> ([String]?, Bool?, Bool?) {
        var userSaveErrors: [String] = []
        var passwordError: Bool?
        var confirmPasswordError: Bool?

        if name == nil || (name?.isWhitespace() ?? false) {
            userSaveErrors.append("You must specify a name")
        }

        if username == nil || (username?.isWhitespace() ?? false) {
            userSaveErrors.append("You must specify a username")
        }

        if !edit {
            if password == nil {
                userSaveErrors.append("You must specify a password")
                passwordError = true
            }

            if confirmPassword == nil {
                userSaveErrors.append("You must confirm your password")
                confirmPasswordError = true
            }
        }

        return (userSaveErrors, passwordError, confirmPasswordError)
    }

    private func validateUserSaveData(edit: Bool, name: String, username: String, password: String?, confirmPassword: String?, previousUsername: String? = nil) -> ([String]?, Bool?, Bool?) {

        var userSaveErrors: [String] = []
        var passwordError: Bool?
        var confirmPasswordError: Bool?

        if password != confirmPassword {
            userSaveErrors.append("Your passwords must match!")
            passwordError = true
            confirmPasswordError = true
        }

        // Check name is valid
        let validName = name.passes(NameValidator())
        if !validName {
            userSaveErrors.append("The name provided is not valid")
        }

        // Check username is valid
        let validUsername = username.passes(UsernameValidator())
        if !validUsername {
            userSaveErrors.append("The username provided is not valid")
        }

        // Check password is valid
        if !edit || password != nil {
            guard let actualPassword = password else {
                fatalError()
            }
            let validPassword = actualPassword.passes(PasswordValidator())
            if !validPassword {
                userSaveErrors.append("Your password must contain a lowercase letter, an upperacase letter, a number and a symbol")
                passwordError = true
            }
        }

        // Check username unique
        do {
            if username != previousUsername {
                let usernames = try BlogUser.all().map { $0.username.lowercased() }
                if usernames.contains(username.lowercased()) {
                    userSaveErrors.append("Sorry that username has already been taken")
                }
            }
        } catch {
            userSaveErrors.append("Unable to validate username")
        }

        return (userSaveErrors, passwordError, confirmPasswordError)
    }
}
