import Vapor
import Authentication

struct UserAdminController: RouteCollection {

    // MARK: - Properties
    private let pathCreator: BlogPathCreator

    // MARK: - Initialiser
    init(pathCreator: BlogPathCreator) {
        self.pathCreator = pathCreator
    }

    // MARK: - Route setup
    func boot(router: Router) throws {
        router.get("createUser", use: createUserHandler)
        router.post("createUser", use: createUserPostHandler)
        router.get("users", BlogUser.parameter, "edit", use: editUserHandler)
        router.post("users", BlogUser.parameter, "edit", use: editUserPostHandler)
        router.post("users", BlogUser.parameter, "delete", use: deleteUserPostHandler)
    }

    // MARK: - Route handlers
    func createUserHandler(_ req: Request) throws -> EventLoopFuture<View> {
        let presenter = try req.make(BlogAdminPresenter.self)
        return try presenter.createUserView(on: req, editing: false, errors: nil, name: nil, nameError: false, username: nil, usernameErorr: false, passwordError: false, confirmPasswordError: false, resetPasswordOnLogin: false, userID: nil, profilePicture: nil, twitterHandle: nil, biography: nil, tagline: nil, pageInformation: req.adminPageInfomation())
    }

    func createUserPostHandler(_ req: Request) throws -> EventLoopFuture<Response> {
        let data = try req.content.syncDecode(CreateUserData.self)

        return try validateUserCreation(data, on: req).flatMap { createUserErrors in
            if let errors = createUserErrors {
                let presenter = try req.make(BlogAdminPresenter.self)
                let view = try presenter.createUserView(on: req, editing: false, errors: errors.errors, name: data.name, nameError: errors.nameError, username: data.username, usernameErorr: errors.usernameError, passwordError: errors.passwordError, confirmPasswordError: errors.confirmPasswordError, resetPasswordOnLogin: data.resetPasswordOnLogin ?? false, userID: nil, profilePicture: data.profilePicture, twitterHandle: data.twitterHandle, biography: data.biography, tagline: data.tagline, pageInformation: req.adminPageInfomation())
                return try view.encode(for: req)
            }

            guard let name = data.name, let username = data.username, let password = data.password else {
                throw Abort(.internalServerError)
            }

            let hasher = try req.make(PasswordHasher.self)
            let hashedPassword = try hasher.hash(password)
            #warning("Do the same for editing")
            let profilePicture = data.profilePicture.isEmptyOrWhitespace() ? nil : data.profilePicture
            let twitterHandle = data.twitterHandle.isEmptyOrWhitespace() ? nil : data.twitterHandle
            let biography = data.biography.isEmptyOrWhitespace() ? nil : data.biography
            let tagline = data.tagline.isEmptyOrWhitespace() ? nil : data.tagline
            let newUser = BlogUser(name: name, username: username.lowercased(), password: hashedPassword, profilePicture: profilePicture, twitterHandle: twitterHandle, biography: biography, tagline: tagline)
            if let resetPasswordRequired = data.resetPasswordOnLogin, resetPasswordRequired {
                newUser.resetPasswordRequired = true
            }
            let userRepository = try req.make(BlogUserRepository.self)
            return userRepository.save(newUser, on: req).map { _ in
                return req.redirect(to: self.pathCreator.createPath(for: "admin"))
            }

        }
    }

    func editUserHandler(_ req: Request) throws -> EventLoopFuture<View> {
        return try req.parameters.next(BlogUser.self).flatMap { user in
            let presenter = try req.make(BlogAdminPresenter.self)
            return try presenter.createUserView(on: req, editing: true, errors: nil, name: user.name, nameError: false, username: user.username, usernameErorr: false, passwordError: false, confirmPasswordError: false, resetPasswordOnLogin: user.resetPasswordRequired, userID: user.userID, profilePicture: user.profilePicture, twitterHandle: user.twitterHandle, biography: user.biography, tagline: user.tagline, pageInformation: req.adminPageInfomation())
        }
    }

    func editUserPostHandler(_ req: Request) throws -> EventLoopFuture<Response> {
        return try req.parameters.next(BlogUser.self).flatMap { user in
            let data = try req.content.syncDecode(CreateUserData.self)

            guard let name = data.name, let username = data.username else {
                throw Abort(.internalServerError)
            }

            return try self.validateUserCreation(data, editing: true, existingUsername: user.username, on: req).flatMap { errors in
                if let editUserErrors = errors {
                    let presenter = try req.make(BlogAdminPresenter.self)
                    let view = try presenter.createUserView(on: req, editing: true, errors: editUserErrors.errors, name: data.name, nameError: errors?.nameError ?? false, username: data.username, usernameErorr: errors?.usernameError ?? false, passwordError: editUserErrors.passwordError, confirmPasswordError: editUserErrors.confirmPasswordError, resetPasswordOnLogin: data.resetPasswordOnLogin ?? false, userID: user.userID, profilePicture: data.profilePicture, twitterHandle: data.twitterHandle, biography: data.biography, tagline: data.tagline, pageInformation: req.adminPageInfomation())
                    return try view.encode(for: req)
                }

                user.name = name
                user.username = username.lowercased()
                user.profilePicture = data.profilePicture
                user.twitterHandle = data.twitterHandle
                user.biography = data.biography
                user.tagline = data.tagline

                if let resetPasswordOnLogin = data.resetPasswordOnLogin, resetPasswordOnLogin {
                    user.resetPasswordRequired = true
                }

                if let password = data.password, password != "" {
                    let hasher = try req.make(PasswordHasher.self)
                    user.password = try hasher.hash(password)
                }

                let redirect = req.redirect(to: self.pathCreator.createPath(for: "admin"))
                let userRepository = try req.make(BlogUserRepository.self)
                return userRepository.save(user, on: req).transform(to: redirect)
            }
        }
    }

