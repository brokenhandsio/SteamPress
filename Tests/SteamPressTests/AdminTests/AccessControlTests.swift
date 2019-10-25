import XCTest
import Vapor
import SteamPress

class AccessControlTests: XCTestCase {
    
    // MARK: - Properties
    private var app: Application!
    private var testWorld: TestWorld!
    private var user: BlogUser!
    
    // MARK: - Overrides
    
    override func setUp() {
        testWorld = try! TestWorld.create(path: "blog")
        user = testWorld.createUser()
    }
    
    // MARK: - Tests
    
    // MARK: - Access restriction tests
    
    func testCannotAccessAdminPageWithoutBeingLoggedIn() throws {
        try assertLoginRequired(method: .GET, path: "")
    }
    
    func testCannotAccessCreateBlogPostPageWithoutBeingLoggedIn() throws {
        try assertLoginRequired(method: .GET, path: "createPost")
    }

    func testCannotSendCreateBlogPostPageWithoutBeingLoggedIn() throws {
        try assertLoginRequired(method: .POST, path: "createPost")
    }

    func testCannotAccessEditPostPageWithoutLogin() throws {
        let post = try testWorld.createPost()
        try assertLoginRequired(method: .GET, path: "posts/\(post.post.blogID!)/edit")
    }

    func testCannotSendEditPostPageWithoutLogin() throws {
        let post = try testWorld.createPost()
        try assertLoginRequired(method: .POST, path: "posts/\(post.post.blogID!)/edit")
    }

    func testCannotAccessCreateUserPageWithoutLogin() throws {
        try assertLoginRequired(method: .GET, path: "createUser")
    }

    func testCannotSendCreateUserPageWithoutLogin() throws {
        try assertLoginRequired(method: .POST, path: "createUser")
    }

    func testCannotAccessEditUserPageWithoutLogin() throws {
        try assertLoginRequired(method: .GET, path: "users/1/edit")
    }

    func testCannotSendEditUserPageWithoutLogin() throws {
        try assertLoginRequired(method: .POST, path: "users/1/edit")
    }

    func testCannotDeletePostWithoutLogin() throws {
        try assertLoginRequired(method: .POST, path: "posts/1/delete")
    }

    func testCannotDeleteUserWithoutLogin() throws {
        try assertLoginRequired(method: .POST, path: "users/1/delete")
    }

    func testCannotAccessResetPasswordPageWithoutLogin() throws {
        try assertLoginRequired(method: .GET, path: "resetPassword")
    }

    func testCannotSendResetPasswordPageWithoutLogin() throws {
        try assertLoginRequired(method: .POST, path: "resetPassword")
    }
    
    // MARK: - Access Success Tests
    
    func testCanAccessAdminPageWhenLoggedIn() throws {
        let response = try testWorld.getResponse(to: "/blog/admin/", loggedInUser: user)
        XCTAssertEqual(response.http.status, .ok)
    }

    func testCanAccessCreatePostPageWhenLoggedIn() throws {
        let response = try testWorld.getResponse(to: "/blog/admin/createPost", loggedInUser: user)
        XCTAssertEqual(response.http.status, .ok)
    }

    func testCanAccessEditPostPageWhenLoggedIn() throws {
        let post = try testWorld.createPost()
        let response = try testWorld.getResponse(to: "/blog/admin/posts/\(post.post.blogID!)/edit", loggedInUser: user)
        XCTAssertEqual(response.http.status, .ok)
    }

    func testCanAccessCreateUserPageWhenLoggedIn() throws {
        let response = try testWorld.getResponse(to: "/blog/admin/createUser", loggedInUser: user)
        XCTAssertEqual(response.http.status, .ok)
    }

    func testCanAccessEditUserPageWhenLoggedIn() throws {
        let response = try testWorld.getResponse(to: "/blog/admin/users/1/edit", loggedInUser: user)
        XCTAssertEqual(response.http.status, .ok)
    }

    func testCanAccessResetPasswordPage() throws {
        let response = try testWorld.getResponse(to: "/blog/admin/resetPassword", loggedInUser: user)
        XCTAssertEqual(response.http.status, .ok)
    }

    
    // MARK: - Helpers
    
    private func assertLoginRequired(method: HTTPMethod, path: String) throws {
        let response = try testWorld.getResponse(to: "/blog/admin/\(path)", method: method)

        XCTAssertEqual(response.http.status, .seeOther)
        XCTAssertEqual(response.http.headers[.location].first, "/blog/admin/login/?loginRequired")
    }
    
}
