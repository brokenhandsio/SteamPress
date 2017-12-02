import Vapor
import HTTP
import Routing
import MarkdownProvider

struct BlogLinksController {

    fileprivate let drop: Droplet
    fileprivate let pathCreator: BlogPathCreator
    fileprivate let viewFactory: ViewFactory
    fileprivate let apiPath = "api"
    fileprivate let linksPath = "links"
    fileprivate let enableLinksPages: Bool

    // MARK: - Initialiser
    init(drop: Droplet, pathCreator: BlogPathCreator, viewFactory: ViewFactory, enableLinksPages: Bool) {
        self.drop = drop
        self.pathCreator = pathCreator
        self.viewFactory = viewFactory
        self.enableLinksPages = enableLinksPages
    }

    // MARK: - Add routes
    func addRoutes() {
        drop.group(pathCreator.blogPath ?? "") { index in

            index.get(apiPath, linksPath, handler: linkApiHandler)

            if enableLinksPages {
                index.get(linksPath, handler: allLinksViewHandler)
            }
        }

        self.addAdminRoutes()
    }

    private func addAdminRoutes() {
        let router = drop.grouped(pathCreator.blogPath ?? "", "admin")
        let protect = BlogLoginRedirectAuthMiddleware(pathCreator: pathCreator)
        let routerSecure = router.grouped(protect)

        routerSecure.get("createLink", handler: createLinkHandler)
        routerSecure.post("createLink", handler: createLinkPostHandler)
        routerSecure.get("links", BlogLink.parameter, "delete", handler: deleteLinkHandler)
        routerSecure.get("links", BlogLink.parameter, "edit", handler: editLinkHandler)
        routerSecure.post("links", BlogLink.parameter, "edit", handler: editLinkPostHandler)
    }

    func linkApiHandler(request: Request) throws -> ResponseRepresentable {
        return try JSON(node: BlogLink.all().makeNode(in: nil))
    }

    func allLinksViewHandler(request: Request) throws -> ResponseRepresentable {
        return try viewFactory.allLinksView(uri: request.getURIWithHTTPSIfReverseProxy(), allLinks: BlogLink.all())
    }

    func createLinkHandler(_ request: Request) throws -> ResponseRepresentable {
        return try viewFactory.createLinkView(isEditing: false, linkToEdit: nil)
    }

    func createLinkPostHandler(_ request: Request) throws -> ResponseRepresentable {
        let name = request.data["inputName"]?.string
        let href = request.data["inputHref"]?.string

        if name == nil && href == nil {
            throw Abort.badRequest
        }

        let newLink = BlogLink(name: name!, href: href!)
        try newLink.save()

        return Response(redirect: pathCreator.createPath(for: "links"))
    }

    func editLinkHandler(_ request: Request) throws -> ResponseRepresentable {
        let link = try request.parameters.next(BlogLink.self)

        return try viewFactory.createLinkView(isEditing: true, linkToEdit: link)
    }

    func editLinkPostHandler(_ request: Request) throws -> ResponseRepresentable {
        let link = try request.parameters.next(BlogLink.self)

        let name = request.data["inputName"]?.string
        let href = request.data["inputHref"]?.string

        if name == nil && href == nil {
            throw Abort.badRequest
        }

        link.name = name!
        link.href = href!

        try link.save()

        return Response(redirect: pathCreator.createPath(for: "admin"))
    }

    func deleteLinkHandler(_ request: Request) throws -> ResponseRepresentable {
        let link = try request.parameters.next(BlogLink.self)
        try link.delete()
        return Response(redirect: pathCreator.createPath(for: "admin"))
    }
}
