import XCTest
@testable import Vapor
@testable import SteamPress
import HTTP
import FluentProvider
import Sessions
import Cookies

class BlogAdminControllerTests: XCTestCase {
    static var allTests = [
        ("testLinuxTestSuiteIncludesAllTests", testLinuxTestSuiteIncludesAllTests),
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
        ("testCanAccessAdminPageWhenLoggedIn", testCanAccessAdminPageWhenLoggedIn),
        ("testCanAccessCreatePostPageWhenLoggedIn", testCanAccessCreatePostPageWhenLoggedIn),
        ("testCanAccessCreateUserPageWhenLoggedIn", testCanAccessCreateUserPageWhenLoggedIn),
        ("testCanAccessProfilePageWhenLoggedIn", testCanAccessProfilePageWhenLoggedIn),
        ("testCanAccessResetPasswordPage", testCanAccessResetPasswordPage),
        ("testCanDeleteBlogPost", testCanDeleteBlogPost),
        ("testCanDeleteUser", testCanDeleteUser),
        ("testCannotDeleteSelf", testCannotDeleteSelf),
        ("testCannotDeleteLastUser", testCannotDeleteLastUser),
        ("testUserCannotResetPasswordWithMismatchingPasswords", testUserCannotResetPasswordWithMismatchingPasswords),
        ("testUserCannotResetPasswordWithBasicPassword", testUserCannotResetPasswordWithBasicPassword),
        ("testUserCanResetPassword", testUserCanResetPassword),
        ("testUserCannotResetPasswordWithoutPassword", testUserCannotResetPasswordWithoutPassword),
        ("testUserCannotResetPasswordWithoutConfirmPassword", testUserCannotResetPasswordWithoutConfirmPassword),
        ("testUserCannotResetPasswordWithShortPassword", testUserCannotResetPasswordWithShortPassword),
        ("testUserIsRedirectedWhenLoggingInAndPasswordResetRequired", testUserIsRedirectedWhenLoggingInAndPasswordResetRequired),
    ]
    
    var database: Database!
    var drop: Droplet!
    var capturingViewFactory: CapturingViewFactory!
    
    override func setUp() {
        database = Database(try! MemoryDriver(()))
        try! Droplet.prepare(database: database)
        var config = try! Config()
        config.addConfigurable(middleware: { (_) -> (SessionsMiddleware) in
            let sessions = SessionsMiddleware(try! config.resolveSessions(), cookieName: "steampress-session")
            return sessions
        }, name: "steampress-sessions")
        try! config.set("droplet.middleware", ["error", "steampress-sessions"])
        
        drop = try! Droplet(config)
        capturingViewFactory = CapturingViewFactory()
        let adminController = BlogAdminController(drop: drop, pathCreator: BlogPathCreator(blogPath: "blog"), viewFactory: capturingViewFactory)
        adminController.addRoutes()
    }
    
    override func tearDown() {
        try! Droplet.teardown(database: database)
    }
    
    // Courtesy of https://oleb.net/blog/2017/03/keeping-xctest-in-sync/
    func testLinuxTestSuiteIncludesAllTests() {
        #if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
            let thisClass = type(of: self)
            let linuxCount = thisClass.allTests.count
            let darwinCount = Int(thisClass.defaultTestSuite().testCaseCount)
            XCTAssertEqual(linuxCount, darwinCount, "\(darwinCount - linuxCount) tests are missing from allTests")
        #endif
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
        let request = try createLoggedInRequest(method: .get, path: "/blog/admin/")
        let response = try drop.respond(to: request)
        
        XCTAssertEqual(response.status, .ok)
    }
    
    func testCanAccessCreatePostPageWhenLoggedIn() throws {
        let request = try createLoggedInRequest(method: .get, path: "/blog/admin/createPost/")
        let response = try drop.respond(to: request)
        
        XCTAssertEqual(response.status, .ok)
    }
    
    func testCanAccessCreateUserPageWhenLoggedIn() throws {
        let request = try createLoggedInRequest(method: .get, path: "/blog/admin/createUser/")
        let response = try drop.respond(to: request)
        
        XCTAssertEqual(response.status, .ok)
    }
    
