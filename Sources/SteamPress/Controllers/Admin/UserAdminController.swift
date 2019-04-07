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
        
        let newUser = BlogUser(name: data.name, username: data.username, password: data.password, profilePicture: nil, twitterHandle: nil, biography: nil, tagline: nil)
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
    
}

struct CreateUserData: Content {
    let name: String
    let username: String
    let password: String
    let confirmPassword: String
    #warning("resetpassword")
    #warning("ProfilePicture")
    #warning("tagline")
    #warning("biography")
    #warning("twitterHandler")
    //        let resetPasswordRequired = rawPasswordResetRequired != nil
}
