import XCTest
@testable import Vapor
@testable import SteamPress
import HTTP
import FluentProvider
import Sessions
import Cookies

class BlogAdminControllerTests: XCTestCase {
    static var allTests = [
        ("testLogin", testLogin),
        ("testCannotAccessAdminPageWithoutBeingLoggedIn", testCannotAccessAdminPageWithoutBeingLoggedIn),
        ("testCannotAccessCreateBlogPostPageWithoutBeingLoggedIn", testCannotAccessCreateBlogPostPageWithoutBeingLoggedIn),
        ("testCannotSendCreateBlogPostPageWithoutBeingLoggedIn", testCannotSendCreateBlogPostPageWithoutBeingLoggedIn),
        ("testCannotAccessEditPostPageWithoutLogin", testCannotAccessEditPostPageWithoutLogin),
        ("testCannotSendEditPostPageWithoutLogin", testCannotSendEditPostPageWithoutLogin),
        ("testCannotAccessCreateUserPageWithoutLogin", testCannotAccessCreateUserPageWithoutLogin),
        ("testCannotSendCreateUserPageWithoutLogin", testCannotSendCreateUserPageWithoutLogin),
        ("testCannotAccessProfilePageWithoutLogin", testCannotAccessProfilePageWithoutLogin),
        ("testCannotAccessEditUserPageWithoutLogin", testCannotAccessEditUserPageWithoutLogin),
        ("testCannotSendEditUserPageWithoutLogin", testCannotSendEditUserPageWithoutLogin),
        ("testCannotDeletePostWithoutLogin", testCannotDeletePostWithoutLogin),
        ("testCannotDeleteUserWithoutLogin", testCannotDeleteUserWithoutLogin),
        ("testCannotAccessResetPasswordPageWithoutLogin", testCannotAccessResetPasswordPageWithoutLogin),
        ("testCannotSendResetPasswordPageWithoutLogin", testCannotSendResetPasswordPageWithoutLogin),
    ]
    
    var database: Database!
    var drop: Droplet!
    var fakeSessions: FakeSessionsMemory!
    
    override func setUp() {
        database = Database(try! MemoryDriver(()))
        try! Droplet.prepare(database: database)
        var config = try! Config()
        fakeSessions = FakeSessionsMemory()
        config.addConfigurable(sessions: { (_) -> (FakeSessionsMemory) in
            return self.fakeSessions
        }, name: "sessions-memory")
        config.addConfigurable(middleware: { (_) -> (SessionsMiddleware) in
            let sessions = SessionsMiddleware(self.fakeSessions, cookieName: "steampress-session")
            return sessions
        }, name: "steampress-sessions")
        try! config.set("droplet.middleware", ["error", "steampress-sessions"])
        
        drop = try! Droplet(config)
        let adminController = BlogAdminController(drop: drop, pathCreator: BlogPathCreator(blogPath: "blog"), viewFactory: CapturingViewFactory())
        adminController.addRoutes()
    }
    
    override func tearDown() {
        try! Droplet.teardown(database: database)
    }
    
    func testLogin() throws {
        let hashedPassword = try BlogUser.passwordHasher.make("password")
        let newUser = TestDataBuilder.anyUser()
        newUser.password = hashedPassword
        try newUser.save()
        
        let loginJson = JSON(try Node(node: [
                "inputUsername": newUser.username,
                "inputPassword": "password"
            ]))
        let loginRequest = Request(method: .post, uri: "/blog/admin/login/")
        loginRequest.json = loginJson
        let response = try drop.respond(to: loginRequest)
        
        XCTAssertEqual(response.status, .seeOther)
        XCTAssertEqual(response.headers[HeaderKey.location], "/blog/admin/")
    }
    
    func testCannotAccessAdminPageWithoutBeingLoggedIn() throws {
        try assertLoginRequired(method: .get, path: "/blog/admin/")
    }
    
    func testCannotAccessCreateBlogPostPageWithoutBeingLoggedIn() throws {
        try assertLoginRequired(method: .get, path: "/blog/admin/createPost/")
    }
    
    func testCannotSendCreateBlogPostPageWithoutBeingLoggedIn() throws {
        try assertLoginRequired(method: .post, path: "/blog/admin/createPost/")
    }
    
    func testCannotAccessEditPostPageWithoutLogin() throws {
        try assertLoginRequired(method: .get, path: "/blog/admin/posts/2/edit/")
    }
    
    func testCannotSendEditPostPageWithoutLogin() throws {
        try assertLoginRequired(method: .post, path: "/blog/admin/posts/2/edit/")
    }
    
    func testCannotAccessCreateUserPageWithoutLogin() throws {
        try assertLoginRequired(method: .get, path: "/blog/admin/createUser/")
    }
    
    func testCannotSendCreateUserPageWithoutLogin() throws {
        try assertLoginRequired(method: .post, path: "/blog/admin/createUser/")
    }
    
    func testCannotAccessProfilePageWithoutLogin() throws {
        try assertLoginRequired(method: .get, path: "/blog/admin/profile/")
    }
    
    func testCannotAccessEditUserPageWithoutLogin() throws {
        try assertLoginRequired(method: .get, path: "/blog/admin/users/1/edit/")
    }
    
    func testCannotSendEditUserPageWithoutLogin() throws {
        try assertLoginRequired(method: .post, path: "/blog/admin/users/1/edit/")
    }
    
    func testCannotDeletePostWithoutLogin() throws {
        try assertLoginRequired(method: .get, path: "/blog/admin/posts/1/delete/")
    }
    
    func testCannotDeleteUserWithoutLogin() throws {
        try assertLoginRequired(method: .get, path: "/blog/admin/users/1/delete/")
    }
    
    func testCannotAccessResetPasswordPageWithoutLogin() throws {
        try assertLoginRequired(method: .get, path: "/blog/admin/resetPassword")
    }

    func testCannotSendResetPasswordPageWithoutLogin() throws {
        try assertLoginRequired(method: .post, path: "/blog/admin/resetPassword")
    }
    
    func testCanAccessAdminPageWhenLoggedIn() throws {
        
        let identifier = "dummy-identifier"
        let request = Request(method: .get, uri: "/blog/admin/")
        let cookie = Cookie(name: "steampress-session", value: identifier)
        
        request.cookies.insert(cookie)
        
        
        
        
        let response = try drop.respond(to: request)
        
        XCTAssertEqual(response.status, .ok)
    }
    
    private func assertLoginRequired(method: HTTP.Method, path: String) throws {
        let request = Request(method: method, uri: path)
        let response = try drop.respond(to: request)
        
        XCTAssertEqual(response.status, .seeOther)
        XCTAssertEqual(response.headers[HeaderKey.location], "/blog/admin/login/?loginRequired")
    }
}

struct FakeSessionsMemory: SessionsProtocol {
    
    var sessionIdentifier = "identifier"
    
    func makeIdentifier() throws -> String {
        return sessionIdentifier
    }
    
    func get(identifier: String) throws -> Session? {
        return Session(identifier: sessionIdentifier)
    }
    
    func set(_ session: Session) throws {
        
    }
    
    func destroy(identifier: String) throws {
        
    }
}
