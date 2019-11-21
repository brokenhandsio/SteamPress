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
    func adminHandler(_ req: Request) throws -> EventLoopFuture<View> {
        return try req.make(BlogAdminPresenter.self).createIndexView(on: req, errors: nil)
    }

//
//    private func validateUserSaveData(edit: Bool, name: String, username: String, password: String?, confirmPassword: String?, previousUsername: String? = nil) -> ([String]?, Bool?, Bool?) {
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

}

