import Vapor

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
        return try req.blogPresenter.loginView(loginWarning: loginRequied, errors: nil, username: nil, usernameError: false, passwordError: false, rememberMe: false, pageInformation: req.pageInformation())
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
            return try req.blogPresenter.loginView(loginWarning: false, errors: loginErrors, username: loginData.username, usernameError: usernameError, passwordError: passwordError, rememberMe: loginData.rememberMe ?? false, pageInformation: req.pageInformation()).encodeResponse(for: req)
        }
        
        guard let username = loginData.username, let password = loginData.password else {
            throw Abort(.internalServerError)
        }
        
        if let rememberMe = loginData.rememberMe, rememberMe {
            req.session.data["SteamPressRememberMe"] = "YES"
        } else {
            req.session.data["SteamPressRememberMe"] = nil
        }
        
        return req.blogUserRepository.getUser(username: username).flatMap { user -> EventLoopFuture<Response> in
            do {
                guard let user = user, try req.passwordVerifier.verify(password, created: user.password) else {
                    let loginError = ["Your username or password is incorrect"]
                    return try req.blogPresenter.loginView(loginWarning: false, errors: loginError, username: loginData.username, usernameError: false, passwordError: false, rememberMe: loginData.rememberMe ?? false, pageInformation: req.pageInformation()).encodeResponse(for: req)
                }
                user.authenticateSession(on: req)
                return req.eventLoop.future(req.redirect(to: self.pathCreator.createPath(for: "admin")))
            }
            catch {
                return req.eventLoop.makeFailedFuture(error)
            }
        }
    }
    
    func logoutHandler(_ request: Request) -> Response {
        request.unauthenticateBlogUserSession()
        return request.redirect(to: pathCreator.createPath(for: pathCreator.blogPath))
    }
    
    func resetPasswordHandler(_ req: Request) throws -> EventLoopFuture<View> {
        try req.adminPresenter.createResetPasswordView(errors: nil, passwordError: nil, confirmPasswordError: nil, pageInformation: req.adminPageInfomation())
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
            
            let view = try req.adminPresenter.createResetPasswordView(errors: resetPasswordErrors, passwordError: passwordError, confirmPasswordError: confirmPasswordError, pageInformation: req.adminPageInfomation())
            return view.encodeResponse(for: req)
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
            let view = try req.adminPresenter.createResetPasswordView(errors: resetPasswordErrors, passwordError: passwordError, confirmPasswordError: confirmPasswordError, pageInformation: req.adminPageInfomation())
            return view.encodeResponse(for: req)
        }
        
        let user = try req.auth.require(BlogUser.self)
        user.password = try req.passwordHasher.hash(password)
        user.resetPasswordRequired = false
        let redirect = req.redirect(to: pathCreator.createPath(for: "admin"))
        return req.blogUserRepository.save(user).transform(to: redirect)
    }
}
