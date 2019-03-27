import Vapor
import Authentication
//import HTTP
//import Routing
////import AuthProvider
//import Foundation
//import Fluent
//import Validation
////import Cookies
//
struct BlogAdminController: RouteCollection {

    // MARK: - Properties
    fileprivate let pathCreator: BlogPathCreator

    // MARK: - Initialiser
    init(pathCreator: BlogPathCreator) {
        self.pathCreator = pathCreator
    }

    // MARK: - Route setup
    func boot(router: Router) throws {
        let adminRoutes = router.grouped("admin")
        
        let redirectMiddleware = BlogLoginRedirectAuthMiddleware(pathCreator: pathCreator)
        let adminProtectedRoutes = adminRoutes.grouped(redirectMiddleware)
        adminProtectedRoutes.get(use: adminHandler)
        
        let loginController = LoginController(pathCreator: pathCreator)
        try adminRoutes.register(collection: loginController)
        let postController = PostAdminController()
        try adminProtectedRoutes.register(collection: postController)
    }
//    func addRoutes() {
//        let router = drop.grouped(pathCreator.blogPath ?? "", "admin")
//
//        router.get("login", handler: loginHandler)
//        router.post("login", handler: loginPostHandler)
//        router.get("logout", handler: logoutHandler)
//
//        let protect = BlogLoginRedirectAuthMiddleware(pathCreator: pathCreator)
//        let routerSecure = router.grouped(protect)
//        routerSecure.get(handler: adminHandler)
//        routerSecure.get("createPost", handler: createPostHandler)
//        routerSecure.post("createPost", handler: createPostPostHandler)
//        routerSecure.get("createUser", handler: createUserHandler)
//        routerSecure.post("createUser", handler: createUserPostHandler)
//        routerSecure.get("posts", BlogPost.parameter, "delete", handler: deletePostHandler)
//        routerSecure.get("posts", BlogPost.parameter, "edit", handler: editPostHandler)
//        routerSecure.post("posts", BlogPost.parameter, "edit", handler: editPostPostHandler)
//        routerSecure.get("users", BlogUser.parameter, "edit", handler: editUserHandler)
//        routerSecure.post("users", BlogUser.parameter, "edit", handler: editUserPostHandler)
//        routerSecure.get("users", BlogUser.parameter, "delete", handler: deleteUserPostHandler)
//        routerSecure.get("resetPassword", handler: resetPasswordHandler)
//        routerSecure.post("resetPassword", handler: resetPasswordPostHandler)
//    }

    // MARK: - Route Handlers

    // MARK: - Blog Posts handlers
    
//    // MARK: - User handlers
//    func createUserHandler(_ request: Request) throws -> ResponseRepresentable {
//        return try viewFactory.createUserView(editing: false, errors: nil, name: nil, username: nil, passwordError: nil, confirmPasswordError: nil, resetPasswordRequired: nil, userId: nil, profilePicture: nil, twitterHandle: nil, biography: nil, tagline: nil, loggedInUser: request.user())
//    }
//
//    func createUserPostHandler(_ request: Request) throws -> ResponseRepresentable {
//
//        let rawName = request.data["inputName"]?.string
//        let rawUsername = request.data["inputUsername"]?.string
//        let rawPassword = request.data["inputPassword"]?.string
//        let rawConfirmPassword = request.data["inputConfirmPassword"]?.string
//        let rawPasswordResetRequired = request.data["inputResetPasswordOnLogin"]?.string
//        let resetPasswordRequired = rawPasswordResetRequired != nil
//        let profilePicture = request.data["inputProfilePicture"]?.string
//        let tagline = request.data["inputTagline"]?.string
//        let biography = request.data["inputBiography"]?.string
//        let twitterHandle = request.data["inputTwitterHandle"]?.string
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
//
//    }
//
//    func editUserHandler(request: Request) throws -> ResponseRepresentable {
//        let user = try request.parameters.next(BlogUser.self)
//        return try viewFactory.createUserView(editing: true, errors: nil, name: user.name, username: user.username, passwordError: nil, confirmPasswordError: nil, resetPasswordRequired: nil, userId: user.id, profilePicture: user.profilePicture, twitterHandle: user.twitterHandle, biography: user.biography, tagline: user.tagline, loggedInUser: request.user())
//    }
//
//    func editUserPostHandler(request: Request) throws -> ResponseRepresentable {
//        let user = try request.parameters.next(BlogUser.self)
//        let rawName = request.data["inputName"]?.string
//        let rawUsername = request.data["inputUsername"]?.string
//        let rawPassword = request.data["inputPassword"]?.string
//        let rawConfirmPassword = request.data["inputConfirmPassword"]?.string
//        let rawPasswordResetRequired = request.data["inputResetPasswordOnLogin"]?.string
//        let resetPasswordRequired = rawPasswordResetRequired != nil
//        let profilePicture = request.data["inputProfilePicture"]?.string
//        let tagline = request.data["inputTagline"]?.string
//        let biography = request.data["inputBiography"]?.string
//        let twitterHandle = request.data["inputTwitterHandle"]?.string
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
//    }
//
//    func deleteUserPostHandler(request: Request) throws -> ResponseRepresentable {
//        let user = try request.parameters.next(BlogUser.self)
//        // Check we have at least one user left
//        let users = try BlogUser.all()
//        if users.count <= 1 {
//            return try viewFactory.createBlogAdminView(errors: ["You cannot delete the last user"], user: try request.user())
//        }
//        // Make sure we aren't deleting ourselves!
//        else if try request.user().id == user.id {
//            return try viewFactory.createBlogAdminView(errors: ["You cannot delete yourself whilst logged in"], user: try request.user())
//        } else {
//            try user.delete()
//            return Response(redirect: pathCreator.createPath(for: "admin"))
//        }
//    }


