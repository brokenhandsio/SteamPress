import Vapor
//import MarkdownProvider
//import Leaf
////import AuthProvider
////import Sessions
////import Cookies
//import Foundation
//

public struct Provider: Vapor.Provider {

    public static var repositoryName: String {
        return "steampress"
    }

    let blogPath: String?
    let pathCreator: BlogPathCreator
    let blogPresenter: BlogPresenter
    let feedInformation: FeedInformation
    let enableAuthorPages: Bool
    let enableTagPages: Bool

    // TODO update
    /**
     Initialiser for SteamPress' Provider to add a blog to your Vapor App. You can pass it an optional
     `blogPath` to add the blog to. For instance, if you pass in "blog", your blog will be accessible
     at http://mysite.com/blog/, or if you pass in `nil` your blog will be added to the root of your
     site (i.e. http://mysite.com/)

     - Parameter postsPerPage: The number of posts to show per page on the main index page of the
     blog (integrates with Paginator)
     - Parameter blogPath: The path to add the blog too
     - Parameter useBootstrap4: Flag used to deterimine whether to use Bootstrap v4 for Paginator.
     Defaults to true
     - Parameter enableAuthorsPages: Flag used to determine whether to publicly expose the authors endpoints
     or not. Defaults to true
     - Parameter enableTagsPages: Flag used to determine whether to publicy expose the tags endpoints or not.
     Defaults to true
     */
    public init(
                blogPath: String? = nil,
                feedInformation: FeedInformation = FeedInformation(),
                postsPerPage: Int,
                useBootstrap4: Bool = true,
                enableAuthorPages: Bool = true,
                enableTagPages: Bool = true,
                blogPresenter: BlogPresenter? = nil) {
//        self.postsPerPage = postsPerPage
//        self.databaseIdentifier = databaseIdentifier
        self.blogPath = blogPath
        self.feedInformation = feedInformation

        self.pathCreator = BlogPathCreator(blogPath: self.blogPath)
        #warning("Default to sensible one")
        self.blogPresenter = blogPresenter!
        self.enableAuthorPages = enableAuthorPages
        self.enableTagPages = enableTagPages

//        self.useBootstrap4 = useBootstrap4
        
    }

    public func register(_ services: inout Services) throws {
//        var migrationConfig = MigrationConfig()
//        migrationConfig.add(model: BlogPost.self, database: databaseIdentifier)
//        migrationConfig.add(model: BlogUser.self, database: databaseIdentifier)
//        migrationConfig.add(model: BlogTag.self, database: databaseIdentifier)
//        migrationConfig.add(model: BlogPostTagPivot.self, database: databaseIdentifier)
//        services.register(migrationConfig)
//        services.register(blogPresenter, as: [BlogPresenter.self])
//        let factory = BasicServiceFactory(BlogPresenter.self, supports: interfaces) { container in
//            return instance
//        }
        #warning("sort out with generics")
//        services.register([BlogPresenter.self], factory: { _ in
//            return blogPresenter
//        })
    }

    public func willBoot(_ container: Container) throws -> Future<Void> {
        let router = try container.make(Router.self)

        let feedController = FeedController(pathCreator: pathCreator, feedInformation: feedInformation)
        let apiController = APIController()
        let blogController = BlogController(enableAuthorPages: enableAuthorPages, enableTagPages: enableTagPages)

        let blogRoutes: Router
        if let blogPath = blogPath {
            blogRoutes = router.grouped(blogPath)
        } else {
            blogRoutes = router.grouped("")
        }
        try blogRoutes.register(collection: feedController)
        try blogRoutes.register(collection: apiController)
        try blogRoutes.register(collection: blogController)
        return .done(on: container)
    }

