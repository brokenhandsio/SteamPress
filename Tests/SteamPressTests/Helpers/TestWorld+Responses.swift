import Vapor

extension TestWorld {
    func getResponse<T>(to path: String, method: HTTPMethod = .GET, headers: HTTPHeaders = .init(), decodeTo type: T.Type) throws -> T where T: Content {
        let response = try getResponse(to: path, method: method, headers: headers)
        return try response.content.decode(type).wait()
    }
    
    func getResponse(to path: String, method: HTTPMethod = .GET, headers: HTTPHeaders = .init()) throws -> Response {
        let request = HTTPRequest(method: method, url: URL(string: path)!, headers: headers)
        let wrappedRequest = Request(http: request, using: context.app)
        return try getResponse(to: wrappedRequest)
    }
    
    func getResponseString(to path: String, headers: HTTPHeaders = .init()) throws -> String {
        let data = try getResponse(to: path, headers: headers).http.body.convertToHTTPBody().data
        return String(data: data!, encoding: .utf8)!
    }
    
    func getResponse<T: Content>(to path: String, method: HTTPMethod = .POST, body: T) throws -> Response {
        let request = HTTPRequest(method: method, url: URL(string: path)!)
        let wrappedRequest = Request(http: request, using: context.app)
        try wrappedRequest.content.encode(body)
        return try getResponse(to: wrappedRequest)
    }
    
    func getResponse(to request: Request) throws -> Response {
        let responder = try context.app.make(Responder.self)
        return try responder.respond(to: request).wait()
    }
}
