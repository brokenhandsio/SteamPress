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
    func boot(router: Router) throws {
        router.post("login", use: loginPostHandler)
        router.post("logout", use: logoutHandler)
    }
    
    // MARK: - Route handlers
    //    func loginHandler(_ request: Request) throws -> ResponseRepresentable {
    //        let loginRequired = request.uri.query == "loginRequired"
    //        return try viewFactory.createLoginView(loginWarning: loginRequired, errors: nil, username: nil, password: nil)
    //    }
    //
    func loginPostHandler(_ req: Request) throws -> Future<Response> {
        let loginData = try req.content.syncDecode(LoginData.self)
        var loginErrors = [String]()

        if loginData.username == nil {
            loginErrors.append("You must supply your username")
        }

        if loginData.password == nil {
            loginErrors.append("You must supply your password")
        }

        if !loginErrors.isEmpty {
            throw Abort(.badRequest)
            #warning("Implement")
//            return try viewFactory.createLoginView(loginWarning: false, errors: loginErrors, username: rawUsername, password: rawPassword)
        }

        guard let username = loginData.username, let password = loginData.password else {
            throw Abort(.internalServerError)
        }

//        if rememberMe {
//            request.storage["remember_me"] = true
//        } else {
//            request.storage.removeValue(forKey: "remember_me")
//        }
        
        let userRepository = try req.make(BlogUserRepository.self)
        return userRepository.getUser(username: username, on: req).map { user in
            let verifier = try req.make(PasswordVerifier.self)
            guard let user = user, try verifier.verify(password, created: user.password) else {
                #warning("TODO")
//                let loginError = ["Your username or password was incorrect"]
//                return try viewFactory.createLoginView(loginWarning: false, errors: loginError, username: username, password: "")
                throw Abort(.badRequest)
            }
            try user.authenticateSession(on: req)
            return req.redirect(to: self.pathCreator.createPath(for: "admin"))
        }
    }

    func logoutHandler(_ request: Request) throws -> Response {
        try request.unauthenticateBlogUserSession()
        return request.redirect(to: pathCreator.createPath(for: pathCreator.blogPath))
    }
    
    //    func resetPasswordHandler(_ request: Request) throws -> ResponseRepresentable {
    //        return try viewFactory.createResetPasswordView(errors: nil, passwordError: nil, confirmPasswordError: nil, user: request.user())
    //    }
    //
    //    func resetPasswordPostHandler(_ request: Request) throws -> ResponseRepresentable {
    //        let rawPassword = request.data["inputPassword"]?.string
    //        let rawConfirmPassword = request.data["inputConfirmPassword"]?.string
    //        var resetPasswordErrors: [String] = []
    //        var passwordError: Bool?
    //        var confirmPasswordError: Bool?
    //
    //        guard let password = rawPassword, let confirmPassword = rawConfirmPassword else {
    //            if rawPassword == nil {
    //                resetPasswordErrors.append("You must specify a password")
    //                passwordError = true
    //            }
    //
    //            if rawConfirmPassword == nil {
    //                resetPasswordErrors.append("You must confirm your password")
    //                confirmPasswordError = true
    //            }
    //
    //            // Return if we have any missing fields
    //            return try viewFactory.createResetPasswordView(errors: resetPasswordErrors, passwordError: passwordError, confirmPasswordError: confirmPasswordError, user: request.user())
    //        }
    //
    //        if password != confirmPassword {
    //            resetPasswordErrors.append("Your passwords must match!")
    //            passwordError = true
    //            confirmPasswordError = true
    //        }
    //
    //        // Check password is valid
    //        let validPassword = password.passes(PasswordValidator())
    //        if !validPassword {
    //            resetPasswordErrors.append("Your password must contain a lowercase letter, an upperacase letter, a number and a symbol")
    //            passwordError = true
    //        }
    //
    //        if !resetPasswordErrors.isEmpty {
    //            return try viewFactory.createResetPasswordView(errors: resetPasswordErrors, passwordError: passwordError, confirmPasswordError: confirmPasswordError, user: request.user())
    //        }
    //
    //        let user = try request.user()
    //
    //        user.password = try BlogUser.passwordHasher.make(password)
    //        user.resetPasswordRequired = false
    //        try user.save()
    //
    //        return Response(redirect: pathCreator.createPath(for: "admin"))
    //    }
}

struct LoginData: Content {
    let username: String?
    let password: String?
    #warning("Remember me")
}

