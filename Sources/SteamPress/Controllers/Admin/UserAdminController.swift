import Vapor

struct UserAdminController: RouteCollection {

    // MARK: - Properties
    private let pathCreator: BlogPathCreator

    // MARK: - Initialiser
    init(pathCreator: BlogPathCreator) {
        self.pathCreator = pathCreator
    }

    // MARK: - Route setup
    func boot(routes: RoutesBuilder) throws {
        routes.get("createUser", use: createUserHandler)
        routes.post("createUser", use: createUserPostHandler)
        routes.get("users", BlogUser.parameter, "edit", use: editUserHandler)
        routes.post("users", BlogUser.parameter, "edit", use: editUserPostHandler)
        routes.post("users", BlogUser.parameter, "delete", use: deleteUserPostHandler)
    }

    // MARK: - Route handlers
    func createUserHandler(_ req: Request) throws -> EventLoopFuture<View> {
        return try req.adminPresenter.createUserView(editing: false, errors: nil, name: nil, nameError: false, username: nil, usernameErorr: false, passwordError: false, confirmPasswordError: false, resetPasswordOnLogin: false, userID: nil, profilePicture: nil, twitterHandle: nil, biography: nil, tagline: nil, pageInformation: req.adminPageInfomation())
    }

    func createUserPostHandler(_ req: Request) throws -> EventLoopFuture<Response> {
        let data = try req.content.decode(CreateUserData.self)

        return try validateUserCreation(data, on: req).flatMap { createUserErrors in
            if let errors = createUserErrors {
                let view = try req.adminPresenter.createUserView(editing: false, errors: errors.errors, name: data.name, nameError: errors.nameError, username: data.username, usernameErorr: errors.usernameError, passwordError: errors.passwordError, confirmPasswordError: errors.confirmPasswordError, resetPasswordOnLogin: data.resetPasswordOnLogin ?? false, userID: nil, profilePicture: data.profilePicture, twitterHandle: data.twitterHandle, biography: data.biography, tagline: data.tagline, pageInformation: req.adminPageInfomation())
                return view.encodeResponse(for: req)
            }

            guard let name = data.name, let username = data.username, let password = data.password else {
                throw Abort(.internalServerError)
            }

            let hasher = try req.make(PasswordHasher.self)
            let hashedPassword = try hasher.hash(password)
            let profilePicture = data.profilePicture.isEmptyOrWhitespace() ? nil : data.profilePicture
            let twitterHandle = data.twitterHandle.isEmptyOrWhitespace() ? nil : data.twitterHandle
            let biography = data.biography.isEmptyOrWhitespace() ? nil : data.biography
            let tagline = data.tagline.isEmptyOrWhitespace() ? nil : data.tagline
            let newUser = BlogUser(name: name, username: username.lowercased(), password: hashedPassword, profilePicture: profilePicture, twitterHandle: twitterHandle, biography: biography, tagline: tagline)
            if let resetPasswordRequired = data.resetPasswordOnLogin, resetPasswordRequired {
                newUser.resetPasswordRequired = true
            }
            return req.blogUserRepository.save(newUser, on: req).map { _ in
                return req.redirect(to: self.pathCreator.createPath(for: "admin"))
            }

        }
    }

    func editUserHandler(_ req: Request) throws -> EventLoopFuture<View> {
        req.parameters.findUser(on: req).flatMap { user in
            do {
                return try req.adminPresenter.createUserView(editing: true, errors: nil, name: user.name, nameError: false, username: user.username, usernameErorr: false, passwordError: false, confirmPasswordError: false, resetPasswordOnLogin: user.resetPasswordRequired, userID: user.userID, profilePicture: user.profilePicture, twitterHandle: user.twitterHandle, biography: user.biography, tagline: user.tagline, pageInformation: req.adminPageInfomation())
            } catch {
                return req.eventLoop.makeFailedFuture(error)
            }
        }
    }

