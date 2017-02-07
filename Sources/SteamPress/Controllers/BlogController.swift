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
    
    // MARK: - Initialiser
    init(drop: Droplet, pathCreator: BlogPathCreator, viewFactory: ViewFactory) {
        self.drop = drop
        self.pathCreator = pathCreator
        self.viewFactory = viewFactory
    }
    
    // MARK: - Add routes
    func addRoutes() {
        drop.group(pathCreator.blogPath ?? "") { index in
            index.get(handler: indexHandler)
            index.get(blogPostsPath, String.self, handler: blogPostHandler)
            index.get(tagsPath, BlogTag.self, handler: tagViewHandler)
            index.get(authorsPath, BlogUser.self, handler: authorViewHandler)
        }
    }
    
    // MARK: - Route Handlers
    
    func indexHandler(request: Request) throws -> ResponseRepresentable {
        let tags = try BlogTag.all()
        var parameters: [String: Node] = [:]
        
        let paginatedBlogPosts = try BlogPost.query().sort("created", .descending).paginator(10, request: request)

        if paginatedBlogPosts.totalPages ?? 0 > 0 {
            var paginatedNode = try paginatedBlogPosts.makeNode(context: BlogPostContext.longSnippet)
            var postsNode = [Node]()
            for node in (paginatedNode["data"]?.array as? [Node])! {
                if let id = node["id"]?.string {
                    let post = try BlogPost.query().filter("id", id).first()
                    if let foundPost = post {
                        postsNode.append(try foundPost.makeNode(context: BlogPostContext.longSnippet))
                    }
                }
            }
            paginatedNode["data"] = try postsNode.makeNode()
            parameters["posts"] = paginatedNode
        }
        
        if tags.count > 0 {
            parameters["tags"] = try tags.makeNode()
        }
        
        do {
            if let user = try request.auth.user() as? BlogUser {
                parameters["user"] = try user.makeNode(context: BlogUserContext.passwordHidden)
            }
        }
        catch {}
        
        parameters["blogIndexPage"] = true
        
        return try drop.view.make("blog/blog", parameters)
    }
    
    func blogPostHandler(request: Request, blogSlugUrl: String) throws -> ResponseRepresentable {
        guard let blogPost = try BlogPost.query().filter("slug_url", blogSlugUrl).first() else {
            throw Abort.notFound
        }
        
        guard let author = try blogPost.getAuthor() else {
            throw Abort.badRequest
        }
                
        var parameters = try Node(node: [
                "post": try blogPost.makeNode(context: BlogPostContext.all),
                "author": try author.makeNode(context: BlogUserContext.passwordHidden),
                "blogPostPage": true.makeNode()
            ])
        
        do {
            if let user = try request.auth.user() as? BlogUser {
                parameters["user"] = try user.makeNode(context: BlogUserContext.passwordHidden)
            }
        }
        catch {}
        
        return try drop.view.make("blog/blogpost", parameters)
    }
    
    func tagViewHandler(request: Request, tag: BlogTag) throws -> ResponseRepresentable {
        let posts = try tag.blogPosts()
        
        var parameters: [String: Node] = [
            "tag": try tag.makeNode(),
            "tagPage": true.makeNode(),
            "posts": try posts.makeNode(context: BlogPostContext.shortSnippet)
        ]
        
        do {
            if let user = try request.auth.user() as? BlogUser {
                parameters["user"] = try user.makeNode(context: BlogUserContext.passwordHidden)
            }
        }
        catch {}
        
        return try drop.view.make("blog/tag", parameters)
    }
    
    func authorViewHandler(request: Request, author: BlogUser) throws -> ResponseRepresentable {
        return try viewFactory.createProfileView(user: author, isMyProfile: false)
    }
    
}
