import Vapor
import Fluent
import LeafMarkdown
import Auth

/**
    A Blog engine for Vapor. Simply initialise an instance of `SteamPress` and it will do the rest for you!
    You will need to ensure that the views it is expecting are available though. See https://github.com/brokenhandsio/SteamPress for full documentation.
 */
public struct SteamPress {
    
    fileprivate let blogPath: String?
    fileprivate let blogController: BlogController
    fileprivate let blogAdminController: BlogAdminController
    
    /**
        Initialiser for SteamPress to add a blog to your Vapor App. You can pass it an optional `blogPath` to add the blog to. For instance, if you pass in "blog", your blog will be accessible at http://mysite.com/blog/, or if you pass in `nil` your blog will be added to the root of your site (i.e. http://mysite.com/)
     
        - Parameter drop: The droplet to add the blog too
        - Parameter blogPath: The path to add the blog too
     
     */
    public init(drop: Droplet, blogPath: String? = nil) {
        self.blogPath = blogPath
        
        // Database preperations
        drop.preparations.append(BlogPost.self)
        drop.preparations.append(BlogUser.self)
        drop.preparations.append(BlogLabel.self)
        drop.preparations.append(Pivot<BlogPost, BlogLabel>.self)
        
        // Middleware
        let authMiddleware = AuthMiddleware<BlogUser>()
        drop.middleware.append(authMiddleware)
        
        // Set up Leaf tag
        if let leaf = drop.view as? LeafRenderer {
            leaf.stem.register(Markdown())
        }
        
        let pathCreator = BlogPathCreator(blogPath: blogPath)
        
        // Set up the controllers
        blogController = BlogController(pathCreator: pathCreator)
        blogAdminController = BlogAdminController(pathCreator: pathCreator)
        
        // Add the routes
        blogController.addRoutes(drop: drop)
        blogAdminController.addRoutes(drop: drop)
    }
}
