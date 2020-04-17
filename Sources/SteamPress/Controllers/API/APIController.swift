import Vapor

struct APIController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let apiRoutes = routes.grouped("api")

        let apiTagController = APITagController()
        try apiRoutes.register(collection: apiTagController)
    }
}
