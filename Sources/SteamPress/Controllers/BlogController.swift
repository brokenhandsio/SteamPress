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
        let allposts = try BlogPost.all()
        print("We have \(allposts.count) posts")
        let paginatedBlogPosts = try BlogPost.query().sort("created", .descending).paginator(postsPerPage, request: request)

        return try viewFactory.blogIndexView(paginatedPosts: paginatedBlogPosts, tags: tags, loggedInUser: getLoggedInUser(in: request), disqusName: getDisqusName())
    }
    
    func blogPostHandler(request: Request, blogSlugUrl: String) throws -> ResponseRepresentable {
        guard let blogPost = try BlogPost.query().filter("slug_url", blogSlugUrl).first() else {
            throw Abort.notFound
        }
        
        guard let author = try blogPost.getAuthor() else {
            throw Abort.badRequest
        }
        
        return try viewFactory.blogPostView(post: blogPost, author: author, user: getLoggedInUser(in: request), disqusName: getDisqusName())
    }
    
    func tagViewHandler(request: Request, tagName: String) throws -> ResponseRepresentable {
        guard let tag = try BlogTag.query().filter("name", tagName).first() else {
            throw Abort.notFound
        }
        let posts = try tag.blogPosts()
        
        return try viewFactory.tagView(tag: tag, posts: posts, user: getLoggedInUser(in: request), disqusName: getDisqusName())
    }
    
    func authorViewHandler(request: Request, authorUsername: String) throws -> ResponseRepresentable {
        guard let author = try BlogUser.query().filter("username", authorUsername).first() else {
            throw Abort.notFound
        }
        
        let posts = try author.posts()
        
        return try viewFactory.createProfileView(author: author, isMyProfile: false, posts: posts, loggedInUser: getLoggedInUser(in: request), disqusName: getDisqusName())
    }
    
    private func getLoggedInUser(in request: Request) -> BlogUser? {
        var loggedInUser: BlogUser? = nil
        
        do {
            if let user = try request.auth.user() as? BlogUser {
                loggedInUser = user
            }
        }
        catch {}
        
        return loggedInUser
    }
    
    private func getDisqusName() -> String? {
        return drop.config["disqus", "disqusName"]?.string
    }
    
}
