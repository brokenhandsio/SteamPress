import Vapor
import Authentication

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
        let postController = PostAdminController(pathCreator: pathCreator)
        try adminProtectedRoutes.register(collection: postController)
        let userController = UserAdminController(pathCreator: pathCreator)
        try adminProtectedRoutes.register(collection: userController)
    }
    
    // MARK: Admin Handler
    func adminHandler(_ req: Request) throws -> Future<View> {
        return try req.make(BlogAdminPresenter.self).createIndexView(on: req, errors: nil)
    }

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
}

