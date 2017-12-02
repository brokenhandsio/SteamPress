import Vapor
import HTTP
import Routing
import MarkdownProvider

struct BlogTagsController {

    fileprivate let drop: Droplet
    fileprivate let pathCreator: BlogPathCreator
    fileprivate let viewFactory: TagLeafViewFactory
    fileprivate let apiPath = "api"

    fileprivate let tagsPath = "tags"
    fileprivate let enableTagsPages: Bool

    // MARK: - Initialiser
    init(drop: Droplet, pathCreator: BlogPathCreator, viewFactory: TagLeafViewFactory, enableTagsPages: Bool) {
        self.drop = drop
        self.pathCreator = pathCreator
        self.viewFactory = viewFactory
        self.enableTagsPages = enableTagsPages
    }

    // MARK: - Add routes
    func addRoutes() {
        drop.group(pathCreator.blogPath ?? "") { index in

            index.get(apiPath, tagsPath, handler: tagApiHandler)

            if enableTagsPages {
                index.get(tagsPath, String.parameter, handler: tagViewHandler)
                index.get(tagsPath, handler: allTagsViewHandler)
            }
        }
    }

    func tagViewHandler(request: Request) throws -> ResponseRepresentable {
        let tagName: String = try request.parameters.next()

        guard let decodedTagName = tagName.removingPercentEncoding else {
            throw Abort.badRequest
        }

        guard let tag = try BlogTag.makeQuery().filter(BlogTag.Properties.name, decodedTagName).first() else {
            throw Abort.notFound
        }

        let paginatedBlogPosts = try tag.sortedPosts().paginate(for: request)

        return try viewFactory.tagView(uri: request.getURIWithHTTPSIfReverseProxy(), tag: tag, paginatedPosts: paginatedBlogPosts, user: try? request.user())
    }

    func allTagsViewHandler(request: Request) throws -> ResponseRepresentable {
        return try viewFactory.allTagsView(uri: request.getURIWithHTTPSIfReverseProxy(), allTags: BlogTag.all(), user: try? request.user())
    }

    func tagApiHandler(request: Request) throws -> ResponseRepresentable {
        return try JSON(node: BlogTag.all().makeNode(in: nil))
    }
}
