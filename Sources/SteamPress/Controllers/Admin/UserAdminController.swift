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
        router.post("createUser", use: createUserPostHandler)
        router.post("users", BlogUser.parameter, "edit", use: editUserPostHandler)
        router.post("users", BlogUser.parameter, "delete", use: deleteUserPostHandler)
    }
    
    // MARK: - Route handlers
    func createUserPostHandler(_ req: Request) throws -> Future<Response> {
        let data = try req.content.syncDecode(CreateUserData.self)
        
        if let createUserErrors = validateUserCreation(data) {
            let presenter = try req.make(BlogAdminPresenter.self)
            let view = presenter.createUserView(on: req, errors: createUserErrors)
            return try view.encode(for: req)
        }
        
        guard let name = data.name, let username = data.username, let password = data.password else {
            throw Abort(.internalServerError)
        }
        
        let newUser = BlogUser(name: name, username: username, password: password, profilePicture: data.profilePicture, twitterHandle: data.twitterHandle, biography: data.biography, tagline: data.tagline)
        if let resetPasswordRequired = data.resetPasswordOnLogin, resetPasswordRequired {
            newUser.resetPasswordRequired = true
        }
        let userRepository = try req.make(BlogUserRepository.self)
        return userRepository.save(newUser, on: req).map { _ in
            return req.redirect(to: self.pathCreator.createPath(for: "admin"))
        }
        
        //
        //        let (createUserRawErrors, passwordRawError, confirmPasswordRawError) = validateUserSaveDataExists(edit: false, name: rawName, username: rawUsername, password: rawPassword, confirmPassword: rawConfirmPassword, profilePicture: profilePicture)
        //
        //        // Return if we have any missing fields
        //        if !(createUserRawErrors?.isEmpty ?? true) {
        //            return try viewFactory.createUserView(editing: false, errors: createUserRawErrors, name: rawName, username: rawUsername, passwordError: passwordRawError, confirmPasswordError: confirmPasswordRawError, resetPasswordRequired: resetPasswordRequired, userId: nil, profilePicture: profilePicture, twitterHandle: twitterHandle, biography: biography, tagline: tagline, loggedInUser: request.user())
        //        }
        //
        //        let (createUserErrors, passwordError, confirmPasswordError) = validateUserSaveData(edit: false, name: name, username: username, password: password, confirmPassword: confirmPassword)
        //
        //        if !(createUserErrors?.isEmpty ?? true) {
        //            return try viewFactory.createUserView(editing: false, errors: createUserErrors, name: name, username: username, passwordError: passwordError, confirmPasswordError: confirmPasswordError, resetPasswordRequired: resetPasswordRequired, userId: nil, profilePicture: profilePicture, twitterHandle: twitterHandle, biography: biography, tagline: tagline, loggedInUser: request.user())
        //        }
        //
        //        // We now have valid data
        //        let hashedPassword = try BlogUser.passwordHasher.make(password)
        //        let newUser = BlogUser(name: name, username: username.lowercased(), password: hashedPassword, profilePicture: profilePicture, twitterHandle: twitterHandle, biography: biography, tagline: tagline)
    }
    
    func editUserPostHandler(_ req: Request) throws -> Future<Response> {
        return try req.parameters.next(BlogUser.self).flatMap { user in
            let data = try req.content.syncDecode(CreateUserData.self)
            
            guard let name = data.name, let username = data.username else {
                throw Abort(.internalServerError)
            }
            
            user.name = name
            user.username = username
//            user.profilePicture = data.profilePicture
//            user.twitterHandle = data.twitterHandle
//            user.biography = data.biography
//            user.tagline = data.tagline
            
            let redirect = req.redirect(to: self.pathCreator.createPath(for: "admin"))
            let userRepository = try req.make(BlogUserRepository.self)
            return userRepository.save(user, on: req).transform(to: redirect)
        }
//
//        let (saveUserRawErrors, passwordRawError, confirmPasswordRawError) = validateUserSaveDataExists(edit: true, name: rawName, username: rawUsername, password: rawPassword, confirmPassword: rawConfirmPassword, profilePicture: profilePicture)
//
//        // Return if we have any missing fields
//        if !(saveUserRawErrors?.isEmpty ?? true) {
//            return try viewFactory.createUserView(editing: true, errors: saveUserRawErrors, name: rawName, username: rawUsername, passwordError: passwordRawError, confirmPasswordError: confirmPasswordRawError, resetPasswordRequired: resetPasswordRequired, userId: user.id, profilePicture: profilePicture, twitterHandle: twitterHandle, biography: biography, tagline: tagline, loggedInUser: request.user())
//        }
//
//        guard let name = rawName, let username = rawUsername else {
//            throw Abort.badRequest
//        }
//
//        let (saveUserErrors, passwordError, confirmPasswordError) = validateUserSaveData(edit: true, name: name, username: username, password: rawPassword, confirmPassword: rawConfirmPassword, previousUsername: user.username)
//
//        if !(saveUserErrors?.isEmpty ?? true) {
//            return try viewFactory.createUserView(editing: true, errors: saveUserErrors, name: name, username: username, passwordError: passwordError, confirmPasswordError: confirmPasswordError, resetPasswordRequired: resetPasswordRequired, userId: user.id, profilePicture: profilePicture, twitterHandle: twitterHandle, biography: biography, tagline: tagline, loggedInUser: request.user())
//        }
//
//        // We now have valid data
//        guard let userId = user.id, let userToUpdate = try BlogUser.find(userId) else {
//            throw Abort.badRequest
//        }
//        userToUpdate.name = name
//        userToUpdate.username = username
//        userToUpdate.profilePicture = profilePicture
//        userToUpdate.twitterHandle = twitterHandle
//        userToUpdate.biography = biography
//        userToUpdate.tagline = tagline
//
//        if resetPasswordRequired {
//            userToUpdate.resetPasswordRequired = true
//        }
//
//        if let password = rawPassword {
//            userToUpdate.password = try BlogUser.passwordHasher.make(password)
//        }
//
//        try userToUpdate.save()
//        return Response(redirect: pathCreator.createPath(for: "admin"))
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
    private func validateUserCreation(_ data: CreateUserData) -> [String]? {
        var createUserErrors = [String]()
        
        if data.name.isEmptyOrWhitespace() {
            createUserErrors.append("You must specify a name")
        }
        
        if data.username.isEmptyOrWhitespace() {
            createUserErrors.append("You must specify a username")
        }
        
        if data.password.isEmptyOrWhitespace() {
            createUserErrors.append("You must specify a password")
        }
        
        if data.confirmPassword.isEmptyOrWhitespace() {
            createUserErrors.append("You must confirm your password")
        }
        
        if data.password?.count ?? 0 < 10 {
            createUserErrors.append("Your password must be at least 10 characters long")
        }
        
        if data.password != data.confirmPassword {
            createUserErrors.append("Your passwords must match")
        }
        
        do {
            try data.validate()
        } catch {
            createUserErrors.append("The username provided is not valid")
        }
        
        if createUserErrors.count == 0 {
            return nil
        }
        
        return createUserErrors
    }
    
}

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
        try validations.add(\.username, .alphanumeric || .nil)
        return validations
    }
}
