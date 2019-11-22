import Vapor
@testable import SteamPress

extension TestWorld {
    func getResponse<T>(to path: String, method: HTTPMethod = .GET, headers: HTTPHeaders = .init(), decodeTo type: T.Type) throws -> T where T: Content {
        let response = try getResponse(to: path, method: method, headers: headers)
        return try response.content.decode(type).wait()
    }

    func getResponseString(to path: String, headers: HTTPHeaders = .init()) throws -> String {
        let data = try getResponse(to: path, headers: headers).http.body.convertToHTTPBody().data
        return String(data: data!, encoding: .utf8)!
    }

    func getResponse<T: Content>(to path: String, method: HTTPMethod = .POST, body: T, loggedInUser: BlogUser? = nil, passwordToLoginWith: String? = nil, headers: HTTPHeaders = .init()) throws -> Response {
        let request = try setupRequest(to: path, method: method, loggedInUser: loggedInUser, passwordToLoginWith: passwordToLoginWith, headers: headers)
        try request.content.encode(body)
        return try getResponse(to: request)
    }

    func getResponse(to path: String, method: HTTPMethod = .GET, headers: HTTPHeaders = .init(), loggedInUser: BlogUser? = nil) throws -> Response {
        let request = try setupRequest(to: path, method: method, loggedInUser: loggedInUser, passwordToLoginWith: nil, headers: headers)
        return try getResponse(to: request)
    }

    func setupRequest(to path: String, method: HTTPMethod = .POST, loggedInUser: BlogUser? = nil, passwordToLoginWith: String? = nil, headers: HTTPHeaders = .init()) throws -> Request {
        var request = HTTPRequest(method: method, url: URL(string: path)!, headers: headers)
        request.cookies["steampress-session"] = try setLoginCookie(for: loggedInUser, password: passwordToLoginWith)

        return Request(http: request, using: context.app)
    }

    func setLoginCookie(for user: BlogUser?, password: String? = nil) throws -> HTTPCookieValue? {
        if let user = user {
            let loginData = LoginData(username: user.username, password: password ?? user.password)
            var loginPath = "/admin/login"
            if let path = context.path {
                loginPath = "/\(path)\(loginPath)"
            }
            let loginResponse = try getResponse(to: loginPath, method: .POST, body: loginData)
            let sessionCookie = loginResponse.http.cookies["steampress-session"]
            return sessionCookie
        } else {
            return nil
        }
    }

    func getResponse(to request: Request) throws -> Response {
        let responder = try context.app.make(Responder.self)
        return try responder.respond(to: request).wait()
    }
}
