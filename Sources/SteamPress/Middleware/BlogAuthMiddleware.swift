import HTTP
import Vapor

struct BlogAuthMiddleware: Middleware {
    
    let pathCreator: BlogPathCreator
    
    public func respond(to request: Request, chainingTo next: Responder) throws -> Response {
        do {
            guard let user = try request.auth.user() as? BlogUser else {
                throw Abort.badRequest
            }
            if user.resetPasswordRequired && request.uri.path != pathCreator.createPath(for: "admin/resetPassword") {
                return Response(redirect: pathCreator.createPath(for: "admin/resetPassword"))
            }
            
        } catch {
            return Response(redirect: pathCreator.createPath(for: "admin/login"))
        }
        return try next.respond(to: request)
    }
}
