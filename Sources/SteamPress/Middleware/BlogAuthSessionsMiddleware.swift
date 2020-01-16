import Vapor

public final class BlogAuthSessionsMiddleware: Middleware {
    
    public init() {}
    
    public func respond(to request: Request, chainingTo next: Responder) throws -> EventLoopFuture<Response> {
        let future: EventLoopFuture<Void>
        if let userIDString = try request.session()["_BlogUserSession"], let userID = Int(userIDString) {
            let userRepository = try request.make(BlogUserRepository.self)
            future = userRepository.getUser(id: userID, on: request).flatMap { user in
                if let user = user {
                    try request.authenticate(user)
                }
                return .done(on: request)
            }
        } else {
            future = .done(on: request)
        }

        return future.flatMap {
            return try next.respond(to: request).map { response in
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
