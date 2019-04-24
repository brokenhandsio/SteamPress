import Vapor

struct BlogLoginRedirectAuthMiddleware: Middleware {

    let pathCreator: BlogPathCreator
    
    func respond(to request: Request, chainingTo next: Responder) throws -> EventLoopFuture<Response> {
        do {
            let user = try request.requireAuthenticated(BlogUser.self)
            let resetPasswordPath = pathCreator.createPath(for: "admin/resetPassword")
            var requestPath = request.http.urlString
            if !requestPath.hasSuffix("/") {
                requestPath = requestPath + "/"
            }
            if user.resetPasswordRequired && requestPath != resetPasswordPath {
                let redirect = request.redirect(to: resetPasswordPath)
                return request.future(redirect)
            }
        } catch {
            return request.future(request.redirect(to: pathCreator.createPath(for: "admin/login", query: "loginRequired")))
        }
        return try next.respond(to: request)
    }
}

