import Vapor
import HTTP
import Routing
import LeafMarkdown

struct BlogController {
    
    // MARK: - Properties
    fileprivate let blogPostsPath = "posts"
    fileprivate let labelsPath = "labels"
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
            index.get(blogPostsPath, BlogPost.self, handler: blogPostHandler)
            index.get(labelsPath, BlogLabel.self, handler: labelViewHandler)
            index.get(authorsPath, BlogUser.self, handler: authorViewHandler)
        }
    }
    
    // MARK: - Route Handlers
    
    func indexHandler(request: Request) throws -> ResponseRepresentable {
        let labels = try BlogLabel.all()
        var parameters: [String: Node] = [:]
        
        let paginatedBlogPosts = try BlogPost.query().sort("created", .descending).paginator(1, request: request)

        if paginatedBlogPosts.totalPages ?? 0 > 0 {
            var paginatedNode = try paginatedBlogPosts.makeNode(context: BlogPostAllInfo())
            var postsNode = [Node]()
            for node in (paginatedNode["data"]?.array as? [Node])! {
                if let id = node["id"]?.string {
                    let post = try BlogPost.query().filter("id", id).first()
                    if let foundPost = post {
                        postsNode.append(try foundPost.makeNode(context: BlogPostAllInfo()))
                    }
                }
            }
            paginatedNode["data"] = try postsNode.makeNode()
            parameters["posts"] = paginatedNode
        }
        
        if labels.count > 0 {
            parameters["labels"] = try labels.makeNode()
        }
        
        do {
            if let user = try request.auth.user() as? BlogUser {
                parameters["user"] = try user.makeNode(context: BlogUserPasswordHidden())
            }
        }
        catch {}
        
        parameters["blogIndexPage"] = true
        
        return try drop.view.make("blog/blog", parameters)
    }
    
    func blogPostHandler(request: Request, blogPost: BlogPost) throws -> ResponseRepresentable {
        guard let author = try blogPost.getAuthor() else {
            throw Abort.badRequest
        }
                
        var parameters = try Node(node: [
                "post": try blogPost.makeNode(context: BlogPostAllInfo()),
                "author": try author.makeNode(context: BlogUserPasswordHidden()),
                "blogPostPage": true.makeNode()
            ])
        
        do {
            if let user = try request.auth.user() as? BlogUser {
                parameters["user"] = try user.makeNode(context: BlogUserPasswordHidden())
            }
        }
        catch {}
        
        return try drop.view.make("blog/blogpost", parameters)
    }
    
    func labelViewHandler(request: Request, label: BlogLabel) throws -> ResponseRepresentable {
        let posts = try label.blogPosts()
        
        var parameters: [String: Node] = [
            "label": try label.makeNode(),
            "labelPage": true.makeNode(),
            "posts": try posts.makeNode(context: BlogPostAllInfo())
        ]
        
        do {
            if let user = try request.auth.user() as? BlogUser {
                parameters["user"] = try user.makeNode(context: BlogUserPasswordHidden())
            }
        }
        catch {}
        
        return try drop.view.make("blog/label", parameters)
    }
    
    func authorViewHandler(request: Request, author: BlogUser) throws -> ResponseRepresentable {
        return try viewFactory.createProfileView(user: author, isMyProfile: false)
    }
    
}
