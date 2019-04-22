import XCTest
import Vapor
@testable import SteamPress
import Foundation
import Authentication

class LoginTests: XCTestCase {
    
    // MARK: - allTests
    
    static var allTests = [
        ("testLinuxTestSuiteIncludesAllTests", testLinuxTestSuiteIncludesAllTests),
        ("testAdminUserCreatedOnFirstBoot", testAdminUserCreatedOnFirstBoot),
        ("testLogin", testLogin),
        ("testUserCanResetPassword", testUserCanResetPassword),
        ("testUserCannotResetPasswordWithMismatchingPasswords", testUserCannotResetPasswordWithMismatchingPasswords),
        ("testUserCannotResetPasswordWithoutPassword", testUserCannotResetPasswordWithoutPassword),
        ("testUserCannotResetPasswordWithoutConfirmPassword", testUserCannotResetPasswordWithoutConfirmPassword)
    ]
    
    // MARK: - Properties
    private var app: Application!
    private var testWorld: TestWorld!
    private var user: BlogUser!
    
    private var presenter: CapturingAdminPresenter {
        return testWorld.context.blogAdminPresenter
    }
    
    // MARK: - Overrides
    
    override func setUp() {
        testWorld = try! TestWorld.create(path: "blog")
        user = testWorld.createUser()
    }
    
    // MARK: - Tests
    
    func testLinuxTestSuiteIncludesAllTests() {
        #if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
        let thisClass = type(of: self)
        let linuxCount = thisClass.allTests.count
        let darwinCount = Int(thisClass
            .defaultTestSuite.testCaseCount)
        XCTAssertEqual(linuxCount, darwinCount,
                       "\(darwinCount - linuxCount) tests are missing from allTests")
        #endif
    }
    
    func testLogin() throws {
        testWorld = try TestWorld.create(path: "blog", useRealPasswordHasher: true)
        let hashedPassword = try BCrypt.hash("password")
        user = testWorld.createUser(password: hashedPassword)
        let loginData = LoginData(username: user.username, password: "password")
        let loginResponse = try testWorld.getResponse(to: "/blog/admin/login", method: .POST, body: loginData)

        XCTAssertEqual(loginResponse.http.status, .seeOther)
        XCTAssertEqual(loginResponse.http.headers[.location].first, "/blog/admin/")
        XCTAssertNotNil(loginResponse.http.headers[.setCookie].first)
        XCTAssertNotNil(loginResponse.http.cookies["steampress-session"])

        let sessionCookie = loginResponse.http.cookies["steampress-session"]
        var adminRequest = HTTPRequest(method: .GET, url: URL(string: "/blog/admin")!)
        adminRequest.cookies["steampress-session"] = sessionCookie
        let wrappedAdminRequest = Request(http: adminRequest, using: testWorld.context.app)
        
        let adminResponse = try testWorld.getResponse(to: wrappedAdminRequest)

        XCTAssertEqual(adminResponse.http.status, .ok)
        
        var logoutRequest = HTTPRequest(method: .POST, url: URL(string: "/blog/admin/logout")!)
        logoutRequest.cookies["steampress-session"] = sessionCookie
        let wrappedLogoutRequest = Request(http: logoutRequest, using: testWorld.context.app)
        let logoutResponse = try testWorld.getResponse(to: wrappedLogoutRequest)

        XCTAssertEqual(logoutResponse.http.status, .seeOther)
        XCTAssertEqual(logoutResponse.http.headers[.location].first, "/blog/")
        
        var secondAdminRequest = HTTPRequest(method: .GET, url: URL(string: "/blog/admin")!)
        secondAdminRequest.cookies["steampress-session"] = sessionCookie
        let wrappedSecondRequest = Request(http: secondAdminRequest, using: testWorld.context.app)
        let loggedOutAdminResponse = try testWorld.getResponse(to: wrappedSecondRequest)

        XCTAssertEqual(loggedOutAdminResponse.http.status, .seeOther)
        XCTAssertEqual(loggedOutAdminResponse.http.headers[.location].first, "/blog/admin/login/?loginRequired")
    }
    
    func testAdminUserCreatedOnFirstBoot() {
        #warning("Implement")
    }
    
    func testUserCanResetPassword() throws {
        struct ResetPasswordData: Content {
            static let defaultContentType = MediaType.urlEncodedForm
            let password = "Th3S@m3password"
            let confirmPassword = "Th3S@m3password"
        }
        
        let data = ResetPasswordData()
        let response = try testWorld.getResponse(to: "/blog/admin/resetPassword", body: data, loggedInUser: user)
        
        XCTAssertEqual(user.password, data.password)
        XCTAssertEqual(response.http.status, .seeOther)
        XCTAssertEqual(response.http.headers[.location].first, "/blog/admin/")
        XCTAssertTrue(testWorld.context.repository.userUpdated)
    }

    func testUserCannotResetPasswordWithMismatchingPasswords() throws {
        struct ResetPasswordData: Content {
            static let defaultContentType = MediaType.urlEncodedForm
            let password = "Th3S@m3password"
            let confirmPassword = "An0th3rPass!"
        }

        let data = ResetPasswordData()
        _ = try testWorld.getResponse(to: "/blog/admin/resetPassword", body: data, loggedInUser: user)

        XCTAssertTrue(presenter.resetPasswordErrors?.contains("Your passwords must match!") ?? false)
        XCTAssertTrue(presenter.resetPasswordError ?? false)
        XCTAssertTrue(presenter.resetPasswordConfirmError ?? false)
    }

    func testUserCannotResetPasswordWithoutPassword() throws {
        struct ResetPasswordData: Content {
            static let defaultContentType = MediaType.urlEncodedForm
            let confirmPassword = "Th3S@m3password"
        }
        
        let data = ResetPasswordData()
        _ = try testWorld.getResponse(to: "/blog/admin/resetPassword", body: data, loggedInUser: user)

        XCTAssertTrue(presenter.resetPasswordErrors?.contains("You must specify a password") ?? false)
        XCTAssertTrue(presenter.resetPasswordError ?? false)
        XCTAssertNil(presenter.resetPasswordConfirmError)
    }

        func testUserCannotResetPasswordWithoutConfirmPassword() throws {
            struct ResetPasswordData: Content {
                static let defaultContentType = MediaType.urlEncodedForm
                let password = "Th3S@m3password"
            }
            
            let data = ResetPasswordData()
            _ = try testWorld.getResponse(to: "/blog/admin/resetPassword", body: data, loggedInUser: user)
            
            XCTAssertTrue(presenter.resetPasswordErrors?.contains("You must confirm your password") ?? false)
            XCTAssertNil(presenter.resetPasswordError)
            XCTAssertTrue(presenter.resetPasswordConfirmError ?? false)
        }
    
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
}

