import SteamPress
import Vapor

struct TestWorld {
    
    static func create(title: String? = nil, description: String? = nil, copyright: String? = nil) throws -> TestWorld {
        let repository = InMemoryRepository()
        let application = try TestDataBuilder.getSteamPressApp(tagRepository: repository, title: title, description: description, copyright: copyright)
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
        let response = try getResponse(to: path, method: method)
        return try response.content.decode(type).wait()
    }
    
    func getResponse(to path: String, method: HTTPMethod = .GET) throws -> Response {
        let responder = try context.app.make(Responder.self)
        let request = HTTPRequest(method: method, url: URL(string: path)!)
        let wrappedRequest = Request(http: request, using: context.app)
        return try responder.respond(to: wrappedRequest).wait()
    }
    
    func getResponseString(to path: String) throws -> String {
        let data = try getResponse(to: path).http.body.convertToHTTPBody().data
        return String(data: data!, encoding: .utf8)!
    }
}
