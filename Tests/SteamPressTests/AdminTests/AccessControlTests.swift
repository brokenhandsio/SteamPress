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
    
//    func testCannotAccessAdminPageWithoutBeingLoggedIn() throws {
//        try assertLoginRequired(method: .GET, path: "")
//    }
    
    func testCannotAccessCreateBlogPostPageWithoutBeingLoggedIn() throws {
        try assertLoginRequired(method: .GET, path: "createPost")
    }

    func testCannotSendCreateBlogPostPageWithoutBeingLoggedIn() throws {
        try assertLoginRequired(method: .POST, path: "createPost")
    }

//    func testCannotAccessEditPostPageWithoutLogin() throws {
//        try assertLoginRequired(method: .get, path: "posts/2/edit")
//    }
//
//    func testCannotSendEditPostPageWithoutLogin() throws {
//        try assertLoginRequired(method: .post, path: "posts/2/edit")
//    }
//
//    func testCannotAccessCreateUserPageWithoutLogin() throws {
//        try assertLoginRequired(method: .get, path: "createUser")
//    }
//
//    func testCannotSendCreateUserPageWithoutLogin() throws {
//        try assertLoginRequired(method: .post, path: "createUser")
//    }
//
//    func testCannotAccessEditUserPageWithoutLogin() throws {
//        try assertLoginRequired(method: .get, path: "users/1/edit")
//    }
//
//    func testCannotSendEditUserPageWithoutLogin() throws {
//        try assertLoginRequired(method: .post, path: "users/1/edit")
//    }
//
//    func testCannotDeletePostWithoutLogin() throws {
//        try assertLoginRequired(method: .get, path: "posts/1/delete")
//    }
//
//    func testCannotDeleteUserWithoutLogin() throws {
//        try assertLoginRequired(method: .get, path: "users/1/delete")
//    }
//
//    func testCannotAccessResetPasswordPageWithoutLogin() throws {
//        try assertLoginRequired(method: .get, path: "resetPassword")
//    }
//
    func testCannotSendResetPasswordPageWithoutLogin() throws {
        try assertLoginRequired(method: .POST, path: "resetPassword")
    }
    
    // MARK: - Access Success Tests
    
//    func testCanAccessAdminPageWhenLoggedIn() throws {
//        let request = try createLoggedInRequest(method: .get, path: "")
//        let response = try drop.respond(to: request)
//
//        XCTAssertEqual(response.status, .ok)
//    }
//
    func testCanAccessCreatePostPageWhenLoggedIn() throws {
        let response = try testWorld.getResponse(to: "/blog/admin/createPost", loggedInUser: user)
        XCTAssertEqual(response.http.status, .ok)
    }
//
//    func testCanAccessEditPostPageWhenLoggedIn() throws {
//        let user = TestDataBuilder.anyUser()
//        try user.save()
//        let post = TestDataBuilder.anyPost(author: user)
//        try post.save()
//        let request = try createLoggedInRequest(method: .get, path: "posts/\(post.id!.string!)/edit", for: user)
//        let response = try drop.respond(to: request)
//
//        XCTAssertEqual(response.status, .ok)
//    }
//
//    func testCanAccessCreateUserPageWhenLoggedIn() throws {
//        let request = try createLoggedInRequest(method: .get, path: "createUser")
//        let response = try drop.respond(to: request)
//
//        XCTAssertEqual(response.status, .ok)
//    }
//
//    func testCanAccessEditUserPageWhenLoggedIn() throws {
//        let userToEdit = TestDataBuilder.anyUser(name: "Leia", username: "leia")
//        try userToEdit.save()
//        let request = try createLoggedInRequest(method: .get, path: "users/\(userToEdit.id!.string!)/edit")
//        let response = try drop.respond(to: request)
//
//        XCTAssertEqual(response.status, .ok)
//    }

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
