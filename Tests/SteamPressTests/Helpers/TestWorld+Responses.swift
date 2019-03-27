import Vapor
@testable import SteamPress

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
    
    func getResponse<T: Content>(to path: String, method: HTTPMethod = .POST, body: T, loggedInUser: BlogUser? = nil) throws -> Response {
        var request = HTTPRequest(method: method, url: URL(string: path)!)
        
        if let user = loggedInUser {
            let loginData = LoginData(username: user.username, password: user.password)
            var loginPath = "/admin/login"
            if let path = context.path {
                loginPath = "/\(path)\(loginPath)"
            }
            let loginResponse = try getResponse(to: loginPath, method: .POST, body: loginData)
            let sessionCookie = loginResponse.http.cookies["steampress-session"]
            request.cookies["steampress-session"] = sessionCookie
        }
        
        let wrappedRequest = Request(http: request, using: context.app)
        try wrappedRequest.content.encode(body)
        return try getResponse(to: wrappedRequest)
    }
    
    func getResponse(to request: Request) throws -> Response {
        let responder = try context.app.make(Responder.self)
        return try responder.respond(to: request).wait()
    }
}

struct LoginData: Content {
    let username: String
    let password: String
}