    func deleteUserPostHandler(_ req: Request) throws -> EventLoopFuture<Response> {
        let userRepository = try req.make(BlogUserRepository.self)
        return try flatMap(req.parameters.next(BlogUser.self), userRepository.getUsersCount(on: req)) { user, userCount in
            guard userCount > 1 else {
                let postRepository = try req.make(BlogPostRepository.self)
                return flatMap(postRepository.getAllPostsSortedByPublishDate(includeDrafts: true, on: req), userRepository.getAllUsers(on: req)) { posts, users in
                    let presenter = try req.make(BlogAdminPresenter.self)
                    let view = try presenter.createIndexView(on: req, posts: posts, users: users, errors: ["You cannot delete the last user"], pageInformation: req.adminPageInfomation())
                    return try view.encode(for: req)
                }
            }

            let loggedInUser = try req.requireAuthenticated(BlogUser.self)
            guard loggedInUser.userID != user.userID else {
                let postRepository = try req.make(BlogPostRepository.self)
                return flatMap(postRepository.getAllPostsSortedByPublishDate(includeDrafts: true, on: req), userRepository.getAllUsers(on: req)) { posts, users in
                    let presenter = try req.make(BlogAdminPresenter.self)
                    let view = try presenter.createIndexView(on: req, posts: posts, users: users, errors: ["You cannot delete yourself whilst logged in"], pageInformation: req.adminPageInfomation())
                    return try view.encode(for: req)
                }
            }

            let redirect = req.redirect(to: self.pathCreator.createPath(for: "admin"))
            return userRepository.delete(user, on: req).transform(to: redirect)
        }
    }

    // MARK: - Validators
    private func validateUserCreation(_ data: CreateUserData, editing: Bool = false, existingUsername: String? = nil, on req: Request) throws -> EventLoopFuture<CreateUserErrors?> {
        var createUserErrors = [String]()
        var passwordError = false
        var confirmPasswordError = false
        var nameErorr = false
        var usernameError = false

        if data.name.isEmptyOrWhitespace() {
            createUserErrors.append("You must specify a name")
            nameErorr = true
        }

        if data.username.isEmptyOrWhitespace() {
            createUserErrors.append("You must specify a username")
            usernameError = true
        }

        if !editing || !data.password.isEmptyOrWhitespace() {
            if data.password.isEmptyOrWhitespace() {
                createUserErrors.append("You must specify a password")
                passwordError = true
            }

            if data.confirmPassword.isEmptyOrWhitespace() {
                createUserErrors.append("You must confirm your password")
                confirmPasswordError = true
            }
        }

        if let password = data.password, password != "" {
            if password.count < 10 {
                createUserErrors.append("Your password must be at least 10 characters long")
                passwordError = true
            }

            if data.password != data.confirmPassword {
                createUserErrors.append("Your passwords must match")
                passwordError = true
                confirmPasswordError = true
            }
        }

        do {
            try data.validate()
        } catch {
            createUserErrors.append("The username provided is not valid")
            usernameError = true
        }

        var usernameUniqueError: EventLoopFuture<String?>
        let usersRepository = try req.make(BlogUserRepository.self)
        if let username = data.username {
            if editing && data.username == existingUsername {
                usernameUniqueError = req.future(nil)
            } else {
                usernameUniqueError = usersRepository.getUser(username: username.lowercased(), on: req).map { user in
                    if user != nil {
                        return "Sorry that username has already been taken"
                    } else {
                        return nil
                    }
                }
            }
        } else {
            usernameUniqueError = req.future(nil)
        }

        return usernameUniqueError.map { usernameErrorOccurred in
            if let uniqueError = usernameErrorOccurred {
                createUserErrors.append(uniqueError)
                usernameError = true
            }
            if createUserErrors.count == 0 {
                return nil
            }

            let errors = CreateUserErrors(errors: createUserErrors, passwordError: passwordError, confirmPasswordError: confirmPasswordError, nameError: nameErorr, usernameError: usernameError)

            return errors

        }
    }
}
