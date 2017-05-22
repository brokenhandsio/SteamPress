import XCTest
import Vapor
@testable import SteamPress
import HTTP
import FluentProvider

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
    
    override func setUp() {
        database = Database(try! MemoryDriver(()))
        try! Droplet.prepare(database: database)
        let config = try! Config()
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
    
    private func assertLoginRequired(method: HTTP.Method, path: String) throws {
        let request = Request(method: method, uri: path)
        let response = try drop.respond(to: request)
        
        XCTAssertEqual(response.status, .seeOther)
        XCTAssertEqual(response.headers[HeaderKey.location], "/blog/admin/login/?loginRequired")
    }
}
