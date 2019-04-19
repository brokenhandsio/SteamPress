import Vapor

public final class BlogAuthSessionsMiddleware: Middleware {
    public func respond(to request: Request, chainingTo next: Responder) throws -> EventLoopFuture<Response> {
        let future: Future<Void>
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

//public class BlogAuthMiddleware: Middleware {
//    private let turnstile: Turnstile
//    private let cookieName: String
//    private let cookieFactory: CookieFactory
//    
//    public typealias CookieFactory = (String) -> Cookie
//    
//    public init(
//        turnstile: Turnstile,
//        cookieName: String = defaultCookieName,
//        makeCookie cookieFactory: CookieFactory?
//        ) {
//        self.turnstile = turnstile
//        
//        self.cookieName = cookieName
//        self.cookieFactory = cookieFactory ?? { value in
//            return Cookie(
//                name: cookieName,
//                value: value,
//                expires: nil,
//                secure: false,
//                httpOnly: true
//            )
//        }
//    }
//    
//    public convenience init(
//        realm: Realm = AuthenticatorRealm(BlogUser.self),
//        cache: CacheProtocol = MemoryCache(),
//        cookieName: String = defaultCookieName,
//        makeCookie cookieFactory: CookieFactory? = nil
//        ) {
//        let session = CacheSessionManager(cache: cache, realm: realm)
//        let turnstile = Turnstile(sessionManager: session, realm: realm)
//        self.init(turnstile: turnstile, cookieName: cookieName, makeCookie: cookieFactory)
//    }
//    
//    public func respond(to request: Request, chainingTo next: Responder) throws -> Response {
//        request.storage["subject"] = Subject(
//            turnstile: turnstile,
//            sessionID: request.cookies[cookieName]
//        )
//        
//        let response = try next.respond(to: request)
//        let subject = request.storage["subject"] as? Subject
//        
//        // If we have a new session, set a new cookie
//        if let sid = subject?.authDetails?.sessionID, request.cookies[cookieName] != sid
//        {
//            var cookie = cookieFactory(sid)
//            cookie.name = cookieName
//            if request.storage["remember_me"] != nil {
//                cookie.expires = Date().addingTimeInterval(oneMonthTime)
//            }
//            else {
//                cookie.expires = nil
//            }
//            request.storage.removeValue(forKey: "remember_me")
//            response.cookies.insert(cookie)
//        } else if
//            subject?.authDetails?.sessionID == nil,
//            request.cookies[cookieName] != nil
//        {
//            // If we have a cookie but no session, delete it.
//            response.cookies[cookieName] = nil
//        }
//        
//        return response
//    }
//}
