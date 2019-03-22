import XCTest
//@testable import SteamPress
import SteamPress
import Vapor
//import Fluent
//import HTTP
import Foundation

class BlogControllerTests: XCTestCase {
  
  
    // MARK: - all tests
    static var allTests = [
        ("testLinuxTestSuiteIncludesAllTests", testLinuxTestSuiteIncludesAllTests),
        ("testBlogIndexGetsPostsInReverseOrder", testBlogIndexGetsPostsInReverseOrder),
//        ("testBlogIndexGetsAllTags", testBlogIndexGetsAllTags),
//        ("testBlogIndexGetsAllAuthors", testBlogIndexGetsAllAuthors),
//        ("testBlogPostRetrievedCorrectlyFromSlugUrl", testBlogPostRetrievedCorrectlyFromSlugUrl),
//        ("testThatAccessingPathsRouteRedirectsToBlogIndex", testThatAccessingPathsRouteRedirectsToBlogIndex),
//        ("testAuthorView", testAuthorView),
//        ("testTagView", testTagView),
//        ("testIndexPageGetsUri", testIndexPageGetsUri),
//        ("testIndexPageGetsHTTPSUriFromReverseProxy", testIndexPageGetsHTTPSUriFromReverseProxy),
//        ("testBlogPageGetsUri", testBlogPageGetsUri),
//        ("testHTTPSPassedThroughToBlogPageURI", testHTTPSPassedThroughToBlogPageURI),
//        ("testHTTPSURIPassedThroughAsBlogPageURIIfAccessingViaReverseProxyOverHTTPS", testHTTPSURIPassedThroughAsBlogPageURIIfAccessingViaReverseProxyOverHTTPS),
//        ("testBlogPostPageGetHTPSURIFromReverseProxyLowerCase", testBlogPostPageGetHTPSURIFromReverseProxyLowerCase),
//        ("testProfilePageGetsUri", testProfilePageGetsUri),
//        ("testProfilePageGetsHTTPSUriFromReverseProxy", testProfilePageGetsHTTPSUriFromReverseProxy),
//        ("testTagPageGetsUri", testTagPageGetsUri),
//        ("testTagPageGetsHTTPSUriFromReverseProxy", testTagPageGetsHTTPSUriFromReverseProxy),
//        ("testAllAuthorsPageGetsUri", testAllAuthorsPageGetsUri),
//        ("testAllAuthorsPageGetsHTTPSUriFromReverseProxy", testAllAuthorsPageGetsHTTPSUriFromReverseProxy),
//        ("testAllTagsPageGetsUri", testAllTagsPageGetsUri),
//        ("testAllTagsPageGetsHTTPSUriFromReverseProxy", testAllTagsPageGetsHTTPSUriFromReverseProxy),
//        ("testAllTagsPageGetsAllTags", testAllTagsPageGetsAllTags),
//        ("testAllAuthorsPageGetAllAuthors", testAllAuthorsPageGetAllAuthors),
//        ("testTagPageGetsOnlyPublishedPostsInDescendingOrder", testTagPageGetsOnlyPublishedPostsInDescendingOrder),
//        ("testAuthorPageGetsOnlyPublishedPostsInDescendingOrder", testAuthorPageGetsOnlyPublishedPostsInDescendingOrder),
//        ("testDisabledBlogAuthorsPath", testDisabledBlogAuthorsPath),
//        ("testDisabledBlogTagsPath", testDisabledBlogTagsPath),
//        ("testBlogPassedToSearchPageCorrectly", testBlogPassedToSearchPageCorrectly),
//        ("testThatFlagSetIfEmptySearch", testThatFlagSetIfEmptySearch),
//        ("testThatFlagSetIfNoSearchTerm", testThatFlagSetIfNoSearchTerm),
    ]

