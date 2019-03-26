//import HTTP
import Vapor

struct BlogLoginRedirectAuthMiddleware: Middleware {

    let pathCreator: BlogPathCreator
    
    func respond(to request: Request, chainingTo next: Responder) throws -> EventLoopFuture<Response> {
        do {
            let user = try request.requireAuthenticated(BlogUser.self)
            
        } catch {
            return request.future(request.redirect(to: pathCreator.createPath(for: "admin/login", query: "loginRequired")))
        }
        return try next.respond(to: request)
    }

//    public func respond(to request: Request, chainingTo next: Responder) throws -> Response {
//        do {
//            let user = try request.user()
//            if user.resetPasswordRequired && request.uri.path != pathCreator.createPath(for: "admin/resetPassword") {
//                return Response(redirect: pathCreator.createPath(for: "admin/resetPassword"))
//            }
//
//        } catch {
//            return Response(redirect: pathCreator.createPath(for: "admin/login", query: "loginRequired"))
//        }
//        return try next.respond(to: request)
//    }
}

