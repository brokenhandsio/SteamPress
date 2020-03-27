import Vapor

public final class BlogAuthSessionsMiddleware: Middleware {
    
    public init() {}
    
    public func respond(to request: Request, chainingTo next: Responder) -> EventLoopFuture<Response> {
        let future: EventLoopFuture<Void>
        if let userIDString = try request.session()["_BlogUserSession"], let userID = Int(userIDString) {
            future = request.blogUserRepository.getUser(id: userID).flatMap { user in
                if let user = user {
                    request.auth.login(user)
                }
                return request.eventLoop.future()
            }
        } else {
            future = request.eventLoop.future()
        }

        return future.flatMap {
            return next.respond(to: request).flatMapThrowing { response in
                if let user = request.auth.get(BlogUser.self) {
                    try user.authenticateSession(on: request)
                } else {
                    try request.unauthenticateBlogUserSession()
                }
                return response
            }
        }
    }
}
