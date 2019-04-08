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
        let userRepository = try req.make(BlogUserRepository.self)
        return userRepository.save(newUser, on: req).map { _ in
            return req.redirect(to: "/")
        }

//
//        let (createUserRawErrors, passwordRawError, confirmPasswordRawError) = validateUserSaveDataExists(edit: false, name: rawName, username: rawUsername, password: rawPassword, confirmPassword: rawConfirmPassword, profilePicture: profilePicture)
//
//        // Return if we have any missing fields
//        if !(createUserRawErrors?.isEmpty ?? true) {
//            return try viewFactory.createUserView(editing: false, errors: createUserRawErrors, name: rawName, username: rawUsername, passwordError: passwordRawError, confirmPasswordError: confirmPasswordRawError, resetPasswordRequired: resetPasswordRequired, userId: nil, profilePicture: profilePicture, twitterHandle: twitterHandle, biography: biography, tagline: tagline, loggedInUser: request.user())
//        }
//
//        guard let name = rawName, let username = rawUsername?.lowercased(), let password = rawPassword, let confirmPassword = rawConfirmPassword else {
//            throw Abort.badRequest
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
//
//        if resetPasswordRequired {
//            newUser.resetPasswordRequired = true
//        }
//
//        do {
//            try newUser.save()
//        } catch {
//            return try viewFactory.createUserView(editing: false, errors: ["There was an error creating the user. Please try again"], name: name, username: username, passwordError: passwordError, confirmPasswordError: confirmPasswordError, resetPasswordRequired: resetPasswordRequired, userId: nil, profilePicture: profilePicture, twitterHandle: twitterHandle, biography: biography, tagline: tagline, loggedInUser: request.user())
//        }
//
//        return Response(redirect: pathCreator.createPath(for: "admin"))

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
        
        if data.password != data.confirmPassword {
            createUserErrors.append("Your passwords must match")
        }
        
        if data.password?.count ?? 0 < 10 {
            createUserErrors.append("Your password must be at least 10 characters long")
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
    #warning("resetpassword")
    //        let resetPasswordRequired = rawPasswordResetRequired != nil
}
