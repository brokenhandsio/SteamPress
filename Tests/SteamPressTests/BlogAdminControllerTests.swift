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
//    func testCanDeleteUser() throws {
//        let user2 = TestDataBuilder.anyUser(name: "Han", username: "han")
//        try user2.save()
//        
//        let request = try createLoggedInRequest(method: .get, path: "users/\(user2.id!.string!)/delete")
//        let response = try drop.respond(to: request)
//        
//        XCTAssertEqual(response.status, .seeOther)
//        XCTAssertEqual(try BlogUser.count(), 2)
//        XCTAssertNotEqual(try BlogUser.all().first?.name, "Han")
//    }
//    
//    func testCannotDeleteSelf() throws {
//        let user = TestDataBuilder.anyUser(name: "Han", username: "han")
//        try user.save()
//        
//        let request = try createLoggedInRequest(method: .get, path: "users/\(user.id!.string!)/delete", for: user)
//        _ = try drop.respond(to: request)
//        
//        XCTAssertTrue(capturingViewFactory.adminViewErrors?.contains("You cannot delete yourself whilst logged in") ?? false)
//    }
//    
//    func testCannotDeleteLastUser() throws {
//        let user = try BlogUser.all().first
//        
//        let userID = user!.id!.string!
//        
//        let request = try createLoggedInRequest(method: .get, path: "users/\(userID)/delete", for: user)
//        _ = try drop.respond(to: request)
//        
//        XCTAssertTrue(capturingViewFactory.adminViewErrors?.contains("You cannot delete the last user") ?? false)
//    }
//    
//    // MARK: - Reset Password tests
//    
//    func testUserCannotResetPasswordWithMismatchingPasswords() throws {
//        let user = TestDataBuilder.anyUser()
//        try user.save()
//        
//        let request = try createLoggedInRequest(method: .post, path: "resetPassword", for: user)
//        let resetPasswordData = try Node(node: [
//            "inputPassword": "Th3S@m3password",
//            "inputConfirmPassword": "An0th3rPass!"
//            ])
//        request.formURLEncoded = resetPasswordData
//        
//        _ = try drop.respond(to: request)
//        
//        XCTAssertTrue(capturingViewFactory.resetPasswordErrors?.contains("Your passwords must match!") ?? false)
//    }
//    
//    func testUserCanResetPassword() throws {
//        BlogUser.passwordHasher = FakePasswordHasher()
//        let user = TestDataBuilder.anyUser()
//        try user.save()
//        let newPassword = "Th3S@m3password"
//        
//        let request = try createLoggedInRequest(method: .post, path: "resetPassword", for: user)
//        let resetPasswordData = try Node(node: [
//            "inputPassword": newPassword,
//            "inputConfirmPassword": newPassword
//            ])
//        request.formURLEncoded = resetPasswordData
//        
//        let response = try drop.respond(to: request)
//        
//        XCTAssertEqual(user.password, newPassword.makeBytes())
//        XCTAssertEqual(response.status, .seeOther)
//        XCTAssertEqual(response.headers[HeaderKey.location], "/blog/admin/")
//    }
//    
//    func testUserCannotResetPasswordWithoutPassword() throws {
//        let user = TestDataBuilder.anyUser()
//        try user.save()
//        
//        let request = try createLoggedInRequest(method: .post, path: "resetPassword", for: user)
//        let resetPasswordData = try Node(node: [
//            "inputConfirmPassword": "Th3S@m3password",
//            ])
//        request.formURLEncoded = resetPasswordData
//        
//        _ = try drop.respond(to: request)
//        
//        XCTAssertTrue(capturingViewFactory.resetPasswordErrors?.contains("You must specify a password") ?? false)
//    }
//    
//    func testUserCannotResetPasswordWithoutConfirmPassword() throws {
//        let user = TestDataBuilder.anyUser()
//        try user.save()
//        
//        let request = try createLoggedInRequest(method: .post, path: "resetPassword", for: user)
//        let resetPasswordData = try Node(node: [
//            "inputPassword": "Th3S@m3password",
//            ])
//        request.formURLEncoded = resetPasswordData
//        
//        _ = try drop.respond(to: request)
//        
//        XCTAssertTrue(capturingViewFactory.resetPasswordErrors?.contains("You must confirm your password") ?? false)
//    }
//    
//    func testUserCannotResetPasswordWithShortPassword() throws {
//        let user = TestDataBuilder.anyUser()
//        try user.save()
//        
//        let request = try createLoggedInRequest(method: .post, path: "resetPassword", for: user)
//        let resetPasswordData = try Node(node: [
//            "inputPassword": "S12$345",
//            "inputConfirmPassword": "S12$345"
//            ])
//        request.formURLEncoded = resetPasswordData
//        
//        _ = try drop.respond(to: request)
//        
//        XCTAssertTrue(capturingViewFactory.resetPasswordErrors?.contains("Your password must contain a lowercase letter, an upperacase letter, a number and a symbol") ?? false)
//    }
//    
//    func testUserIsRedirectedWhenLoggingInAndPasswordResetRequired() throws {
//        let user = TestDataBuilder.anyUser()
//        user.resetPasswordRequired = true
//        try user.save()
//        
//        let request = try createLoggedInRequest(method: .get, path: "", for: user)
//        
//        let response = try drop.respond(to: request)
//        
//        XCTAssertEqual(response.status, .seeOther)
//        XCTAssertEqual(response.headers[HeaderKey.location], "/blog/admin/resetPassword/")
//    }
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


