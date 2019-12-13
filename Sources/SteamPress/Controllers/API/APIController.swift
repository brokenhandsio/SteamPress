import Vapor

struct APIController: RouteCollection {
    func boot(router: Router) throws {
        let apiRoutes = router.grouped("api")

        let apiTagController = APITagController()
        try apiRoutes.register(collection: apiTagController)
    }
}