    func testCanAccessProfilePageWhenLoggedIn() throws {
        let user = TestDataBuilder.anyUser()
        try user.save()
        let request = try createLoggedInRequest(method: .get, path: "/blog/admin/profile/", for: user)
        let response = try drop.respond(to: request)
        
        XCTAssertEqual(response.status, .ok)
    }
    
    func testCanAccessResetPasswordPage() throws {
        let request = try createLoggedInRequest(method: .get, path: "/blog/admin/resetPassword/")
        let response = try drop.respond(to: request)
        
        XCTAssertEqual(response.status, .ok)
    }
    
    func testCanDeleteBlogPost() throws {
        let user = TestDataBuilder.anyUser()
        try user.save()
        let post = TestDataBuilder.anyPost(author: user)
        try post.save()
        
        let request = try createLoggedInRequest(method: .get, path: "/blog/admin/posts/\(post.id!.string!)/delete/", for: user)
        
        let response = try drop.respond(to: request)
        
        XCTAssertEqual(response.status, .seeOther)
        XCTAssertEqual(try BlogPost.count(), 0)
    }
    
    func testCanDeleteUser() throws {
        let user2 = TestDataBuilder.anyUser(name: "Han", username: "han")
        try user2.save()
        
        let request = try createLoggedInRequest(method: .get, path: "/blog/admin/users/\(user2.id!.string!)/delete/")
        let response = try drop.respond(to: request)
        
        XCTAssertEqual(response.status, .seeOther)
        XCTAssertEqual(try BlogUser.count(), 1)
        XCTAssertNotEqual(try BlogUser.all().first?.name, "Han")
    }
    
    func testCannotDeleteSelf() throws {
        let adminUser = TestDataBuilder.anyUser(name: "admin", username: "admin")
        try adminUser.save()
        let user = TestDataBuilder.anyUser(name: "Han", username: "han")
        try user.save()
        
        let request = try createLoggedInRequest(method: .get, path: "/blog/admin/users/\(user.id!.string!)/delete/", for: user)
        _ = try drop.respond(to: request)
        
        XCTAssertTrue(capturingViewFactory.adminViewErrors?.contains("You cannot delete yourself whilst logged in") ?? false)
    }
    
    func testCannotDeleteLastUser() throws {
        let user = TestDataBuilder.anyUser(name: "Han", username: "han")
        try user.save()
        
        let request = try createLoggedInRequest(method: .get, path: "/blog/admin/users/\(user.id!.string!)/delete/", for: user)
        _ = try drop.respond(to: request)
        
        XCTAssertTrue(capturingViewFactory.adminViewErrors?.contains("You cannot delete the last user") ?? false)
    }
    
    func testUserCannotResetPasswordWithMismatchingPasswords() throws {
        let user = TestDataBuilder.anyUser()
        try user.save()
        
        let request = try createLoggedInRequest(method: .post, path: "/blog/admin/resetPassword/", for: user)
        let resetPasswordData = try Node(node: [
            "inputPassword": "Th3S@m3password",
            "inputConfirmPassword": "An0th3rPass!"
            ])
        request.formURLEncoded = resetPasswordData
        
        _ = try drop.respond(to: request)
        
        XCTAssertTrue(capturingViewFactory.resetPasswordErrors?.contains("Your passwords must match!") ?? false)
    }
    
    func testUserCannotResetPasswordWithBasicPassword() throws {
        let user = TestDataBuilder.anyUser()
        try user.save()
        
        let request = try createLoggedInRequest(method: .post, path: "/blog/admin/resetPassword/", for: user)
        let resetPasswordData = try Node(node: [
            "inputPassword": "simplepassword",
            "inputConfirmPassword": "simplepassword"
            ])
        request.formURLEncoded = resetPasswordData
        
        _ = try drop.respond(to: request)
        
        XCTAssertTrue(capturingViewFactory.resetPasswordErrors?.contains("Your password must contain a lowercase letter, an upperacase letter, a number and a symbol") ?? false)
    }
    
