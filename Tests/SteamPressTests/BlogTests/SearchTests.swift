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

        XCTAssertEqual(response.status, .ok)
        XCTAssertEqual(presenter.searchTerm, "Test")
        XCTAssertEqual(presenter.searchTotalResults, 1)
        XCTAssertEqual(presenter.searchPosts?.first?.title, firstData.post.title)
    }

    func testThatSearchTermNilIfEmptySearch() throws {
        let response = try testWorld.getResponse(to: "/search?term=")

        XCTAssertEqual(response.status, .ok)
        XCTAssertEqual(presenter.searchPosts?.count, 0)
        XCTAssertNil(presenter.searchTerm)
    }

    func testThatSearchTermNilIfNoSearchTerm() throws {
        let response = try testWorld.getResponse(to: "/search")

        XCTAssertEqual(response.status, .ok)
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
        XCTAssertEqual(presenter.searchPageInformation?.websiteURL.absoluteString, "/")
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
    
    func testPaginationInfoSetCorrectly() throws {
        try testWorld.createPosts(count: 15, author: firstData.author)
        _ = try testWorld.getResponse(to: "/search?term=Test&page=1")
        XCTAssertEqual(presenter.searchPaginationTagInfo?.currentPage, 1)
        XCTAssertEqual(presenter.searchPaginationTagInfo?.totalPages, 1)
        XCTAssertEqual(presenter.searchPaginationTagInfo?.currentQuery, "term=Test&page=1")
    }
    
    func testTagsForSearchPostsSetCorrectly() throws {
        let post2 = try testWorld.createPost(title: "Test Search", author: firstData.author)
        let post3 = try testWorld.createPost(title: "Test Tags", author: firstData.author)
        let tag1Name = "Testing"
        let tag2Name = "Search"
        let tag1 = try testWorld.createTag(tag1Name, on: post2.post)
        _ = try testWorld.createTag(tag2Name, on: firstData.post)
        try testWorld.context.repository.add(tag1, to: firstData.post)
        
        _ = try testWorld.getResponse(to: "/search?term=Test")
        let tagsForPosts = try XCTUnwrap(presenter.searchPageTagsForPost)
        XCTAssertNil(tagsForPosts[post3.post.blogID!])
        XCTAssertEqual(tagsForPosts[post2.post.blogID!]?.count, 1)
        XCTAssertEqual(tagsForPosts[post2.post.blogID!]?.first?.name, tag1Name)
        XCTAssertEqual(tagsForPosts[firstData.post.blogID!]?.count, 2)
        XCTAssertEqual(tagsForPosts[firstData.post.blogID!]?.first?.name, tag1Name)
        XCTAssertEqual(tagsForPosts[firstData.post.blogID!]?.last?.name, tag2Name)
    }
}
