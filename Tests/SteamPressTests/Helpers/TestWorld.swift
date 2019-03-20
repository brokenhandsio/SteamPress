import SteamPress
import Vapor

struct TestWorld {
    
    static func create(path: String? = nil, feedInformation: FeedInformation = FeedInformation()) throws -> TestWorld {
        let repository = InMemoryRepository()
        let blogPresenter = CapturingBlogPresenter()
        let application = try TestDataBuilder.getSteamPressApp(repository: repository, path: path, feedInformation: feedInformation, blogPresenter: blogPresenter)
        let context = Context(app: application, repository: repository, blogPresenter: blogPresenter)
        return TestWorld(context: context)
    }
    
    let context: Context
    
    init(context: Context) {
        self.context = context
    }
    
    struct Context {
        let app: Application
        let repository: InMemoryRepository
        let blogPresenter: CapturingBlogPresenter
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