    func testUserCanResetPassword() throws {
        BlogUser.passwordHasher = FakePasswordHasher()
        let user = TestDataBuilder.anyUser()
        try user.save()
        let newPassword = "Th3S@m3password"
        
        let request = try createLoggedInRequest(method: .post, path: "/blog/admin/resetPassword/", for: user)
        let resetPasswordData = try Node(node: [
            "inputPassword": newPassword,
            "inputConfirmPassword": newPassword
            ])
        request.formURLEncoded = resetPasswordData
        
        let response = try drop.respond(to: request)
        
        XCTAssertEqual(user.password, newPassword.makeBytes())
        XCTAssertEqual(response.status, .seeOther)
        XCTAssertEqual(response.headers[HeaderKey.location], "/blog/admin/")
    }
    
    func testUserCannotResetPasswordWithoutPassword() throws {
        let user = TestDataBuilder.anyUser()
        try user.save()
        
        let request = try createLoggedInRequest(method: .post, path: "/blog/admin/resetPassword/", for: user)
        let resetPasswordData = try Node(node: [
            "inputConfirmPassword": "Th3S@m3password",
            ])
        request.formURLEncoded = resetPasswordData
        
        _ = try drop.respond(to: request)
        
        XCTAssertTrue(capturingViewFactory.resetPasswordErrors?.contains("You must specify a password") ?? false)
    }
    
    func testUserCannotResetPasswordWithoutConfirmPassword() throws {
        let user = TestDataBuilder.anyUser()
        try user.save()
        
        let request = try createLoggedInRequest(method: .post, path: "/blog/admin/resetPassword/", for: user)
        let resetPasswordData = try Node(node: [
            "inputPassword": "Th3S@m3password",
            ])
        request.formURLEncoded = resetPasswordData
        
        _ = try drop.respond(to: request)
        
        XCTAssertTrue(capturingViewFactory.resetPasswordErrors?.contains("You must confirm your password") ?? false)
    }
    
    func testUserCannotResetPasswordWithShortPassword() throws {
        let user = TestDataBuilder.anyUser()
        try user.save()
        
        let request = try createLoggedInRequest(method: .post, path: "/blog/admin/resetPassword/", for: user)
        let resetPasswordData = try Node(node: [
            "inputPassword": "S12$",
            "inputConfirmPassword": "S12$"
            ])
        request.formURLEncoded = resetPasswordData
        
        _ = try drop.respond(to: request)
        
        XCTAssertTrue(capturingViewFactory.resetPasswordErrors?.contains("Your password must contain a lowercase letter, an upperacase letter, a number and a symbol") ?? false)
    }
    
    func testUserIsRedirectedWhenLoggingInAndPasswordResetRequired() throws {
        let user = TestDataBuilder.anyUser()
        user.resetPasswordRequired = true
        try user.save()
        
        let request = try createLoggedInRequest(method: .get, path: "/blog/admin/", for: user)
        
        let response = try drop.respond(to: request)
        
        XCTAssertEqual(response.status, .seeOther)
        XCTAssertEqual(response.headers[HeaderKey.location], "/blog/admin/resetPassword/")
    }
    
    private func assertLoginRequired(method: HTTP.Method, path: String) throws {
        let request = Request(method: method, uri: path)
        let response = try drop.respond(to: request)
        
        XCTAssertEqual(response.status, .seeOther)
        XCTAssertEqual(response.headers[HeaderKey.location], "/blog/admin/login/?loginRequired")
    }
    
    private func createLoggedInRequest(method: HTTP.Method, path: String, for user: BlogUser? = nil) throws -> Request {
        let request = Request(method: method, uri: path)
        let cookie = Cookie(name: "steampress-session", value: "dummy-identifier")
        
        let authAuthenticatedKey = "auth-authenticated"
        
        if let user = user {
            request.storage[authAuthenticatedKey] = user
        }
        else {
            let testUser = TestDataBuilder.anyUser()
            try testUser.save()
            request.storage[authAuthenticatedKey] = testUser
        }
        
        
        request.cookies.insert(cookie)
        
        return request
    }
}

struct FakePasswordHasher: PasswordHasherVerifier {
    func verify(password: Bytes, matches hash: Bytes) throws -> Bool {
        return password == hash
    }
    
    func make(_ message: Bytes) throws -> Bytes {
        return message
    }
    
    func check(_ message: Bytes, matchesHash: Bytes) throws -> Bool {
        return message == matchesHash
    }
}