    // MARK: - Properties
    var testWorld: TestWorld!
    var firstData: TestData!
    private let blogIndexPath = "/"
    private let blogPostPath = "/posts/test-path/"
//    private let tagPath = "/tags/tatooine/"
//    private let authorPath = "/authors/luke/"
//    private let allAuthorsPath = "/authors/"
//    private let allTagsPath = "/tags/"
    
    var presenter: CapturingBlogPresenter {
        return testWorld.context.blogPresenter
    }

    // MARK: - Overrides
    
    override func setUp() {
        testWorld = try! TestWorld.create()
        firstData = try! testWorld.createPost(title: "Test Path", slugUrl: "test-path")
    }

    override func tearDown() {
//        try! Droplet.teardown(database: database)
    }
    
    //

//    func setupDrop(config: Config? = nil, setupData: Bool = true) throws {
//        drop = try Droplet()
//
//        viewFactory = CapturingViewFactory()
//        let pathCreator = BlogPathCreator(blogPath: nil)
//        let configToUse = config ?? drop.config
//
//        let enableAuthorsPages = configToUse["enableAuthorsPages"]?.bool ?? true
//        let enableTagsPages = configToUse["enableTagsPages"]?.bool ?? true
//
//        let blogController = BlogController(drop: drop, pathCreator: pathCreator, viewFactory: viewFactory, enableAuthorsPages: enableAuthorsPages, enableTagsPages: enableTagsPages)
//        blogController.addRoutes()
//
//        let blogAdminController = BlogAdminController(drop: drop, pathCreator: pathCreator, viewFactory: viewFactory)
//        blogAdminController.addRoutes()
//
//        if setupData {
//            user = TestDataBuilder.anyUser()
//            try user.save()
//            post = BlogPost(title: "Test Path", contents: "A long time ago", author: user, creationDate: Date(), slugUrl: "test-path", published: true)
//            try post.save()
//
//            try BlogTag.addTag("tatooine", to: post)
//        }
//    }
    
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

    func testBlogIndexGetsPostsInReverseOrder() throws {
        let secondData = try testWorld.createPost(title: "A New Post")

        _ = try testWorld.getResponse(to: blogIndexPath)

        XCTAssertEqual(presenter.indexPosts?.count, 2)
        XCTAssertEqual(presenter.indexPosts?[0].title, secondData.post.title)
        XCTAssertEqual(presenter.indexPosts?[1].title, firstData.post.title)

    }

    func testBlogIndexGetsAllTags() throws {
        let tagName = "tatooine"
        try testWorld.context.repository.addTag(name: tagName)
        
        _ = try testWorld.getResponse(to: blogIndexPath)

        XCTAssertEqual(presenter.indexTags?.count, 1)
        XCTAssertEqual(presenter.indexTags?.first?.name, tagName)
    }

    func testBlogIndexGetsAllAuthors() throws {
        _ = try testWorld.getResponse(to: blogIndexPath)

        XCTAssertEqual(presenter.indexAuthors?.count, 1)
        XCTAssertEqual(presenter.indexAuthors?.first?.name, firstData.author.name)
    }

    func testBlogPostRetrievedCorrectlyFromSlugUrl() throws {
        _ = try testWorld.getResponse(to: blogPostPath)

        XCTAssertEqual(presenter.post?.title, firstData.post.title)
        XCTAssertEqual(presenter.post?.contents, firstData.post.contents)
        XCTAssertEqual(presenter.postAuthor?.name, firstData.author.name)
        XCTAssertEqual(presenter.postAuthor?.username, firstData.author.username)
    }

