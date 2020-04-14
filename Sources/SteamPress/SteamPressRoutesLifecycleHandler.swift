import Vapor

public struct SteamPressRoutesLifecycleHandler: LifecycleHandler {

    let blogPath: String?
    let feedInformation: FeedInformation
    let postsPerPage: Int
    let enableAuthorPages: Bool
    let enableTagPages: Bool

    public init(
        blogPath: String?,
        feedInformation: FeedInformation,
        postsPerPage: Int,
        enableAuthorPages: Bool,
        enableTagPages: Bool) {
        self.blogPath = blogPath
        self.feedInformation = feedInformation
        self.postsPerPage = postsPerPage
        self.enableAuthorPages = enableAuthorPages
        self.enableTagPages = enableTagPages
    }
    
    public func willBoot(_ application: Application) throws {
        let router = application.routes
        let pathCreator = BlogPathCreator(blogPath: self.blogPath)

        let feedController = FeedController(pathCreator: pathCreator, feedInformation: self.feedInformation)
        let apiController = APIController()
        let blogController = BlogController(pathCreator: pathCreator, enableAuthorPages: self.enableAuthorPages, enableTagPages: self.enableTagPages, postsPerPage: self.postsPerPage)
        let blogAdminController = BlogAdminController(pathCreator: pathCreator)

        let blogRoutes: RoutesBuilder
        if let blogPath = blogPath {
            blogRoutes = router.grouped(PathComponent(stringLiteral: blogPath))
        } else {
            blogRoutes = router.grouped("")
        }
        let steampressSessionsConfig = SessionsConfiguration(cookieName: "steampress-session") { value in
            HTTPCookies.Value(string: value.string)
        }
        let steampressSessions = SessionsMiddleware(session: application.sessions.driver, configuration: steampressSessionsConfig)
        let steampressAuthSessions = BlogAuthSessionsMiddleware()
        let sessionedRoutes = blogRoutes.grouped(steampressSessions, steampressAuthSessions)

        try sessionedRoutes.register(collection: feedController)
        try sessionedRoutes.register(collection: apiController)
        try sessionedRoutes.register(collection: blogController)
        try sessionedRoutes.register(collection: blogAdminController)
    }
}

