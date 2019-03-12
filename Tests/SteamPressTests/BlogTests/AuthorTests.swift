import XCTest
import Vapor

class AuthorTests: XCTestCase {

    // MARK: - allTests

    static var allTests = [
        ("testLinuxTestSuiteIncludesAllTests", testLinuxTestSuiteIncludesAllTests),
        ("testAllAuthorsPageGetsUri", testAllAuthorsPageGetsUri),
        ("testAllAuthorsPageGetsHTTPSUriFromReverseProxy", testAllAuthorsPageGetsHTTPSUriFromReverseProxy),
        ("testAuthorView", testAuthorView),
        ("testAllAuthorsPageGetAllAuthors", testAllAuthorsPageGetAllAuthors),
        ("testAuthorPageGetsOnlyPublishedPostsInDescendingOrder", testAuthorPageGetsOnlyPublishedPostsInDescendingOrder),
        ("testDisabledBlogAuthorsPath", testDisabledBlogAuthorsPath),
        ]

    // MARK: - Properties
    private var app: Application!
    private var capturingAuthorPresenter: CapturingAuthorPresenter!

    // MARK: - Overrides

    override func setUp() {
        capturingAuthorPresenter = CapturingAuthorPresenter()
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

    func testAllAuthorsPageGetsUri() throws {
        app = try TestDataBuilder.getSteamPressApp(authorPresenter: capturingAuthorPresenter)

//        try setupDrop()
//
//        _ = try drop.respond(to: allAuthorsRequest)
//
//        XCTAssertEqual(allAuthorsPath, viewFactory.allAuthorsURI?.description)
        XCTFail("Implement")
    }

    func testAllAuthorsPageGetsHTTPSUriFromReverseProxy() throws {
//        try setupDrop()
//
//        let httpsReverseProxyRequest = Request(method: .get, uri: "http://geeks.brokenhands.io\(allAuthorsPath)")
//        httpsReverseProxyRequest.headers["X-Forwarded-Proto"] = "https"
//
//        _ = try drop.respond(to: httpsReverseProxyRequest)
//
//        XCTAssertEqual("https://geeks.brokenhands.io/authors/", viewFactory.allAuthorsURI?.descriptionWithoutPort)
        XCTFail("Implement")
    }

    func testAllAuthorsPageGetAllAuthors() throws {
//        try setupDrop()
//        _ = try drop.respond(to: allAuthorsRequest)
//
//        XCTAssertEqual(1, viewFactory.allAuthorsPageAuthors?.count)
//        XCTAssertEqual("Luke", viewFactory.allAuthorsPageAuthors?.first?.name)
        XCTFail("Implement")
    }

    func testAuthorPageGetsOnlyPublishedPostsInDescendingOrder() throws {
//        try setupDrop()
//        let post2 = TestDataBuilder.anyPost(author: self.user, title: "A later post")
//        try post2.save()
//        let draftPost = TestDataBuilder.anyPost(author: self.user, published: false)
//        try draftPost.save()
//        _ = try drop.respond(to: authorRequest)
//
//        XCTAssertEqual(2, viewFactory.authorPosts?.total)
//        XCTAssertEqual(post2.title, viewFactory.authorPosts?.data[0].title)
        XCTFail("Implement")
    }

    func testDisabledBlogAuthorsPath() throws {
//        let config = Config(try Node(node: [
//            "enableAuthorsPages": false
//        ]))
//
//        try setupDrop(config: config)
//
//        let authorResponse = try drop.respond(to: authorRequest)
//        let allAuthorsResponse = try drop.respond(to: allAuthorsRequest)
//
//        XCTAssertEqual(404, authorResponse.status.statusCode)
//        XCTAssertEqual(404, allAuthorsResponse.status.statusCode)
        XCTFail("Implement")
    }

    func testAuthorView() throws {
//        try setupDrop()
//        _ = try drop.respond(to: authorRequest)
//
//        XCTAssertEqual(viewFactory.author?.username, user.username)
//        XCTAssertEqual(viewFactory.authorPosts?.total, 1)
//        XCTAssertEqual(viewFactory.authorPosts?.data[0].title, post.title)
//        XCTAssertEqual(viewFactory.authorPosts?.data[0].contents, post.contents)
        XCTFail("Implement")
    }

    // MARK: - Private

    func setupApp(config: Config? = nil, setupData: Bool = true) throws {
        app = try TestDataBuilder.getSteamPressApp()
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
    }

}
