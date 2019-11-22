import Vapor

public struct BlogRememberMeMiddleware: Middleware, ServiceType {

    public static func makeService(for container: Container) throws -> BlogRememberMeMiddleware {
        return .init()
    }

    public func respond(to request: Request, chainingTo next: Responder) throws -> EventLoopFuture<Response> {
        return try next.respond(to: request).map { response in
            if let rememberMe = try request.session()["SteamPressRememberMe"], rememberMe == "YES" {
                if var steampressCookie = response.http.cookies["steampress-session"] {
                    let oneYear: TimeInterval = 60 * 60 * 24 * 365
                    steampressCookie.expires = Date().addingTimeInterval(oneYear)
                    response.http.cookies["steampress-session"] = steampressCookie
                    try request.session()["SteamPressRememberMe"] = nil
                }
            }
            return response
        }
    }
}
