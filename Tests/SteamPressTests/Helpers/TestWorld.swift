import SteamPress
import Vapor

struct TestWorld {
    
    static func create() throws -> TestWorld {
        let repository = InMemoryRepository()
        let application = try TestDataBuilder.getSteamPressApp(tagRepository: repository)
        let context = Context(app: application, repository: repository)
        return TestWorld(context: context)
    }
    
    let context: Context
    
    init(context: Context) {
        self.context = context
    }
    
    struct Context {
        let app: Application
        let repository: InMemoryRepository
    }
}

extension TestWorld {
    func getResponse<T>(to path: String, method: HTTPMethod = .GET, decodeTo type: T.Type) throws -> T where T: Content {
        let responder = try context.app.make(Responder.self)
        let request = HTTPRequest(method: method, url: URL(string: path)!)
        let wrappedRequest = Request(http: request, using: context.app)
        let response = try responder.respond(to: wrappedRequest).wait()
        return try response.content.decode(type).wait()
    }
}
