import SteamPress
import Vapor

struct TestWorld {
    
    static func create(path: String? = nil, title: String? = nil, description: String? = nil, copyright: String? = nil, imageURL: String? = nil) throws -> TestWorld {
        let repository = InMemoryRepository()
        let application = try TestDataBuilder.getSteamPressApp(repository: repository, path: path, title: title, description: description, copyright: copyright, imageURL: imageURL)
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
    func getResponse<T>(to path: String, method: HTTPMethod = .GET, headers: HTTPHeaders = .init(), decodeTo type: T.Type) throws -> T where T: Content {
        let response = try getResponse(to: path, method: method, headers: headers)
        return try response.content.decode(type).wait()
    }
    
    func getResponse(to path: String, method: HTTPMethod = .GET, headers: HTTPHeaders = .init()) throws -> Response {
        let responder = try context.app.make(Responder.self)
        let request = HTTPRequest(method: method, url: URL(string: path)!, headers: headers)
        let wrappedRequest = Request(http: request, using: context.app)
        return try responder.respond(to: wrappedRequest).wait()
    }
    
    func getResponseString(to path: String, headers: HTTPHeaders = .init()) throws -> String {
        let data = try getResponse(to: path, headers: headers).http.body.convertToHTTPBody().data
        return String(data: data!, encoding: .utf8)!
    }
}
