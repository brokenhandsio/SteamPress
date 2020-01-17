import XCTest
import Vapor
import SteamPress
import Foundation
import Authentication

class LoginTests: XCTestCase {

    // MARK: - Properties
    private var app: Application!
    private var testWorld: TestWorld!
    private var user: BlogUser!

    private var presenter: CapturingAdminPresenter {
        return testWorld.context.blogAdminPresenter
    }

    private var blogPresenter: CapturingBlogPresenter {
        return testWorld.context.blogPresenter
    }

    // MARK: - Overrides

    override func setUp() {
        testWorld = try! TestWorld.create(path: "blog")
        user = testWorld.createUser()
    }
    
    override func tearDown() {
        XCTAssertNoThrow(try testWorld.tryAsHardAsWeCanToShutdownApplication())
    }

    // MARK: - Tests

    func testLogin() throws {
        testWorld = try TestWorld.create(path: "blog", passwordHasherToUse: .real)
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
        let wrappedAdminRequest = Request(http: adminRequest, using: testWorld.context.app!)

        let adminResponse = try testWorld.getResponse(to: wrappedAdminRequest)

        XCTAssertEqual(adminResponse.http.status, .ok)

        var logoutRequest = HTTPRequest(method: .POST, url: URL(string: "/blog/admin/logout")!)
        logoutRequest.cookies["steampress-session"] = sessionCookie
        let wrappedLogoutRequest = Request(http: logoutRequest, using: testWorld.context.app!)
        let logoutResponse = try testWorld.getResponse(to: wrappedLogoutRequest)

        XCTAssertEqual(logoutResponse.http.status, .seeOther)
        XCTAssertEqual(logoutResponse.http.headers[.location].first, "/blog/")

        var secondAdminRequest = HTTPRequest(method: .GET, url: URL(string: "/blog/admin")!)
        secondAdminRequest.cookies["steampress-session"] = sessionCookie
        let wrappedSecondRequest = Request(http: secondAdminRequest, using: testWorld.context.app!)
        let loggedOutAdminResponse = try testWorld.getResponse(to: wrappedSecondRequest)

        XCTAssertEqual(loggedOutAdminResponse.http.status, .seeOther)
        XCTAssertEqual(loggedOutAdminResponse.http.headers[.location].first, "/blog/admin/login/?loginRequired")
    }

    func testLoginPageCanBeAccessed() throws {
        let response = try testWorld.getResponse(to: "/blog/admin/login")
        XCTAssertEqual(response.http.status, .ok)
    }

    func testLoginWarningShownIfRedirecting() throws {
        _ = try testWorld.getResponse(to: "/blog/admin/login?loginRequired")
        let loginWarning = try XCTUnwrap(blogPresenter.loginWarning)
        XCTAssertTrue(loginWarning)
    }
    
    func testPresenterGetsCorrectInformationForResetPasswordPage() throws {
        _ = try testWorld.getResponse(to: "/blog/admin/resetPassword", loggedInUser: user)
        XCTAssertNil(presenter.resetPasswordErrors)
        XCTAssertNil(presenter.resetPasswordError)
        XCTAssertNil(presenter.resetPasswordConfirmError)
        XCTAssertEqual(presenter.resetPasswordPageInformation?.loggedInUser.username, user.username)
        XCTAssertEqual(presenter.resetPasswordPageInformation?.websiteURL.absoluteString, "/")
        XCTAssertEqual(presenter.resetPasswordPageInformation?.currentPageURL.absoluteString, "/blog/admin/resetPassword")
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

        let passwordErrors = try XCTUnwrap(presenter.resetPasswordErrors)
        let resetPasswordError = try XCTUnwrap(presenter.resetPasswordError)
        let confirmPasswordError = try XCTUnwrap(presenter.resetPasswordConfirmError)

        XCTAssertTrue(passwordErrors.contains("Your passwords must match!"))
        XCTAssertTrue(resetPasswordError)
        XCTAssertTrue(confirmPasswordError)
        XCTAssertEqual(presenter.resetPasswordPageInformation?.loggedInUser.username, user.username)
        XCTAssertEqual(presenter.resetPasswordPageInformation?.websiteURL.absoluteString, "/")
        XCTAssertEqual(presenter.resetPasswordPageInformation?.currentPageURL.absoluteString, "/blog/admin/resetPassword")
    }

