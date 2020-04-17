import Vapor
@testable import SteamPress

extension TestWorld {
    func getResponse<T>(to path: String, method: HTTPMethod = .GET, headers: HTTPHeaders = .init(), decodeTo type: T.Type) throws -> T where T: Content {
        let response = try getResponse(to: path, method: method, headers: headers)
        return try response.content.decode(type)
    }

    func getResponseString(to path: String, headers: HTTPHeaders = .init()) throws -> String {
        return try getResponse(to: path, headers: headers).body.string!
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
        let request = Request(application: context.app, method: method, url: URI(path: path), headers: headers, on: context.eventLoopGroup.next())
        request.cookies["steampress-session"] = try setLoginCookie(for: loggedInUser, password: passwordToLoginWith)
        return request
    }

    func setLoginCookie(for user: BlogUser?, password: String? = nil) throws -> HTTPCookies.Value? {
        if let user = user {
            let loginData = LoginData(username: user.username, password: password ?? user.password)
            var loginPath = "/admin/login"
            if let path = context.path {
                loginPath = "/\(path)\(loginPath)"
            }
            let loginResponse = try getResponse(to: loginPath, method: .POST, body: loginData)
            let sessionCookie = loginResponse.cookies["steampress-session"]
            return sessionCookie
        } else {
            return nil
        }
    }

    func getResponse(to request: Request) throws -> Response {
        return try context.app.responder.respond(to: request).wait()
    }
}
