import XCTest
import SteamPress
import Vapor
import Foundation

class PostTests: XCTestCase {

    // MARK: - Properties
    var testWorld: TestWorld!
    var firstData: TestData!
    private let blogPostPath = "/posts/test-path/"

    var presenter: CapturingBlogPresenter {
        return testWorld.context.blogPresenter
    }

    // MARK: - Overrides

    override func setUp() {
        testWorld = try! TestWorld.create()
        firstData = try! testWorld.createPost(title: "Test Path", slugUrl: "test-path")
    }

    // MARK: - Tests

    func testBlogPostRetrievedCorrectlyFromSlugUrl() throws {
        _ = try testWorld.getResponse(to: blogPostPath)

        XCTAssertEqual(presenter.post?.title, firstData.post.title)
        XCTAssertEqual(presenter.post?.contents, firstData.post.contents)
        XCTAssertEqual(presenter.postAuthor?.name, firstData.author.name)
        XCTAssertEqual(presenter.postAuthor?.username, firstData.author.username)
    }
    
    func testIndexGetsCorrectPageInformation() throws {
        _ = try testWorld.getResponse(to: blogPostPath)
        XCTAssertNil(presenter.postPageInformation?.disqusName)
        XCTAssertNil(presenter.postPageInformation?.googleAnalyticsIdentifier)
        XCTAssertNil(presenter.postPageInformation?.siteTwitterHandler)
        XCTAssertNil(presenter.postPageInformation?.loggedInUser)
        XCTAssertEqual(presenter.postPageInformation?.currentPageURL.absoluteString, blogPostPath)
        XCTAssertEqual(presenter.postPageInformation?.websiteURL.absoluteString, "")
    }
    
    func testIndexPageInformationGetsLoggedInUser() throws {
        let user = testWorld.createUser()
        _ = try testWorld.getResponse(to: blogPostPath, loggedInUser: user)
        XCTAssertEqual(presenter.postPageInformation?.loggedInUser?.username, user.username)
    }
    
    func testSettingEnvVarsWithPageInformation() throws {
        let googleAnalytics = "ABDJIODJWOIJIWO"
        let twitterHandle = "3483209fheihgifffe"
        let disqusName = "34829u48932fgvfbrtewerg"
        setenv("BLOG_GOOGLE_ANALYTICS_IDENTIFIER", googleAnalytics, 1)
        setenv("BLOG_SITE_TWITTER_HANDLER", twitterHandle, 1)
        setenv("BLOG_DISQUS_NAME", disqusName, 1)
        _ = try testWorld.getResponse(to: blogPostPath)
        XCTAssertEqual(presenter.postPageInformation?.disqusName, disqusName)
        XCTAssertEqual(presenter.postPageInformation?.googleAnalyticsIdentifier, googleAnalytics)
        XCTAssertEqual(presenter.postPageInformation?.siteTwitterHandler, twitterHandle)
    }
}