    public func didBoot(_ container: Container) throws -> Future<Void> {
        return .done(on: container)
    }


}
//
//    private static let configFilename: String = "steampress"
//    public static let repositoryName: String = "steampress"
//    static let cookieName = "steampress-session"
//
//    private let blogPath: String?
//    private let postsPerPage: Int
//    private let pathCreator: BlogPathCreator
//    private let useBootstrap4: Bool
//    private let enableAuthorsPages: Bool
//    private let enableTagsPages: Bool
//
//    static func createCookieFactory(for environment: Environment) -> ((_ request: Request) -> Cookie) {
//        let cookieFactory: (_ request: Request) -> Cookie = { req in
//            var cookie = Cookie(name: cookieName, value: "", secure: environment == .production,
//                                httpOnly: true, sameSite: .lax)
//
//            if req.storage["remember_me"] as? Bool ?? false {
//                let oneMonthTime: TimeInterval = 30 * 24 * 60 * 60
//                let expiryDate = Date().addingTimeInterval(oneMonthTime)
//                cookie.expires = expiryDate
//            }
//
//            return cookie
//        }
//
//        return cookieFactory
//    }
//
//    public func boot(_ config: Config) throws {
//        try config.addProvider(AuthProvider.Provider.self)
//
//        // Database preparations
//        config.preparations.append(BlogUser.self)
//        config.preparations.append(BlogPost.self)
//        config.preparations.append(BlogTag.self)
//        config.preparations.append(Pivot<BlogPost, BlogTag>.self)
//        config.preparations.append(BlogPostDraft.self)
//        config.preparations.append(BlogUserExtraInformation.self)
//        config.preparations.append(BlogAdminUser.self)
//        config.preparations.append(BlogIndexes.self)
//
//        // Sessions
//        let persistMiddleware = PersistMiddleware(BlogUser.self)
//        config.addConfigurable(middleware: { (_) -> (PersistMiddleware<BlogUser>) in
//            return persistMiddleware
//        }, name: "blog-persist")
//
//        let cookieFactory = Provider.createCookieFactory(for: config.environment)
//        let sessionsMiddleware = SessionsMiddleware(try config.resolveSessions(), cookieName: Provider.cookieName,
//                                                    cookieFactory: cookieFactory)
//        config.addConfigurable(middleware: { (_) -> (SessionsMiddleware) in
//            return sessionsMiddleware
//        }, name: "steampress-sessions")
//    }
//
//    public func boot(_ drop: Droplet) {
//
//        BlogPost.postsPerPage = postsPerPage
//
//        BlogAdminUser.log = drop.log
//
//        // Set up Leaf tag
//        if let leaf = drop.view as? LeafRenderer {
//            leaf.stem.register(Markdown())
//            leaf.stem.register(PaginatorTag(blogPathCreator: pathCreator, paginationLabel: "Blog Post Pages",
//                                            useBootstrap4: useBootstrap4))
//        }
//
//        // TODO
//        let viewFactory = LeafViewFactory(viewRenderer: drop.view,
//                                          disqusName: drop.config["disqus", "disqusName"]?.string,
//                                          siteTwitterHandle: drop.config["twitter", "siteHandle"]?.string,
//                                          googleAnalyticsIdentifier: drop.config["googleAnalytics", "identifier"]?.string)
//
//        // Set up the controllers
//        let blogController = BlogController(drop: drop, pathCreator: pathCreator,
//                                            viewFactory: viewFactory, enableAuthorsPages: enableAuthorsPages,
//                                            enableTagsPages: enableTagsPages)
//        let blogAdminController = BlogAdminController(drop: drop, pathCreator: pathCreator, viewFactory: viewFactory)
//        let feedController = BlogFeedController(drop: drop, pathCreator: pathCreator,
//                                                   title: drop.config["steampress", "title"]?.string,
//                                                   description: drop.config["steampress", "description"]?.string,
//                                                   copyright: drop.config["steampress", "copyright"]?.string,
//                                                   imageURL: drop.config["steampress", "imageURL"]?.string)
//
//        // Add the routes
//        blogController.addRoutes()
//        blogAdminController.addRoutes()
//        feedController.addRoutes()
//    }
//
//    public init(config: Config) throws {
//
//        guard let postsPerPage = config[Provider.configFilename, "postsPerPage"]?.int else {
//            throw Error.invalidConfiguration(message: "Missing postsPerPage variable in Steampress' config file")
//        }
//
//        var blogPath: String? = nil
//
//        if let blogPathFromConfig = config[Provider.configFilename, "blogPath"]?.string {
//            blogPath = blogPathFromConfig
//        }
//
//        let useBootstrap4 = config[Provider.configFilename, "paginator", "useBootstrap4"]?.bool ?? true
//        let enableAuthorsPages = config[Provider.configFilename, "enableAuthorsPages"]?.bool ?? true
//        let enableTagsPages = config[Provider.configFilename, "enableTagsPages"]?.bool ?? true
//
//        self.init(postsPerPage: postsPerPage, blogPath: blogPath, useBootstrap4: useBootstrap4,
//                  enableAuthorsPages: enableAuthorsPages, enableTagsPages: enableTagsPages)
//    }
//
//
//    enum Error: Swift.Error {
//        case invalidConfiguration(message: String)
//    }
//
//    public func beforeRun(_: Vapor.Droplet) {}
//
//}

public struct FeedInformation {
    let title: String?
    let description: String?
    let copyright: String?
    let imageURL: String?
    
    public init(title: String? = nil, description: String? = nil, copyright: String? = nil, imageURL: String? = nil) {
        self.title = title
        self.description = description
        self.copyright = copyright
        self.imageURL = imageURL
    }
}
