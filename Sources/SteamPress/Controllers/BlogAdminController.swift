import Vapor

struct BlogAdminController: RouteCollection {

    // MARK: - Properties
    fileprivate let pathCreator: BlogPathCreator

    // MARK: - Initialiser
    init(pathCreator: BlogPathCreator) {
        self.pathCreator = pathCreator
    }

    // MARK: - Route setup
    func boot(routes: RoutesBuilder) throws {
        let adminRoutes = routes.grouped("admin")

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
        return req.blogPostRepository.getAllPostsSortedByPublishDate(includeDrafts: true).and(req.blogUserRepository.getAllUsers()).flatMap { posts, users in
            return try req.adminPresenter.createIndexView(posts: posts, users: users, errors: nil, pageInformation: req.adminPageInfomation())
        }
    }

}
