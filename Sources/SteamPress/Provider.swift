import Vapor
import Authentication

public struct Provider<P: BlogPresenter, AP: BlogAdminPresenter>: Vapor.Provider {
    
    public static var repositoryName: String {
        return "steampress"
    }
    
    let blogPath: String?
    let pathCreator: BlogPathCreator
    let blogPresenter: P
    let blogAdminPresenter: AP
    let feedInformation: FeedInformation
    let enableAuthorPages: Bool
    let enableTagPages: Bool
    
    #warning("Update")
    /**
     Initialiser for SteamPress' Provider to add a blog to your Vapor App. You can pass it an optional
     `blogPath` to add the blog to. For instance, if you pass in "blog", your blog will be accessible
     at http://mysite.com/blog/, or if you pass in `nil` your blog will be added to the root of your
     site (i.e. http://mysite.com/)
     - Parameter blogPath: The path to add the blog too
     blog (integrates with Paginator)
     - Parameter feedInformation: Information to vend to the RSS and Atom feeds
     - Parameter postsPerPage: The number of posts to show per page on the main index page of the
     - Parameter enableAuthorsPages: Flag used to determine whether to publicly expose the authors endpoints
     or not. Defaults to true
     - Parameter enableTagsPages: Flag used to determine whether to publicy expose the tags endpoints or not.
     Defaults to true
     - Parameter blogPresenter: The presenter to generate templates with, defaults to LeafBlogPresenter
     - Parameter blogAdminPresenter: The presenter to generate templates for the admin section, defaults to LeadBlogAdminPresenter
     */
    public init(
        blogPath: String? = nil,
        feedInformation: FeedInformation = FeedInformation(),
        postsPerPage: Int,
        enableAuthorPages: Bool = true,
        enableTagPages: Bool = true,
        blogPresenter: P,
        blogAdminPresenter: AP) {
        //        self.postsPerPage = postsPerPage
        self.blogPath = blogPath
        self.feedInformation = feedInformation
        self.pathCreator = BlogPathCreator(blogPath: self.blogPath)
        #warning("Default to sensible ones in the constructor")
        self.blogPresenter = blogPresenter
        self.blogAdminPresenter = blogAdminPresenter
        self.enableAuthorPages = enableAuthorPages
        self.enableTagPages = enableTagPages
    }
    
    public func register(_ services: inout Services) throws {
        services.register(BlogPresenter.self) { _ in
            return self.blogPresenter
        }
        
        services.register(BlogAdminPresenter.self) { _ in
            return self.blogAdminPresenter
        }
        
        try services.register(AuthenticationProvider())
        services.register([PasswordHasher.self, PasswordVerifier.self]) { _ in
            return BCryptDigest()
        }
        
        services.register(BlogRememberMeMiddleware.self)
    }
    
    public func willBoot(_ container: Container) throws -> EventLoopFuture<Void> {
        let router = try container.make(Router.self)
        
        let feedController = FeedController(pathCreator: pathCreator, feedInformation: feedInformation)
        let apiController = APIController()
        let blogController = BlogController(pathCreator: pathCreator, enableAuthorPages: enableAuthorPages, enableTagPages: enableTagPages)
        let blogAdminController = BlogAdminController(pathCreator: pathCreator)
        
        let blogRoutes: Router
        if let blogPath = blogPath {
            blogRoutes = router.grouped(blogPath)
        } else {
            blogRoutes = router.grouped("")
        }
        let steampressSessionsConfig = SessionsConfig(cookieName: "steampress-session") { value in
            return HTTPCookieValue(string: value)
        }
        let steampressSessions = try SessionsMiddleware(sessions: container.make(), config: steampressSessionsConfig)
        let steampressAuthSessions = BlogAuthSessionsMiddleware()
        let sessionedRoutes = blogRoutes.grouped(steampressSessions, steampressAuthSessions)
        
        try sessionedRoutes.register(collection: feedController)
        try sessionedRoutes.register(collection: apiController)
        try sessionedRoutes.register(collection: blogController)
        try sessionedRoutes.register(collection: blogAdminController)
        return .done(on: container)
    }
    
    public func didBoot(_ container: Container) throws -> EventLoopFuture<Void> {
        return .done(on: container)
    }
    
    
}
