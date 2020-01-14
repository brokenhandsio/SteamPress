import XCTest
import SteamPress
import Vapor
import Foundation

class IndexTests: XCTestCase {

    // MARK: - Properties
    var testWorld: TestWorld!
    var firstData: TestData!
    let blogIndexPath = "/"
    let postsPerPage = 10

    var presenter: CapturingBlogPresenter {
        return testWorld.context.blogPresenter
    }

    // MARK: - Overrides

    override func setUp() {
        testWorld = try! TestWorld.create(postsPerPage: postsPerPage)
        firstData = try! testWorld.createPost(title: "Test Path", slugUrl: "test-path")
    }
    
    override func tearDown() {
        XCTAssertNoThrow(try testWorld.tryAsHardAsWeCanToShutdownApplication())
    }

    // MARK: - Tests

    func testBlogIndexGetsPostsInReverseOrder() throws {
        let secondData = try testWorld.createPost(title: "A New Post")

        _ = try testWorld.getResponse(to: blogIndexPath)

        XCTAssertEqual(presenter.indexPosts?.count, 2)
        XCTAssertEqual(presenter.indexPosts?[0].title, secondData.post.title)
        XCTAssertEqual(presenter.indexPosts?[1].title, firstData.post.title)

    }

    func testBlogIndexGetsAllTags() throws {
        let tag = try testWorld.context.repository.addTag(name: "tatooine")

        _ = try testWorld.getResponse(to: blogIndexPath)

        XCTAssertEqual(presenter.indexTags?.count, 1)
        XCTAssertEqual(presenter.indexTags?.first?.name, tag.name)
    }

    func testBlogIndexGetsAllAuthors() throws {
        _ = try testWorld.getResponse(to: blogIndexPath)

        XCTAssertEqual(presenter.indexAuthors?.count, 1)
        XCTAssertEqual(presenter.indexAuthors?.first?.name, firstData.author.name)
    }

    func testThatAccessingPathsRouteRedirectsToBlogIndex() throws {
        let response = try testWorld.getResponse(to: "/posts/")
        XCTAssertEqual(response.http.status, .movedPermanently)
        XCTAssertEqual(response.http.headers[.location].first, "/")
    }

    func testThatAccessingPathsRouteRedirectsToBlogIndexWithCustomPath() throws {
        testWorld = try! TestWorld.create(path: "blog")
        let response = try testWorld.getResponse(to: "/blog/posts/")
        XCTAssertEqual(response.http.status, .movedPermanently)
        XCTAssertEqual(response.http.headers[.location].first, "/blog/")
    }

    // MARK: - Pagination Tests
    func testIndexOnlyGetsTheSpecifiedNumberOfPosts() throws {
        try testWorld.createPosts(count: 15, author: firstData.author)
        _ = try testWorld.getResponse(to: blogIndexPath)
        XCTAssertEqual(presenter.indexPosts?.count, postsPerPage)
    }

    func testIndexGetsCorrectPostsForPage() throws {
        try testWorld.createPosts(count: 15, author: firstData.author)
        _ = try testWorld.getResponse(to: "/?page=2")
        XCTAssertEqual(presenter.indexPosts?.count, 6)
    }

    // This is a bit of a dummy test since it should be handled by the DB
    func testIndexHandlesIncorrectPageCorrectly() throws {
        try testWorld.createPosts(count: 15, author: firstData.author)
        _ = try testWorld.getResponse(to: "/?page=3")
        XCTAssertEqual(presenter.indexPosts?.count, 0)
    }

    func testIndexHandlesNegativePageCorrectly() throws {
        try testWorld.createPosts(count: 15, author: firstData.author)
        _ = try testWorld.getResponse(to: "/?page=-3")
        XCTAssertEqual(presenter.indexPosts?.count, postsPerPage)
    }

    func testIndexHandlesPageAsStringSafely() throws {
        try testWorld.createPosts(count: 15, author: firstData.author)
        _ = try testWorld.getResponse(to: "/?page=three")
        XCTAssertEqual(presenter.indexPosts?.count, postsPerPage)
    }
    
    // MARK: - Page Information
    
    func testIndexGetsCorrectPageInformation() throws {
        _ = try testWorld.getResponse(to: blogIndexPath)
        XCTAssertNil(presenter.indexPageInformation?.disqusName)
        XCTAssertNil(presenter.indexPageInformation?.googleAnalyticsIdentifier)
        XCTAssertNil(presenter.indexPageInformation?.siteTwitterHandle)
        XCTAssertNil(presenter.indexPageInformation?.loggedInUser)
        XCTAssertEqual(presenter.indexPageInformation?.currentPageURL.absoluteString, "/")
        XCTAssertEqual(presenter.indexPageInformation?.websiteURL.absoluteString, "")
    }
    
    func testIndexPageCurrentPageWhenAtSubPath() throws {
        testWorld = try TestWorld.create(path: "blog")
        _ = try testWorld.getResponse(to: "/blog")
        XCTAssertEqual(presenter.indexPageInformation?.currentPageURL.absoluteString, "/blog")
        XCTAssertEqual(presenter.indexPageInformation?.websiteURL.absoluteString, "")
    }
    
    func testIndexPageInformationGetsLoggedInUser() throws {
        _ = try testWorld.getResponse(to: blogIndexPath, loggedInUser: firstData.author)
        XCTAssertEqual(presenter.indexPageInformation?.loggedInUser?.username, firstData.author.username)
    }
    
    func testSettingEnvVarsWithPageInformation() throws {
        let googleAnalytics = "ABDJIODJWOIJIWO"
        let twitterHandle = "3483209fheihgifffe"
        let disqusName = "34829u48932fgvfbrtewerg"
        setenv("BLOG_GOOGLE_ANALYTICS_IDENTIFIER", googleAnalytics, 1)
        setenv("BLOG_SITE_TWITTER_HANDLE", twitterHandle, 1)
        setenv("BLOG_DISQUS_NAME", disqusName, 1)
        _ = try testWorld.getResponse(to: blogIndexPath)
        XCTAssertEqual(presenter.indexPageInformation?.disqusName, disqusName)
        XCTAssertEqual(presenter.indexPageInformation?.googleAnalyticsIdentifier, googleAnalytics)
        XCTAssertEqual(presenter.indexPageInformation?.siteTwitterHandle, twitterHandle)
    }
}
