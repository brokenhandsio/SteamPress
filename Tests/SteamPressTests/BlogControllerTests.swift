//import XCTest
//@testable import SteamPress
//import Vapor
//import Fluent
//import HTTP
//import Foundation
//
//class BlogControllerTests: XCTestCase {
//    static var allTests = [
//        ("testLinuxTestSuiteIncludesAllTests", testLinuxTestSuiteIncludesAllTests),
//        ("testBlogIndexGetsPostsInReverseOrder", testBlogIndexGetsPostsInReverseOrder),
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
//    ]
//
//    private var drop: Droplet!
//    private var database: Database!
//    private var viewFactory: CapturingViewFactory!
//    private var post: BlogPost!
//    private var user: BlogUser!
//    private let blogIndexPath = "/"
//    private let blogPostPath = "/posts/test-path/"
//    private let tagPath = "/tags/tatooine/"
//    private let authorPath = "/authors/luke/"
//    private let allAuthorsPath = "/authors/"
//    private let allTagsPath = "/tags/"
//    private var blogPostRequest: Request!
//    private var authorRequest: Request!
//    private var tagRequest: Request!
//    private var blogIndexRequest: Request!
//    private var allTagsRequest: Request!
//    private var allAuthorsRequest: Request!
//
//    override func setUp() {
//        blogPostRequest = Request(method: .get, uri: blogPostPath)
//        authorRequest = Request(method: .get, uri: authorPath)
//        tagRequest = Request(method: .get, uri: tagPath)
//        blogIndexRequest = Request(method: .get, uri: blogIndexPath)
//        allTagsRequest = Request(method: .get, uri: allTagsPath)
//        allAuthorsRequest = Request(method: .get, uri: allAuthorsPath)
//        database = try! Database(MemoryDriver())
//        try! Droplet.prepare(database: database)
//    }
//
//    override func tearDown() {
//        try! Droplet.teardown(database: database)
//    }
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
//
//    func testLinuxTestSuiteIncludesAllTests() {
//        #if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
//            let thisClass = type(of: self)
//            let linuxCount = thisClass.allTests.count
//            let darwinCount = Int(thisClass
//                .defaultTestSuite.testCaseCount)
//            XCTAssertEqual(linuxCount, darwinCount,
//                           "\(darwinCount - linuxCount) tests are missing from allTests")
//        #endif
//    }
//
//    func testBlogIndexGetsPostsInReverseOrder() throws {
//        try setupDrop()
//
//        let post2 = BlogPost(title: "A New Path", contents: "In a galaxy far, far, away", author: user, creationDate: Date(), slugUrl: "a-new-path", published: true)
//        try post2.save()
//
//        _ = try drop.respond(to: blogIndexRequest)
//
//        XCTAssertEqual(viewFactory.paginatedPosts?.total, 2)
//        XCTAssertEqual(viewFactory.paginatedPosts?.data[0].title, "A New Path")
//        XCTAssertEqual(viewFactory.paginatedPosts?.data[1].title, "Test Path")
//
//    }
//
//    func testBlogIndexGetsAllTags() throws {
//        try setupDrop()
//        _ = try drop.respond(to: blogIndexRequest)
//
//        XCTAssertEqual(viewFactory.blogIndexTags?.count, 1)
//        XCTAssertEqual(viewFactory.blogIndexTags?.first?.name, "tatooine")
//    }
//
//    func testBlogIndexGetsAllAuthors() throws {
//        try setupDrop()
//        _ = try drop.respond(to: blogIndexRequest)
//
//        XCTAssertEqual(viewFactory.blogIndexAuthors?.count, 1)
//        XCTAssertEqual(viewFactory.blogIndexAuthors?.first?.name, "Luke")
//    }
//
//    func testBlogPostRetrievedCorrectlyFromSlugUrl() throws {
//        try setupDrop()
//        _ = try drop.respond(to: blogPostRequest)
//
//        XCTAssertEqual(viewFactory.blogPost?.title, post.title)
//        XCTAssertEqual(viewFactory.blogPost?.contents, post.contents)
//        XCTAssertEqual(viewFactory.blogPostAuthor?.name, user.name)
//        XCTAssertEqual(viewFactory.blogPostAuthor?.username, user.username)
//    }
//
//    func testThatAccessingPathsRouteRedirectsToBlogIndex() throws {
//        try setupDrop()
//        let request = Request(method: .get, uri: "/posts/")
//        let response = try drop.respond(to: request)
//        XCTAssertEqual(response.status, .movedPermanently)
//        XCTAssertEqual(response.headers[HeaderKey.location], "/")
//    }
//
//    func testTagView() throws {
//        try setupDrop()
//        _ = try drop.respond(to: tagRequest)
//
//        XCTAssertEqual(viewFactory.tagPosts?.total, 1)
//        XCTAssertEqual(viewFactory.tagPosts?.data[0].title, post.title)
//        XCTAssertEqual(viewFactory.tag?.name, "tatooine")
//    }
//
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
//
//    func testProfilePageGetsUri() throws {
//        try setupDrop()
//
//        _ = try drop.respond(to: authorRequest)
//
//        XCTAssertEqual(authorPath, viewFactory.authorURI?.description)
//    }
//
//    func testProfilePageGetsHTTPSUriFromReverseProxy() throws {
//        try setupDrop()
//
//        let httpsReverseProxyRequest = Request(method: .get, uri: "http://geeks.brokenhands.io\(authorPath)")
//        httpsReverseProxyRequest.headers["X-Forwarded-Proto"] = "https"
//
//        _ = try drop.respond(to: httpsReverseProxyRequest)
//
//        XCTAssertEqual("https://geeks.brokenhands.io/authors/luke/", viewFactory.authorURI?.descriptionWithoutPort)
//    }
//
//    func testTagPageGetsUri() throws {
//        try setupDrop()
//
//        _ = try drop.respond(to: tagRequest)
//
//        XCTAssertEqual(tagPath, viewFactory.tagURI?.description)
//    }
//
//    func testTagPageGetsHTTPSUriFromReverseProxy() throws {
//        try setupDrop()
//
//        let httpsReverseProxyRequest = Request(method: .get, uri: "http://geeks.brokenhands.io\(tagPath)")
//        httpsReverseProxyRequest.headers["X-Forwarded-Proto"] = "https"
//
//        _ = try drop.respond(to: httpsReverseProxyRequest)
//
//        XCTAssertEqual("https://geeks.brokenhands.io/tags/tatooine/", viewFactory.tagURI?.descriptionWithoutPort)
//    }
//
//    func testAllTagsPageGetsUri() throws {
//        try setupDrop()
//
//        _ = try drop.respond(to: allTagsRequest)
//
//        XCTAssertEqual(allTagsPath, viewFactory.allTagsURI?.description)
//    }
//
//    func testAllTagsPageGetsHTTPSUriFromReverseProxy() throws {
//        try setupDrop()
//
//        let httpsReverseProxyRequest = Request(method: .get, uri: "http://geeks.brokenhands.io\(allTagsPath)")
//        httpsReverseProxyRequest.headers["X-Forwarded-Proto"] = "https"
//
//        _ = try drop.respond(to: httpsReverseProxyRequest)
//
//        XCTAssertEqual("https://geeks.brokenhands.io/tags/", viewFactory.allTagsURI?.descriptionWithoutPort)
//    }
//
//    func testAllTagsPageGetsAllTags() throws {
//        try setupDrop()
//        _ = try drop.respond(to: allTagsRequest)
//
//        XCTAssertEqual(1, viewFactory.allTagsPageTags?.count)
//        XCTAssertEqual("tatooine", viewFactory.allTagsPageTags?.first?.name)
//    }
//
//    func testTagPageGetsOnlyPublishedPostsInDescendingOrder() throws {
//        try setupDrop()
//        let post2 = TestDataBuilder.anyPost(author: self.user, title: "A later post")
//        try post2.save()
//        let draftPost = TestDataBuilder.anyPost(author: self.user, published: false)
//        try draftPost.save()
//        try BlogTag.addTag("tatooine", to: post2)
//        try BlogTag.addTag("tatooine", to: draftPost)
//        _ = try drop.respond(to: tagRequest)
//
//        XCTAssertEqual(2, viewFactory.tagPosts?.total)
//        XCTAssertEqual(post2.title, viewFactory.tagPosts?.data.first?.title)
//    }
//
//    func testDisabledBlogTagsPath() throws {
//        let config = Config(try Node(node: [
//            "enableTagsPages": false
//        ]))
//
//        try setupDrop(config: config)
//
//        let tagResponse = try drop.respond(to: tagRequest)
//        let allTagsResponse = try drop.respond(to: allTagsRequest)
//
//        XCTAssertEqual(404, tagResponse.status.statusCode)
//        XCTAssertEqual(404, allTagsResponse.status.statusCode)
//    }
//
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
//}
