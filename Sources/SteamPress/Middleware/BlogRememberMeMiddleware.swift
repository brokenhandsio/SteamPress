import Vapor

public struct BlogRememberMeMiddleware: Middleware {

    public func respond(to request: Request, chainingTo next: Responder) -> EventLoopFuture<Response> {
        return next.respond(to: request).map { response in
            if let rememberMe = request.session.data["SteamPressRememberMe"], rememberMe == "YES" {
                if var steampressCookie = response.cookies["steampress-session"] {
                    let oneYear: TimeInterval = 60 * 60 * 24 * 365
                    steampressCookie.expires = Date().addingTimeInterval(oneYear)
                    response.cookies["steampress-session"] = steampressCookie
                    request.session.data["SteamPressRememberMe"] = nil
                }
            }
            return response
        }
    }
}
