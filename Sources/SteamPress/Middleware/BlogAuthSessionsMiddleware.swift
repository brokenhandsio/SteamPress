import Vapor

public final class BlogAuthSessionsMiddleware: Middleware {
    
    public init() {}
    
    public func respond(to request: Request, chainingTo next: Responder) -> EventLoopFuture<Response> {
        let future: EventLoopFuture<Void>
        if let userIDString = try request.session()["_BlogUserSession"], let userID = Int(userIDString) {
            future = request.blogUserRepository.getUser(id: userID).flatMap { user in
                if let user = user {
                    try request.authenticate(user)
                }
                return .done(on: request)
            }
        } else {
            future = .done(on: request.eventLoop)
        }

        return future.flatMap {
            return next.respond(to: request).map { response in
                if let user = try request.authenticated(BlogUser.self) {
                    try user.authenticateSession(on: request)
                } else {
                    try request.unauthenticateBlogUserSession()
                }
                return response
            }
        }
    }
}
