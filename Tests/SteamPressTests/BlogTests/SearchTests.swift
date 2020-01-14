import XCTest
import SteamPress
import Vapor
import Foundation

class SearchTests: XCTestCase {

    // MARK: - Properties
    var testWorld: TestWorld!
    var firstData: TestData!

    var presenter: CapturingBlogPresenter {
        return testWorld.context.blogPresenter
    }

    // MARK: - Overrides

    override func setUp() {
        testWorld = try! TestWorld.create()
        firstData = try! testWorld.createPost(title: "Test Path", slugUrl: "test-path")
    }
    
    override func tearDown() {
        XCTAssertNoThrow(try testWorld.tryAsHardAsWeCanToShutdownApplication())
    }

    // MARK: - Tests

    func testBlogPassedToSearchPageCorrectly() throws {
        let response = try testWorld.getResponse(to: "/search?term=Test")

        XCTAssertEqual(response.http.status, .ok)
        XCTAssertEqual(presenter.searchTerm, "Test")
        XCTAssertEqual(presenter.searchPosts?.first?.title, firstData.post.title)
    }

    func testThatSearchTermNilIfEmptySearch() throws {
        let response = try testWorld.getResponse(to: "/search?term=")

        XCTAssertEqual(response.http.status, .ok)
        XCTAssertEqual(presenter.searchPosts?.count, 0)
        XCTAssertNil(presenter.searchTerm)
    }

    func testThatSearchTermNilIfNoSearchTerm() throws {
        let response = try testWorld.getResponse(to: "/search")

        XCTAssertEqual(response.http.status, .ok)
        XCTAssertEqual(presenter.searchPosts?.count, 0)
        XCTAssertNil(presenter.searchTerm)
    }
    
    func testCorrectPageInformationForSearch() throws {
        _ = try testWorld.getResponse(to: "/search?term=Test")
        XCTAssertNil(presenter.searchPageInformation?.disqusName)
        XCTAssertNil(presenter.searchPageInformation?.googleAnalyticsIdentifier)
        XCTAssertNil(presenter.searchPageInformation?.siteTwitterHandle)
        XCTAssertNil(presenter.searchPageInformation?.loggedInUser)
        XCTAssertEqual(presenter.searchPageInformation?.currentPageURL.absoluteString, "/search")
        XCTAssertEqual(presenter.searchPageInformation?.websiteURL.absoluteString, "")
    }
    
    func testPageInformationGetsLoggedInUserForSearch() throws {
        _ = try testWorld.getResponse(to: "/search?term=Test", loggedInUser: firstData.author)
        XCTAssertEqual(presenter.searchPageInformation?.loggedInUser?.username, firstData.author.username)
    }
    
    func testSettingEnvVarsWithPageInformationForSearch() throws {
        let googleAnalytics = "ABDJIODJWOIJIWO"
        let twitterHandle = "3483209fheihgifffe"
        let disqusName = "34829u48932fgvfbrtewerg"
        setenv("BLOG_GOOGLE_ANALYTICS_IDENTIFIER", googleAnalytics, 1)
        setenv("BLOG_SITE_TWITTER_HANDLE", twitterHandle, 1)
        setenv("BLOG_DISQUS_NAME", disqusName, 1)
        _ = try testWorld.getResponse(to: "/search?term=Test")
        XCTAssertEqual(presenter.searchPageInformation?.disqusName, disqusName)
        XCTAssertEqual(presenter.searchPageInformation?.googleAnalyticsIdentifier, googleAnalytics)
        XCTAssertEqual(presenter.searchPageInformation?.siteTwitterHandle, twitterHandle)
    }
}