    func testThatAccessingPathsRouteRedirectsToBlogIndex() throws {
        let response = try testWorld.getResponse(to: "/posts/")
        XCTAssertEqual(response.http.status, .movedPermanently)
        XCTAssertEqual(response.http.headers[.location].first, "/")
    }

//    func testIndexPageGetsUri() throws {
//        try setupDrop()
//
//        _ = try drop.respond(to: blogIndexRequest)
//
//        XCTAssertEqual(blogIndexPath, viewFactory.blogIndexURI?.description)
//    }
//
//    func testIndexPageGetsHTTPSUriFromReverseProxy() throws {
//        try setupDrop()
//
//        let httpsReverseProxyRequest = Request(method: .get, uri: "http://geeks.brokenhands.io\(blogIndexPath)")
//        httpsReverseProxyRequest.headers["X-Forwarded-Proto"] = "https"
//
//        _ = try drop.respond(to: httpsReverseProxyRequest)
//
//        XCTAssertEqual("https://geeks.brokenhands.io/", viewFactory.blogIndexURI?.descriptionWithoutPort)
//    }
//
//    func testBlogPageGetsUri() throws {
//        try setupDrop()
//
//        _ = try drop.respond(to: blogPostRequest)
//
//        XCTAssertEqual(blogPostPath, viewFactory.blogPostURI?.description)
//    }
//
//    func testHTTPSPassedThroughToBlogPageURI() throws {
//        try setupDrop()
//
//        let httpsRequest = Request(method: .get, uri: "https://localhost\(blogPostPath)")
//        _ = try drop.respond(to: httpsRequest)
//
//        XCTAssertEqual("https://localhost/posts/test-path/", viewFactory.blogPostURI?.descriptionWithoutPort)
//    }
//
//    func testHTTPSURIPassedThroughAsBlogPageURIIfAccessingViaReverseProxyOverHTTPS() throws {
//        try setupDrop()
//
//        let httpsReverseProxyRequest = Request(method: .get, uri: "http://geeks.brokenhands.io\(blogPostPath)")
//        httpsReverseProxyRequest.headers["X-Forwarded-Proto"] = "https"
//
//        _ = try drop.respond(to: httpsReverseProxyRequest)
//
//        XCTAssertEqual("https://geeks.brokenhands.io/posts/test-path/", viewFactory.blogPostURI?.descriptionWithoutPort)
//    }
//
//    func testBlogPostPageGetHTPSURIFromReverseProxyLowerCase() throws {
//        try setupDrop()
//
//        let httpsReverseProxyRequest = Request(method: .get, uri: "http://geeks.brokenhands.io\(blogPostPath)")
//        httpsReverseProxyRequest.headers["x-forwarded-proto"] = "https"
//
//        _ = try drop.respond(to: httpsReverseProxyRequest)
//
//        XCTAssertEqual("https://geeks.brokenhands.io/posts/test-path/", viewFactory.blogPostURI?.descriptionWithoutPort)
//    }
    
//    func testBlogPassedToSearchPageCorrectly() throws {
//        try setupDrop()
//        let searchRequest = Request(method: .get, uri: "/search?term=Test")
//        let searchResponse = try drop.respond(to: searchRequest)
//
//        XCTAssertEqual(searchResponse.status, .ok)
//        XCTAssertEqual(viewFactory.searchTerm, "Test")
//        XCTAssertEqual(viewFactory.searchPosts?.data[0].title, post.title)
//        XCTAssertFalse(viewFactory.emptySearch ?? true)
//    }
//
//    func testThatFlagSetIfEmptySearch() throws {
//        try setupDrop()
//        let searchRequest = Request(method: .get, uri: "/search?term=")
//        let searchResponse = try drop.respond(to: searchRequest)
//
//        XCTAssertEqual(searchResponse.status, .ok)
//        XCTAssertNil(viewFactory.searchPosts)
//        XCTAssertTrue(viewFactory.emptySearch ?? false)
//    }
//
//    func testThatFlagSetIfNoSearchTerm() throws {
//        try setupDrop()
//        let searchRequest = Request(method: .get, uri: "/search")
//        let searchResponse = try drop.respond(to: searchRequest)
//
//        XCTAssertEqual(searchResponse.status, .ok)
//        XCTAssertNil(viewFactory.searchPosts)
//        XCTAssertTrue(viewFactory.emptySearch ?? false)
//    }
}
