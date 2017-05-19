import Vapor
import HTTP
import Routing
import MarkdownProvider

struct BlogController {

    // MARK: - Properties
    fileprivate let blogPostsPath = "posts"
    fileprivate let tagsPath = "tags"
    fileprivate let authorsPath = "authors"
    fileprivate let apiPath = "api"
    fileprivate let drop: Droplet
    fileprivate let pathCreator: BlogPathCreator
    fileprivate let viewFactory: ViewFactory
    fileprivate let enableAuthorsPages: Bool
    fileprivate let enableTagsPages: Bool

    // MARK: - Initialiser
    init(drop: Droplet, pathCreator: BlogPathCreator, viewFactory: ViewFactory, enableAuthorsPages: Bool, enableTagsPages: Bool) {
        self.drop = drop
        self.pathCreator = pathCreator
        self.viewFactory = viewFactory
        self.enableAuthorsPages = enableAuthorsPages
        self.enableTagsPages = enableTagsPages
    }

    // MARK: - Add routes
    func addRoutes() {
        drop.group(pathCreator.blogPath ?? "") { index in
            index.get(handler: indexHandler)
            index.get(blogPostsPath, String.parameter, handler: blogPostHandler)
            index.get(apiPath, tagsPath, handler: tagApiHandler)
            index.get(blogPostsPath, handler: blogPostIndexRedirectHandler)

            if (enableAuthorsPages) {
                index.get(authorsPath, String.parameter, handler: authorViewHandler)
                index.get(authorsPath, handler: allAuthorsViewHandler)
            }

            if (enableTagsPages) {
                index.get(tagsPath, String.parameter, handler: tagViewHandler)
                index.get(tagsPath, handler: allTagsViewHandler)
            }
        }
    }

    // MARK: - Route Handlers

    func indexHandler(request: Request) throws -> ResponseRepresentable {
        let tags = try BlogTag.all()
        let authors = try BlogUser.all()
        let paginatedBlogPosts = try BlogPost.makeQuery().filter("published", true).sort("created", .descending).paginate(for: request)

        return try viewFactory.blogIndexView(uri: request.uri, paginatedPosts: paginatedBlogPosts, tags: tags, authors: authors, loggedInUser: getLoggedInUser(in: request))
    }

    func blogPostIndexRedirectHandler(request: Request) throws -> ResponseRepresentable {
        return Response(redirect: pathCreator.createPath(for: pathCreator.blogPath), permanently: true)
    }

    func blogPostHandler(request: Request) throws -> ResponseRepresentable {
        let blogSlugUrl: String = try request.parameters.next()
        guard let blogPost = try BlogPost.makeQuery().filter("slug_url", blogSlugUrl).first() else {
            throw Abort.notFound
        }

        guard let author = try blogPost.postAuthor.get() else {
            throw Abort.badRequest
        }

        return try viewFactory.blogPostView(uri: request.uri, post: blogPost, author: author, user: getLoggedInUser(in: request))
    }

    func tagViewHandler(request: Request) throws -> ResponseRepresentable {
        let tagName: String = try request.parameters.next()
        
        guard let decodedTagName = tagName.removingPercentEncoding else {
            throw Abort.badRequest
        }

        guard let tag = try BlogTag.makeQuery().filter("name", decodedTagName).first() else {
            throw Abort.notFound
        }

        let paginatedBlogPosts = try tag.sortedPosts().paginate(for: request)

        return try viewFactory.tagView(uri: request.uri, tag: tag, paginatedPosts: paginatedBlogPosts, user: getLoggedInUser(in: request))
    }

    func authorViewHandler(request: Request) throws -> ResponseRepresentable {
        let authorUsername: String = try request.parameters.next()
        
        guard let author = try BlogUser.makeQuery().filter("username", authorUsername).first() else {
            throw Abort.notFound
        }

        let posts = try author.sortedPosts().paginate(for: request)

        return try viewFactory.createProfileView(uri: request.uri, author: author, isMyProfile: author.username == getLoggedInUser(in: request)?.username, paginatedPosts: posts, loggedInUser: getLoggedInUser(in: request))
    }

    func allTagsViewHandler(request: Request) throws -> ResponseRepresentable {
        return try viewFactory.allTagsView(uri: request.uri, allTags: BlogTag.all(), user: getLoggedInUser(in: request))
    }

    func allAuthorsViewHandler(request: Request) throws -> ResponseRepresentable {
        return try viewFactory.allAuthorsView(uri: request.uri, allAuthors: BlogUser.all(), user: getLoggedInUser(in: request))
    }

    func tagApiHandler(request: Request) throws -> ResponseRepresentable {
        return try JSON(node: BlogTag.all().makeNode(in: nil))
    }

    private func getLoggedInUser(in request: Request) -> BlogUser? {
        var loggedInUser: BlogUser? = nil

        do {
            loggedInUser = try request.user()
        }
        catch {}

        return loggedInUser
    }
}