    func testUserCannotResetPasswordWithoutPassword() throws {
        struct ResetPasswordData: Content {
            static let defaultContentType = MediaType.urlEncodedForm
            let confirmPassword = "Th3S@m3password"
        }

        let data = ResetPasswordData()
        _ = try testWorld.getResponse(to: "/blog/admin/resetPassword", body: data, loggedInUser: user)

        let passwordErrors = try XCTUnwrap(presenter.resetPasswordErrors)
        let resetPasswordError = try XCTUnwrap(presenter.resetPasswordError)

        XCTAssertTrue(passwordErrors.contains("You must specify a password"))
        XCTAssertTrue(resetPasswordError)
        XCTAssertNil(presenter.resetPasswordConfirmError)
    }

    func testUserCannotResetPasswordWithoutConfirmPassword() throws {
        struct ResetPasswordData: Content {
            static let defaultContentType = MediaType.urlEncodedForm
            let password = "Th3S@m3password"
        }

        let data = ResetPasswordData()
        _ = try testWorld.getResponse(to: "/blog/admin/resetPassword", body: data, loggedInUser: user)

        let passwordErrors = try XCTUnwrap(presenter.resetPasswordErrors)
        let passwordError = try XCTUnwrap(presenter.resetPasswordConfirmError)
        XCTAssertTrue(passwordErrors.contains("You must confirm your password"))
        XCTAssertNil(presenter.resetPasswordError)
        XCTAssertTrue(passwordError)
    }

    func testUserCannotResetPasswordWithShortPassword() throws {
        struct ResetPasswordData: Content {
            static let defaultContentType = MediaType.urlEncodedForm
            let password = "apassword"
            let confirmPassword = "apassword"
        }

        let data = ResetPasswordData()
        _ = try testWorld.getResponse(to: "/blog/admin/resetPassword", body: data, loggedInUser: user)

        let passwordErrors = try XCTUnwrap(presenter.resetPasswordErrors)
        XCTAssertTrue(passwordErrors.contains("Your password must be at least 10 characters long"))
    }

    func testThatAfterResettingPasswordUserIsNotAskedToResetPassword() throws {
        let user2 = testWorld.createUser(name: "Han", username: "hans", resetPasswordRequired: true)
        struct ResetPasswordData: Content {
            static let defaultContentType = MediaType.urlEncodedForm
            let password = "alongpassword"
            let confirmPassword = "alongpassword"
        }

        let data = ResetPasswordData()
        _ = try testWorld.getResponse(to: "/blog/admin/resetPassword", body: data, loggedInUser: user2)

        let response = try testWorld.getResponse(to: "/blog/admin", method: .GET, body: EmptyContent(), loggedInUser: user2)

        XCTAssertEqual(response.http.status, .ok)
    }

    func testUserIsRedirectedWhenLoggingInAndPasswordResetRequired() throws {
        let user2 = testWorld.createUser(username: "hans", resetPasswordRequired: true)

        let response = try testWorld.getResponse(to: "/blog/admin/", method: .GET, body: EmptyContent(), loggedInUser: user2)

        XCTAssertEqual(response.http.status, .seeOther)
        XCTAssertEqual(response.http.headers[.location].first, "/blog/admin/resetPassword/")
    }

    func testErrorShownWhenTryingToLoginWithoutUsername() throws {
        let loginData = LoginData(username: nil, password: "password")
        _ = try testWorld.getResponse(to: "/blog/admin/login", method: .POST, body: loginData)

        let loginErrors = try XCTUnwrap(testWorld.context.blogPresenter.loginErrors)
        let usernameError = try XCTUnwrap(testWorld.context.blogPresenter.loginUsernameError)
        XCTAssertTrue(loginErrors.contains("You must supply your username"))
        XCTAssertTrue(usernameError)
    }

    func testErrorShownWhenTryingToLoginWithoutPassword() throws {
        let loginData = LoginData(username: "usera", password: nil)
        _ = try testWorld.getResponse(to: "/blog/admin/login", method: .POST, body: loginData)

        let loginErrors = try XCTUnwrap(testWorld.context.blogPresenter.loginErrors)
        let passwordError = try XCTUnwrap(testWorld.context.blogPresenter.loginPasswordError)
        XCTAssertTrue(loginErrors.contains("You must supply your password"))
        XCTAssertTrue(passwordError)
    }

    func testLoggingInWithInvalidCredentials() throws {
        let loginData = LoginData(username: "luke", password: "notthepassword")
        _ = try testWorld.getResponse(to: "/blog/admin/login", method: .POST, body: loginData)

        let loginErrors = try XCTUnwrap(testWorld.context.blogPresenter.loginErrors)
        XCTAssertTrue(loginErrors.contains("Your username or password is incorrect"))
    }

