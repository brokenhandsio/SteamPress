import Vapor
import Fluent

struct APITagController<DatabaseType>: RouteCollection where DatabaseType: QuerySupporting & SchemaSupporting & JoinSupporting {
    func boot(router: Router) throws {
        let tagsRoute = router.grouped("tags")
        tagsRoute.get(use: allTagsHandler)
    }

    func allTagsHandler(_ req: Request) throws -> Future<[BlogTag<DatabaseType>]> {
        return BlogTag<DatabaseType>.query(on: req).all()
    }
}
