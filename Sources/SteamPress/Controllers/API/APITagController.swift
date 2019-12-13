import Vapor

struct APITagController: RouteCollection {
    func boot(router: Router) throws {
        let tagsRoute = router.grouped("tags")
        tagsRoute.get(use: allTagsHandler)
    }

    func allTagsHandler(_ req: Request) throws -> EventLoopFuture<[BlogTag]> {
        let repository = try req.make(BlogTagRepository.self)
        return repository.getAllTags(on: req)
    }
}