    func testLoginWithRememberMeSetsCookieExpiryDateTo1Year() throws {
        let loginData = LoginData(username: "luke", password: "password", rememberMe: true)
        let response = try testWorld.getResponse(to: "/blog/admin/login", method: .POST, body: loginData)

        let cookieExpiry = try XCTUnwrap(response.http.cookies["steampress-session"]?.expires)
        let oneYear: TimeInterval = 60 * 60 * 24 * 365
        XCTAssertEqual(cookieExpiry.timeIntervalSince1970, Date().addingTimeInterval(oneYear).timeIntervalSince1970, accuracy: 1)
    }

    func testLoginWithoutRememberMeDoesntSetCookieExpiryDate() throws {
        let loginData = LoginData(username: "luke", password: "password", rememberMe: nil)
        let response = try testWorld.getResponse(to: "/blog/admin/login", method: .POST, body: loginData)

        let cookie = try XCTUnwrap(response.http.cookies["steampress-session"])
        XCTAssertNil(cookie.expires)
    }

    func testLoginWithRememberMeSetToFalseDoesntSetCookieExpiryDate() throws {
        let loginData = LoginData(username: "luke", password: "password", rememberMe: false)
        let response = try testWorld.getResponse(to: "/blog/admin/login", method: .POST, body: loginData)

        let cookie = try XCTUnwrap(response.http.cookies["steampress-session"])
        XCTAssertNil(cookie.expires)
    }

    func testLoginWithRememberMeThenLoginAgainWithItDisabledDoesntRememberMe() throws {
        var loginData = LoginData(username: "luke", password: "password", rememberMe: true)
        _ = try testWorld.getResponse(to: "/blog/admin/login", method: .POST, body: loginData)

        loginData = LoginData(username: "luke", password: "password", rememberMe: false)
        let response = try testWorld.getResponse(to: "/blog/admin/login", method: .POST, body: loginData)

        let cookie = try XCTUnwrap(response.http.cookies["steampress-session"])
        XCTAssertNil(cookie.expires)
    }

    func testRememberMeDateOnlySetOnceThenLoginAgainWithItDisabledDoesntRememberMe() throws {
        let loginData = LoginData(username: "luke", password: "password", rememberMe: true)
        let loginResponse = try testWorld.getResponse(to: "/blog/admin/login", method: .POST, body: loginData)

        let cookie = loginResponse.http.cookies["steampress-session"]
        var adminRequest = HTTPRequest(method: .GET, url: URL(string: "/blog/admin")!)
        adminRequest.cookies["steampress-session"] = cookie
        let wrappedAdminRequest = Request(http: adminRequest, using: testWorld.context.app!)
        let response = try testWorld.getResponse(to: wrappedAdminRequest)

        XCTAssertEqual(loginResponse.http.cookies["steampress-session"]?.expires, response.http.cookies["steampress-session"]?.expires)
    }
    
    func testCorrectPageInformationForLogin() throws {
        _ = try testWorld.getResponse(to: "/blog/admin/login")
        XCTAssertNil(blogPresenter.loginPageInformation?.disqusName)
        XCTAssertNil(blogPresenter.loginPageInformation?.googleAnalyticsIdentifier)
        XCTAssertNil(blogPresenter.loginPageInformation?.siteTwitterHandle)
        XCTAssertNil(blogPresenter.loginPageInformation?.loggedInUser)
        XCTAssertEqual(blogPresenter.loginPageInformation?.currentPageURL.absoluteString, "/blog/admin/login")
        XCTAssertEqual(blogPresenter.loginPageInformation?.websiteURL.absoluteString, "/")
    }

    func testSettingEnvVarsWithPageInformationForLoginPage() throws {
        let googleAnalytics = "ABDJIODJWOIJIWO"
        let twitterHandle = "3483209fheihgifffe"
        let disqusName = "34829u48932fgvfbrtewerg"
        setenv("BLOG_GOOGLE_ANALYTICS_IDENTIFIER", googleAnalytics, 1)
        setenv("BLOG_SITE_TWITTER_HANDLE", twitterHandle, 1)
        setenv("BLOG_DISQUS_NAME", disqusName, 1)
        _ = try testWorld.getResponse(to: "/blog/admin/login")
        XCTAssertEqual(blogPresenter.loginPageInformation?.disqusName, disqusName)
        XCTAssertEqual(blogPresenter.loginPageInformation?.googleAnalyticsIdentifier, googleAnalytics)
        XCTAssertEqual(blogPresenter.loginPageInformation?.siteTwitterHandle, twitterHandle)
    }
}
