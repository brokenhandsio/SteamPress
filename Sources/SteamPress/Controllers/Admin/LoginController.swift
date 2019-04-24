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
        router.post("resetPassword", use: resetPasswordPostHandler)
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

    func resetPasswordPostHandler(_ req: Request) throws -> EventLoopFuture<Response> {
        let data = try req.content.syncDecode(ResetPasswordData.self)

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
            let view = presenter.createResetPasswordView(on: req, errors: resetPasswordErrors, passwordError: passwordError, confirmPasswordError: confirmPasswordError)
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
            let view = presenter.createResetPasswordView(on: req, errors: resetPasswordErrors, passwordError: passwordError, confirmPasswordError: confirmPasswordError)
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

#warning("Move")
public protocol PasswordHasher: Service {
    func hash(_ plaintext: LosslessDataConvertible) throws -> String
}

extension BCryptDigest: PasswordHasher {
    public func hash(_ plaintext: LosslessDataConvertible) throws -> String {
        return try self.hash(plaintext, salt: nil)
    }
}

struct LoginData: Content {
    let username: String?
    let password: String?
    #warning("Remember me")
}

struct ResetPasswordData: Content {
    let password: String?
    let confirmPassword: String?
}

