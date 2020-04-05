import XCTest
import Vapor
import SteamPress
import Foundation

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
        XCTAssertNoThrow(try testWorld.shutdown())
    }

    // MARK: - Tests

    func testLogin() throws {
        testWorld = try TestWorld.create(path: "blog", passwordHasherToUse: .real)
        let hashedPassword = try BCryptDigest().hash("password")
        user = testWorld.createUser(password: hashedPassword)
        let loginData = LoginData(username: user.username, password: "password")
        let loginResponse = try testWorld.getResponse(to: "/blog/admin/login", method: .POST, body: loginData)

        XCTAssertEqual(loginResponse.status, .seeOther)
        XCTAssertEqual(loginResponse.headers[.location].first, "/blog/admin/")
        XCTAssertNotNil(loginResponse.headers[.setCookie].first)
        XCTAssertNotNil(loginResponse.cookies["steampress-session"])

        let sessionCookie = loginResponse.cookies["steampress-session"]
        let adminRequest = Request(application: testWorld.context.app, method: .GET, url: URI(path: "/blog/admin"), on: testWorld.context.app.eventLoopGroup.next())
        adminRequest.cookies["steampress-session"] = sessionCookie

        let adminResponse = try testWorld.getResponse(to: adminRequest)

        XCTAssertEqual(adminResponse.status, .ok)

        let logoutRequest = Request(application: testWorld.context.app, method: .POST, url: URI(path: "/blog/admin/logout"), on: testWorld.context.app.eventLoopGroup.next())
        logoutRequest.cookies["steampress-session"] = sessionCookie
        let logoutResponse = try testWorld.getResponse(to: logoutRequest)

        XCTAssertEqual(logoutResponse.status, .seeOther)
        XCTAssertEqual(logoutResponse.headers[.location].first, "/blog/")

        let secondAdminRequest = Request(application: testWorld.context.app, method: .GET, url: URI(path: "/blog/admin"), on: testWorld.context.app.eventLoopGroup.next())
        secondAdminRequest.cookies["steampress-session"] = sessionCookie
        let loggedOutAdminResponse = try testWorld.getResponse(to: secondAdminRequest)

        XCTAssertEqual(loggedOutAdminResponse.status, .seeOther)
        XCTAssertEqual(loggedOutAdminResponse.headers[.location].first, "/blog/admin/login/?loginRequired")
    }

    func testLoginPageCanBeAccessed() throws {
        let response = try testWorld.getResponse(to: "/blog/admin/login")
        XCTAssertEqual(response.status, .ok)
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
            static let defaultContentType = HTTPMediaType.urlEncodedForm
            let password = "Th3S@m3password"
            let confirmPassword = "Th3S@m3password"
        }

        let data = ResetPasswordData()
        let response = try testWorld.getResponse(to: "/blog/admin/resetPassword", body: data, loggedInUser: user)

        XCTAssertEqual(user.password, data.password)
        XCTAssertEqual(response.status, .seeOther)
        XCTAssertEqual(response.headers[.location].first, "/blog/admin/")
        XCTAssertTrue(testWorld.context.repository.userUpdated)
    }

    func testUserCannotResetPasswordWithMismatchingPasswords() throws {
        struct ResetPasswordData: Content {
            static let defaultContentType = HTTPMediaType.urlEncodedForm
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
            static let defaultContentType = HTTPMediaType.urlEncodedForm
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
            static let defaultContentType = HTTPMediaType.urlEncodedForm
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
            static let defaultContentType = HTTPMediaType.urlEncodedForm
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
            static let defaultContentType = HTTPMediaType.urlEncodedForm
            let password = "alongpassword"
            let confirmPassword = "alongpassword"
        }

        let data = ResetPasswordData()
        _ = try testWorld.getResponse(to: "/blog/admin/resetPassword", body: data, loggedInUser: user2)

        let response = try testWorld.getResponse(to: "/blog/admin", method: .GET, body: EmptyContent(), loggedInUser: user2)

        XCTAssertEqual(response.status, .ok)
    }

    func testUserIsRedirectedWhenLoggingInAndPasswordResetRequired() throws {
        let user2 = testWorld.createUser(username: "hans", resetPasswordRequired: true)

        let response = try testWorld.getResponse(to: "/blog/admin/", method: .GET, body: EmptyContent(), loggedInUser: user2)

        XCTAssertEqual(response.status, .seeOther)
        XCTAssertEqual(response.headers[.location].first, "/blog/admin/resetPassword/")
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

        let cookieExpiry = try XCTUnwrap(response.cookies["steampress-session"]?.expires)
        let oneYear: TimeInterval = 60 * 60 * 24 * 365
        XCTAssertEqual(cookieExpiry.timeIntervalSince1970, Date().addingTimeInterval(oneYear).timeIntervalSince1970, accuracy: 1)
    }

    func testLoginWithoutRememberMeDoesntSetCookieExpiryDate() throws {
        let loginData = LoginData(username: "luke", password: "password", rememberMe: nil)
        let response = try testWorld.getResponse(to: "/blog/admin/login", method: .POST, body: loginData)

        let cookie = try XCTUnwrap(response.cookies["steampress-session"])
        XCTAssertNil(cookie.expires)
    }

    func testLoginWithRememberMeSetToFalseDoesntSetCookieExpiryDate() throws {
        let loginData = LoginData(username: "luke", password: "password", rememberMe: false)
        let response = try testWorld.getResponse(to: "/blog/admin/login", method: .POST, body: loginData)

        let cookie = try XCTUnwrap(response.cookies["steampress-session"])
        XCTAssertNil(cookie.expires)
    }

    func testLoginWithRememberMeThenLoginAgainWithItDisabledDoesntRememberMe() throws {
        var loginData = LoginData(username: "luke", password: "password", rememberMe: true)
        _ = try testWorld.getResponse(to: "/blog/admin/login", method: .POST, body: loginData)

        loginData = LoginData(username: "luke", password: "password", rememberMe: false)
        let response = try testWorld.getResponse(to: "/blog/admin/login", method: .POST, body: loginData)

        let cookie = try XCTUnwrap(response.cookies["steampress-session"])
        XCTAssertNil(cookie.expires)
    }

    func testRememberMeDateOnlySetOnceThenLoginAgainWithItDisabledDoesntRememberMe() throws {
        let loginData = LoginData(username: "luke", password: "password", rememberMe: true)
        let loginResponse = try testWorld.getResponse(to: "/blog/admin/login", method: .POST, body: loginData)

        let cookie = loginResponse.cookies["steampress-session"]
        let adminRequest = Request(application: testWorld.context.app, method: .GET, url: URI(path: "/blog/admin"), on: testWorld.context.app.eventLoopGroup.next())
        adminRequest.cookies["steampress-session"] = cookie
        let response = try testWorld.getResponse(to: adminRequest)

        XCTAssertEqual(loginResponse.cookies["steampress-session"]?.expires, response.cookies["steampress-session"]?.expires)
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
