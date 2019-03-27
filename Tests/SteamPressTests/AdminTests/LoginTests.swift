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
        ("testLogin", testLogin)
    ]
    
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
}

