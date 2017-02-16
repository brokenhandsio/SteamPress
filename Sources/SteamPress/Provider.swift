import Vapor
import Fluent
import Paginator
import LeafMarkdown

public struct Provider: Vapor.Provider {

    public var provided: Providable = Providable()

    private let blogPath: String?
    private let postsPerPage: Int
    private let pathCreator: BlogPathCreator

    public func boot(_ drop: Droplet) {
        // Database preperations
        drop.preparations.append(BlogPost.self)
        drop.preparations.append(BlogUser.self)
        drop.preparations.append(BlogTag.self)
        drop.preparations.append(Pivot<BlogPost, BlogTag>.self)

        // Middleware
        let authMiddleware = BlogAuthMiddleware()
        drop.middleware.append(authMiddleware)

        // Providers
        let paginator = PaginatorProvider(useBootstrap4: true, paginationLabel: "Blog Post Pages")
        drop.addProvider(paginator)

        // Set up Leaf tag
        if let leaf = drop.view as? LeafRenderer {
            leaf.stem.register(Markdown())
        }

        let viewFactory = ViewFactory(drop: drop)

        // Set up the controllers
        let blogController = BlogController(drop: drop, pathCreator: pathCreator, viewFactory: viewFactory)
        let blogAdminController = BlogAdminController(drop: drop, pathCreator: pathCreator, viewFactory: viewFactory)

        // Add the routes
        blogController.addRoutes()
        blogAdminController.addRoutes()
    }

    public init(config: Config) throws {
        // WARNING TODO
        self.init(postsPerPage: 1, blogPath: nil)
    }

    /**
     Initialiser for SteamPress' Provider to add a blog to your Vapor App. You can pass it an optional `blogPath` to add the blog to. For instance, if you pass in "blog", your blog will be accessible at http://mysite.com/blog/, or if you pass in `nil` your blog will be added to the root of your site (i.e. http://mysite.com/)

     - Parameter postsPerPage: The number of posts to show per page on the main index page of the blog (integrates with Paginator)
     - Parameter blogPath: The path to add the blog too
     */
    public init(postsPerPage: Int, blogPath: String?) {
        self.postsPerPage = postsPerPage
        self.blogPath = blogPath
        self.pathCreator = BlogPathCreator(blogPath: self.blogPath)
    }

    public func afterInit(_: Vapor.Droplet) {}
    public func beforeRun(_: Vapor.Droplet) {}
}
