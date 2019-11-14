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
    func createUserHandler(_ req: Request) throws -> Future<View> {
        let presenter = try req.make(BlogAdminPresenter.self)
        return presenter.createUserView(on: req, errors: nil, name: nil, username: nil, passwordError: false, confirmPasswordError: false, userID: nil, profilePicture: nil, twitterHandle: nil, biography: nil, tagline: nil)
    }
    
    func createUserPostHandler(_ req: Request) throws -> Future<Response> {
        let data = try req.content.syncDecode(CreateUserData.self)
        
        if let createUserErrors = validateUserCreation(data) {
            let presenter = try req.make(BlogAdminPresenter.self)
            let view = presenter.createUserView(on: req, errors: createUserErrors.errors, name: data.name, username: data.username, passwordError: createUserErrors.passwordError, confirmPasswordError: createUserErrors.confirmPasswordError, userID: nil, profilePicture: data.profilePicture, twitterHandle: data.twitterHandle, biography: data.biography, tagline: data.tagline)
            return try view.encode(for: req)
        }
        
        guard let name = data.name, let username = data.username, let password = data.password else {
            throw Abort(.internalServerError)
        }
        
        #warning("Test passowrd hash")
        let newUser = BlogUser(name: name, username: username, password: password, profilePicture: data.profilePicture, twitterHandle: data.twitterHandle, biography: data.biography, tagline: data.tagline)
        if let resetPasswordRequired = data.resetPasswordOnLogin, resetPasswordRequired {
            newUser.resetPasswordRequired = true
        }
        let userRepository = try req.make(BlogUserRepository.self)
        return userRepository.save(newUser, on: req).map { _ in
            return req.redirect(to: self.pathCreator.createPath(for: "admin"))
        }
    }
    
    func editUserHandler(_ req: Request) throws -> Future<View> {
        return try req.parameters.next(BlogUser.self).flatMap { user in
            let presenter = try req.make(BlogAdminPresenter.self)
            return presenter.createUserView(on: req, errors: nil, name: user.name, username: user.username, passwordError: false, confirmPasswordError: false, userID: user.userID, profilePicture: user.profilePicture, twitterHandle: user.twitterHandle, biography: user.biography, tagline: user.tagline)
        }
    }
    
    func editUserPostHandler(_ req: Request) throws -> Future<Response> {
        return try req.parameters.next(BlogUser.self).flatMap { user in
            let data = try req.content.syncDecode(CreateUserData.self)
            
            guard let name = data.name, let username = data.username else {
                throw Abort(.internalServerError)
            }
            
            if let editUserErrors = self.validateUserCreation(data, editing: true) {
                let presenter = try req.make(BlogAdminPresenter.self)
                let view = presenter.createUserView(on: req, errors: editUserErrors.errors, name: data.name, username: data.username, passwordError: editUserErrors.passwordError, confirmPasswordError: editUserErrors.confirmPasswordError, userID: nil, profilePicture: data.profilePicture, twitterHandle: data.twitterHandle, biography: data.biography, tagline: data.tagline)
                return try view.encode(for: req)
            }
            
            user.name = name
            user.username = username
            user.profilePicture = data.profilePicture
            user.twitterHandle = data.twitterHandle
            user.biography = data.biography
            user.tagline = data.tagline
            
            if let resetPasswordOnLogin = data.resetPasswordOnLogin, resetPasswordOnLogin {
                user.resetPasswordRequired = true
            }
            
            if let password = data.password {
                #warning("Test password is hashed")
                let hasher = try req.make(PasswordHasher.self)
                user.password = try hasher.hash(password)
            }
            
            let redirect = req.redirect(to: self.pathCreator.createPath(for: "admin"))
            let userRepository = try req.make(BlogUserRepository.self)
            return userRepository.save(user, on: req).transform(to: redirect)
        }
    }
    

    func deleteUserPostHandler(_ req: Request) throws -> Future<Response> {
        let userRepository = try req.make(BlogUserRepository.self)
        return try flatMap(req.parameters.next(BlogUser.self), userRepository.getUsersCount(on: req)) { user, userCount in
            guard userCount > 1 else {
                let presenter = try req.make(BlogAdminPresenter.self)
                let view = presenter.createIndexView(on: req, errors: ["You cannot delete the last user"])
                return try view.encode(for: req)
            }
            
            let loggedInUser = try req.requireAuthenticated(BlogUser.self)
            guard loggedInUser.userID != user.userID else {
                let presenter = try req.make(BlogAdminPresenter.self)
                let view = presenter.createIndexView(on: req, errors: ["You cannot delete yourself whilst logged in"])
                return try view.encode(for: req)
            }
            
            let redirect = req.redirect(to: self.pathCreator.createPath(for: "admin"))
            return userRepository.delete(user, on: req).transform(to: redirect)
        }
    }

    
    // MARK: - Validators
    private func validateUserCreation(_ data: CreateUserData, editing: Bool = false) -> CreateUserErrors? {
        var createUserErrors = [String]()
        var passwordError = false
        var confirmPasswordError = false
        
        if data.name.isEmptyOrWhitespace() {
            createUserErrors.append("You must specify a name")
        }
        
        if data.username.isEmptyOrWhitespace() {
            createUserErrors.append("You must specify a username")
        }
        
        if !editing || data.password != nil {
            if data.password.isEmptyOrWhitespace() {
                createUserErrors.append("You must specify a password")
                passwordError = true
            }
            
            if data.confirmPassword.isEmptyOrWhitespace() {
                createUserErrors.append("You must confirm your password")
                confirmPasswordError = true
            }
        }
        
        if let password = data.password {
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
        }
        
        if createUserErrors.count == 0 {
            return nil
        }
        
        let errors = CreateUserErrors(errors: createUserErrors, passwordError: passwordError, confirmPasswordError: confirmPasswordError)
        
        return errors
    }
    
}

#warning("Move")
struct CreateUserData: Content {
    let name: String?
    let username: String?
    let password: String?
    let confirmPassword: String?
    let profilePicture: String?
    let tagline: String?
    let biography: String?
    let twitterHandle: String?
    let resetPasswordOnLogin: Bool?
}

extension CreateUserData: Validatable , Reflectable{
    static func validations() throws -> Validations<CreateUserData> {
        var validations = Validations(CreateUserData.self)
        let usernameCharacterSet = CharacterSet(charactersIn: "-_")
        let usernameValidationCharacters = Validator<String>.characterSet(.alphanumerics + usernameCharacterSet)
        try validations.add(\.username, usernameValidationCharacters || .nil)
        return validations
    }
}

struct CreateUserErrors {
    let errors: [String]
    let passwordError: Bool
    let confirmPasswordError: Bool
}
