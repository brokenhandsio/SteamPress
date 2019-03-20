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
    private var testWorld: TestWorld!
    private let authorsRequestPath = "/authors"

    // MARK: - Overrides

    override func setUp() {
        testWorld = try! TestWorld.create()
        
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
//        _ = try testWorld.getResponse(to: authorsRequestPath)
//        XCTAssertEqual("allAuthors", testWorld.context.authorPresenter.allAuthorsURI?.description)
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
        let user = TestDataBuilder.createUser(on: testWorld.context.repository)
        _ = try testWorld.getResponse(to: authorsRequestPath)
        XCTAssertEqual(1, testWorld.context.blogPresenter.allAuthors?.count)
        XCTAssertEqual(user.name, testWorld.context.blogPresenter.allAuthors?.first?.name)
    }

    func testAuthorPageGetsOnlyPublishedPostsInDescendingOrder() throws {
        let firstPostData = try TestDataBuilder.createPost(on: testWorld.context.repository)
        let secondPostData = try TestDataBuilder.createPost(on: testWorld.context.repository, title: "A later post", author: firstPostData.author)
        _ = try TestDataBuilder.createPost(on: testWorld.context.repository, author: firstPostData.author, published: false)
        
        _ = try testWorld.getResponse(to: "/authors/\(firstPostData.author.name)")

        XCTAssertEqual(2, testWorld.context.blogPresenter.authorPosts?.count)
        XCTAssertEqual(secondPostData.post.title, testWorld.context.blogPresenter.authorPosts?.first?.title)
    }

    func testDisabledBlogAuthorsPath() throws {
        testWorld = try TestWorld.create(enableAuthorPages: false)
        let user = TestDataBuilder.createUser(on: testWorld.context.repository)
        
        let authorResponse = try testWorld.getResponse(to: "/authors/\(user.name)")
        let allAuthorsResponse = try testWorld.getResponse(to: "/authors")

        XCTAssertEqual(.notFound, authorResponse.http.status)
        XCTAssertEqual(.notFound, allAuthorsResponse.http.status)
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

//    func setupApp(config: Config? = nil, setupData: Bool = true) throws {
//        app = try TestDataBuilder.getSteamPressApp()
////        drop = try Droplet()
////
////        viewFactory = CapturingViewFactory()
////        let pathCreator = BlogPathCreator(blogPath: nil)
////        let configToUse = config ?? drop.config
////
////        let enableAuthorsPages = configToUse["enableAuthorsPages"]?.bool ?? true
////        let enableTagsPages = configToUse["enableTagsPages"]?.bool ?? true
////
////        let blogController = BlogController(drop: drop, pathCreator: pathCreator, viewFactory: viewFactory, enableAuthorsPages: enableAuthorsPages, enableTagsPages: enableTagsPages)
////        blogController.addRoutes()
////
////        let blogAdminController = BlogAdminController(drop: drop, pathCreator: pathCreator, viewFactory: viewFactory)
////        blogAdminController.addRoutes()
////
////        if setupData {
////            user = TestDataBuilder.anyUser()
////            try user.save()
////            post = BlogPost(title: "Test Path", contents: "A long time ago", author: user, creationDate: Date(), slugUrl: "test-path", published: true)
////            try post.save()
////
////            try BlogTag.addTag("tatooine", to: post)
////        }
//    }

}