    // MARK: Admin Handler
    func adminHandler(_ req: Request) throws -> Future<View> {
        return try req.make(BlogAdminPresenter.self).createIndexView(on: req)
    }

//
//    // MARK: - Validators
//    private func validatePostCreation(title: String?, contents: String?, slugUrl: String?) -> [String]? {
//        var createPostErrors: [String] = []
//
//        if title == nil || (title?.isWhitespace() ?? false) {
//            createPostErrors.append("You must specify a blog post title")
//        }
//
//        if contents == nil || (contents?.isWhitespace() ?? false) {
//            createPostErrors.append("You must have some content in your blog post")
//        }
//
//        if (slugUrl == nil || (slugUrl?.isWhitespace() ?? false)) && (!(title == nil || (title?.isWhitespace() ?? false))) {
//            // The user can't manually edit this so if the title wasn't empty, we should never hit here
//            createPostErrors.append("There was an error with your request, please try again")
//        }
//
//        if createPostErrors.count == 0 {
//            return nil
//        }
//
//        return createPostErrors
//    }
//
//    private func validateUserSaveDataExists(edit: Bool, name: String?, username: String?, password: String?, confirmPassword: String?, profilePicture: String?) -> ([String]?, Bool?, Bool?) {
//        var userSaveErrors: [String] = []
//        var passwordError: Bool?
//        var confirmPasswordError: Bool?
//
//        if name == nil || (name?.isWhitespace() ?? false) {
//            userSaveErrors.append("You must specify a name")
//        }
//
//        if username == nil || (username?.isWhitespace() ?? false) {
//            userSaveErrors.append("You must specify a username")
//        }
//
//        if !edit {
//            if password == nil {
//                userSaveErrors.append("You must specify a password")
//                passwordError = true
//            }
//
//            if confirmPassword == nil {
//                userSaveErrors.append("You must confirm your password")
//                confirmPasswordError = true
//            }
//        }
//
//        return (userSaveErrors, passwordError, confirmPasswordError)
//    }
//
//    private func validateUserSaveData(edit: Bool, name: String, username: String, password: String?, confirmPassword: String?, previousUsername: String? = nil) -> ([String]?, Bool?, Bool?) {
//
//        var userSaveErrors: [String] = []
//        var passwordError: Bool?
//        var confirmPasswordError: Bool?
//
//        if password != confirmPassword {
//            userSaveErrors.append("Your passwords must match!")
//            passwordError = true
//            confirmPasswordError = true
//        }
//
//        // Check name is valid
//        let validName = name.passes(NameValidator())
//        if !validName {
//            userSaveErrors.append("The name provided is not valid")
//        }
//
//        // Check username is valid
//        let validUsername = username.passes(UsernameValidator())
//        if !validUsername {
//            userSaveErrors.append("The username provided is not valid")
//        }
//
//        // Check password is valid
//        if !edit || password != nil {
//            guard let actualPassword = password else {
//                fatalError()
//            }
//            let validPassword = actualPassword.passes(PasswordValidator())
//            if !validPassword {
//                userSaveErrors.append("Your password must contain a lowercase letter, an upperacase letter, a number and a symbol")
//                passwordError = true
//            }
//        }
//
//        // Check username unique
//        do {
//            if username != previousUsername {
//                let usernames = try BlogUser.all().map { $0.username.lowercased() }
//                if usernames.contains(username.lowercased()) {
//                    userSaveErrors.append("Sorry that username has already been taken")
//                }
//            }
//        } catch {
//            userSaveErrors.append("Unable to validate username")
//        }
//
//        return (userSaveErrors, passwordError, confirmPasswordError)
//    }
//
//}
//
//// MARK: - Extensions
//extension String {
//
//    // TODO Could probably improve this
//    static func random(length: Int = 8) -> String {
//        let base = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
//        var randomString: String = ""
//
//        for _ in 0..<length {
//            #if swift(>=4)
//            let randomValue = Int.random(min: 0, max: base.count-1)
//            #else
//            let randomValue = Int.random(min: 0, max: base.characters.count-1)
//            #endif
//            randomString += "\(base[base.index(base.startIndex, offsetBy: Int(randomValue))])"
//        }
//        return randomString
//    }
//
//    func isWhitespace() -> Bool {
//        let whitespaceSet = CharacterSet.whitespacesAndNewlines
//        if isEmpty || self.trimmingCharacters(in: whitespaceSet).isEmpty {
//            return true
//        } else {
//            return false
//        }
//    }
}