    func editUserPostHandler(_ req: Request) throws -> EventLoopFuture<Response> {
        req.parameters.findUser(on: req).flatMap { user in
            let data = try req.content.decode(CreateUserData.self)

            guard let name = data.name, let username = data.username else {
                throw Abort(.internalServerError)
            }

            return try self.validateUserCreation(data, editing: true, existingUsername: user.username, on: req).flatMap { errors in
                if let editUserErrors = errors {
                    let view = try req.adminPresenter.createUserView(editing: true, errors: editUserErrors.errors, name: data.name, nameError: errors?.nameError ?? false, username: data.username, usernameErorr: errors?.usernameError ?? false, passwordError: editUserErrors.passwordError, confirmPasswordError: editUserErrors.confirmPasswordError, resetPasswordOnLogin: data.resetPasswordOnLogin ?? false, userID: user.userID, profilePicture: data.profilePicture, twitterHandle: data.twitterHandle, biography: data.biography, tagline: data.tagline, pageInformation: req.adminPageInfomation())
                    return view.encodeResponse(for: req)
                }

                user.name = name
                user.username = username.lowercased()
                
                let profilePicture = data.profilePicture.isEmptyOrWhitespace() ? nil : data.profilePicture
                let twitterHandle = data.twitterHandle.isEmptyOrWhitespace() ? nil : data.twitterHandle
                let biography = data.biography.isEmptyOrWhitespace() ? nil : data.biography
                let tagline = data.tagline.isEmptyOrWhitespace() ? nil : data.tagline
                
                user.profilePicture = profilePicture
                user.twitterHandle = twitterHandle
                user.biography = biography
                user.tagline = tagline

                if let resetPasswordOnLogin = data.resetPasswordOnLogin, resetPasswordOnLogin {
                    user.resetPasswordRequired = true
                }

                if let password = data.password, password != "" {
                    let hasher = try req.make(PasswordHasher.self)
                    user.password = try hasher.hash(password)
                }

                let redirect = req.redirect(to: self.pathCreator.createPath(for: "admin"))
                return req.blogUserRepository.save(user).transform(to: redirect)
            }
        }
    }

    func deleteUserPostHandler(_ req: Request) throws -> EventLoopFuture<Response> {
        req.parameters.findUser(on: req).and(req.blogUserRepository.getUsersCount()).flatMap { user, userCount in
            guard userCount > 1 else {
                return req.blogPostRepository.getAllPostsSortedByPublishDate(includeDrafts: true).and(req.blogUserRepository.getAllUsers()).flatMap { posts, users in
                    do {
                        let view = try req.adminPresenter.createIndexView(posts: posts, users: users, errors: ["You cannot delete the last user"], pageInformation: req.adminPageInfomation())
                        return view.encodeResponse(for: req)
                    } catch {
                        return req.eventLoop.makeFailedFuture(error)
                    }
                }
            }

            let loggedInUser: BlogUser
            do {
                loggedInUser = try req.auth.require(BlogUser.self)
            } catch {
                return req.eventLoop.makeFailedFuture(error)
            }
            guard loggedInUser.userID != user.userID else {
                return req.blogPostRepository.getAllPostsSortedByPublishDate(includeDrafts: true).and(req.blogUserRepository.getAllUsers()).flatMap { posts, users in
                    do {
                        let view = try req.adminPresenter.createIndexView(posts: posts, users: users, errors: ["You cannot delete yourself whilst logged in"], pageInformation: req.adminPageInfomation())
                        return view.encodeResponse(for: req)
                    } catch {
                        return req.eventLoop.makeFailedFuture(error)
                    }
                }
            }

            let redirect = req.redirect(to: self.pathCreator.createPath(for: "admin"))
            return req.blogUserRepository.delete(user).transform(to: redirect)
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
        if let username = data.username {
            if editing && data.username == existingUsername {
                usernameUniqueError = req.eventLoop.future(nil)
            } else {
                usernameUniqueError = req.blogUserRepository.getUser(username: username.lowercased()).map { user in
                    if user != nil {
                        return "Sorry that username has already been taken"
                    } else {
                        return nil
                    }
                }
            }
        } else {
            usernameUniqueError = req.eventLoop.future(nil)
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
