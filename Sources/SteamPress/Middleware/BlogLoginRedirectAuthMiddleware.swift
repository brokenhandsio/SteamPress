import Vapor

struct BlogLoginRedirectAuthMiddleware: Middleware {

    let pathCreator: BlogPathCreator
    
    func respond(to request: Request, chainingTo next: Responder) -> EventLoopFuture<Response> {
        do {
            let user = try request.requireAuthenticated(BlogUser.self)
            let resetPasswordPath = pathCreator.createPath(for: "admin/resetPassword")
            var requestPath = request.url.string
            if !requestPath.hasSuffix("/") {
                requestPath = requestPath + "/"
            }
            if user.resetPasswordRequired && requestPath != resetPasswordPath {
                let redirect = request.redirect(to: resetPasswordPath)
                return request.eventLoop.future(redirect)
            }
        } catch {
            return request.eventLoop.future(request.redirect(to: pathCreator.createPath(for: "admin/login", query: "loginRequired")))
        }
        return next.respond(to: request)
    }
}
