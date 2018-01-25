import Vapor
import Fluent

struct APIController<DatabaseType>: RouteCollection where DatabaseType: QuerySupporting & SchemaSupporting & JoinSupporting {
    func boot(router: Router) throws {
        let apiRoutes = router.grouped("api")

        let apiTagController = APITagController<DatabaseType>()
        try apiRoutes.register(collection: apiTagController)
    }
}
