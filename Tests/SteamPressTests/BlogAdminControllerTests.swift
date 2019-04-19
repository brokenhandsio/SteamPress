//import XCTest
//@testable import Vapor
//@testable import SteamPress
//import HTTP
//import Fluent
////import Sessions
////import Cookies
////import AuthProvider
//
//class BlogAdminControllerTests: XCTestCase {
//    
//    // MARK: - Overrides
//    
//    override func setUp() {
//        BlogUser.passwordHasher = FakePasswordHasher()
//        var config = Config([:])
//        let sessionsMiddleware = SessionsMiddleware(try! config.resolveSessions(), cookieName: SteamPress.Provider.cookieName, cookieFactory: Provider.createCookieFactory(for: .production))
//        config.addConfigurable(middleware: { (config) -> (SessionsMiddleware) in
//            return sessionsMiddleware
//        }, name: "steampress-sessions")
//        
//        let persistMiddleware = PersistMiddleware(BlogUser.self)
//        config.addConfigurable(middleware: { (config) -> (PersistMiddleware<BlogUser>) in
//            return persistMiddleware
//        }, name: "blog-persist")
//        try! config.set("droplet.middleware", ["error", "steampress-sessions", "blog-persist"])
//        try! config.set("steampress.postsPerPage", 5)
//        try! config.set("fluent.driver", "memory")
//        
//        try! config.addProvider(SteamPress.Provider.self)
//        try! config.addProvider(FluentProvider.Provider.self)
//        
//        drop = try! Droplet(config)
//        capturingViewFactory = CapturingViewFactory()
//        let adminController = BlogAdminController(drop: drop, pathCreator: BlogPathCreator(blogPath: "blog"), viewFactory: capturingViewFactory)
//        adminController.addRoutes()
//        let adminUser = try! BlogUser.all().first
//        
//        guard let createdUser = adminUser else {
//            XCTFail()
//            return
//        }
//        
//        user = createdUser
//        user.resetPasswordRequired = false
//        try! user.save()
//    }

//    // MARK: - Delete tests
//    
//    

//
//    // MARK: - Create User Tests
//    
//    
//    func testAdminPageGetsLoggedInUser() throws {
//        let request = try createLoggedInRequest(method: .get, path: "", for: user)
//        _ = try drop.respond(to: request)
//        
//        XCTAssertEqual(user.name, capturingViewFactory.adminUser?.name)
//    }
//    
//    func testCreatePostPageGetsLoggedInUser() throws {
//        let request = try createLoggedInRequest(method: .get, path: "createPost", for: user)
//        _ = try drop.respond(to: request)
//        
//        XCTAssertEqual(user.name, capturingViewFactory.createBlogPostUser?.name)
//    }
//    
//    func testEditPostPageGetsLoggedInUser() throws {
//        let user = TestDataBuilder.anyUser()
//        try user.save()
//        let post = TestDataBuilder.anyPost(author: user)
//        try post.save()
//        let request = try createLoggedInRequest(method: .get, path: "posts/\(post.id!.string!)/edit", for: user)
//        _ = try drop.respond(to: request)
//        
//        XCTAssertEqual(user.name, capturingViewFactory.createBlogPostUser?.name)
//    }
//    
//    func testCreateUserPageGetsLoggedInUser() throws {
//        let request = try createLoggedInRequest(method: .get, path: "createUser", for: user)
//        _ = try drop.respond(to: request)
//        
//        XCTAssertEqual(user.name, capturingViewFactory.createUserLoggedInUser?.name)
//    }
//    
//    func testEditUserPageGetsLoggedInUser() throws {
//        let user = TestDataBuilder.anyUser()
//        try user.save()
//        let request = try createLoggedInRequest(method: .get, path: "users/\(user.id!.string!)/edit", for: user)
//        _ = try drop.respond(to: request)
//        
//        XCTAssertEqual(user.name, capturingViewFactory.createUserLoggedInUser?.name)
//    }
//    
//    func testResetPasswordPageGetsLoggedInUser() throws {
//        let request = try createLoggedInRequest(method: .get, path: "resetPassword", for: user)
//        _ = try drop.respond(to: request)
//        
//        XCTAssertEqual(user.name, capturingViewFactory.resetPasswordUser?.name)
//    }
//
//    func testCreatePostPageGetsURI() throws {
//        let request = try createLoggedInRequest(method: .get, path: "createPost")
//        _ = try drop.respond(to: request)
//
//        XCTAssertEqual(capturingViewFactory.createPostURI?.descriptionWithoutPort, "/blog/admin/createPost/")
//    }
//
//    func testCreatePostPageGetsHTTPSURIIfFromReverseProxy() throws {
//        let request = Request(method: .get, uri: "http://geeks.brokenhands.io/blog/admin/createPost/")
//        let user = TestDataBuilder.anyUser()
//        try user.save()
//        request.storage["auth-authenticated"] = user
//        request.headers["X-Forwarded-Proto"] = "https"
//
//        _ = try drop.respond(to: request)
//
//        XCTAssertEqual(capturingViewFactory.createPostURI?.descriptionWithoutPort, "https://geeks.brokenhands.io/blog/admin/createPost/")
//    }
//}


