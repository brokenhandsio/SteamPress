import Vapor
import HTTP
import Routing
import LeafMarkdown

struct BlogController {
    
    // MARK: - Properties
    fileprivate let blogPostsPath = "posts"
    fileprivate let tagsPath = "tags"
    fileprivate let authorsPath = "authors"
    fileprivate let drop: Droplet
    fileprivate let pathCreator: BlogPathCreator
    fileprivate let viewFactory: ViewFactory
    fileprivate let postsPerPage: Int
    
    // MARK: - Initialiser
    init(drop: Droplet, pathCreator: BlogPathCreator, viewFactory: ViewFactory, postsPerPage: Int) {
        self.drop = drop
        self.pathCreator = pathCreator
        self.viewFactory = viewFactory
        self.postsPerPage = postsPerPage
    }
    
    // MARK: - Add routes
    func addRoutes() {
        drop.group(pathCreator.blogPath ?? "") { index in
            index.get(handler: indexHandler)
            index.get(blogPostsPath, String.self, handler: blogPostHandler)
            index.get(tagsPath, String.self, handler: tagViewHandler)
            index.get(authorsPath, String.self, handler: authorViewHandler)
        }
    }
    
    // MARK: - Route Handlers
    
    func indexHandler(request: Request) throws -> ResponseRepresentable {
        let tags = try BlogTag.all()
        var parameters: [String: Node] = [:]
        
        let paginatedBlogPosts = try BlogPost.query().sort("created", .descending).paginator(postsPerPage, request: request)

        if paginatedBlogPosts.totalPages ?? 0 > 0 {
            parameters["posts"] = try paginatedBlogPosts.makeNode(context: BlogPostContext.longSnippet)
        }
        
        if tags.count > 0 {
            parameters["tags"] = try tags.makeNode()
        }
        
        do {
            if let user = try request.auth.user() as? BlogUser {
                parameters["user"] = try user.makeNode()
            }
        }
        catch {}
        
        parameters["blogIndexPage"] = true
        
        if let disqusName = getDisqusName() {
            parameters["disqusName"] = disqusName.makeNode()
        }
        
        return try drop.view.make("blog/blog", parameters)
    }
    
    func blogPostHandler(request: Request, blogSlugUrl: String) throws -> ResponseRepresentable {
        guard let blogPost = try BlogPost.query().filter("slug_url", blogSlugUrl).first() else {
            throw Abort.notFound
        }
        
        guard let author = try blogPost.getAuthor() else {
            throw Abort.badRequest
        }
        
        var loggedInUser: BlogUser? = nil
        
        do {
            if let user = try request.auth.user() as? BlogUser {
                loggedInUser = user
            }
        }
        catch {}
        
        return try viewFactory.blogPostView(post: blogPost, author: author, user: loggedInUser, disqusName: getDisqusName())
    }
    
    func tagViewHandler(request: Request, tagName: String) throws -> ResponseRepresentable {
        guard let tag = try BlogTag.query().filter("name", tagName).first() else {
            throw Abort.notFound
        }
        let posts = try tag.blogPosts()
        
        var parameters: [String: Node] = [
            "tag": try tag.makeNode(),
            "tagPage": true.makeNode(),
            "posts": try posts.makeNode(context: BlogPostContext.shortSnippet)
        ]
        
        do {
            if let user = try request.auth.user() as? BlogUser {
                parameters["user"] = try user.makeNode()
            }
        }
        catch {}
        
        return try drop.view.make("blog/tag", parameters)
    }
    
    func authorViewHandler(request: Request, authorUsername: String) throws -> ResponseRepresentable {
        guard let author = try BlogUser.query().filter("username", authorUsername).first() else {
            throw Abort.notFound
        }
        
        let posts = try author.posts()
        
        return try viewFactory.createProfileView(user: author, isMyProfile: false, posts: posts)
    }
    
    private func getDisqusName() -> String? {
        return drop.config["disqus", "disqusName"]?.string
    }
    
}
