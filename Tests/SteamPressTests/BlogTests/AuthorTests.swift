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
        let user = testWorld.createUser()
        _ = try testWorld.getResponse(to: authorsRequestPath)
        XCTAssertEqual(1, testWorld.context.blogPresenter.allAuthors?.count)
        XCTAssertEqual(user.name, testWorld.context.blogPresenter.allAuthors?.first?.name)
    }

    func testAuthorPageGetsOnlyPublishedPostsInDescendingOrder() throws {
        let firstPostData = try TestDataBuilder.createPost(on: testWorld.context.repository)
        let secondPostData = try testWorld.createPost(title: "A later post", author: firstPostData.author)
        _ = try testWorld.createPost(author: firstPostData.author, published: false)
        
        _ = try testWorld.getResponse(to: "/authors/\(firstPostData.author.name)")

        XCTAssertEqual(2, testWorld.context.blogPresenter.authorPosts?.count)
        XCTAssertEqual(secondPostData.post.title, testWorld.context.blogPresenter.authorPosts?.first?.title)
    }

    func testDisabledBlogAuthorsPath() throws {
        testWorld = try TestWorld.create(enableAuthorPages: false)
        let user = testWorld.createUser()
        
        let authorResponse = try testWorld.getResponse(to: "/authors/\(user.name)")
        let allAuthorsResponse = try testWorld.getResponse(to: "/authors")

        XCTAssertEqual(.notFound, authorResponse.http.status)
        XCTAssertEqual(.notFound, allAuthorsResponse.http.status)
    }

    func testAuthorView() throws {
        let data = try TestDataBuilder.createPost(on: testWorld.context.repository)
        
        _ = try testWorld.getResponse(to: "/authors/\(data.author.name)")

        XCTAssertEqual(testWorld.context.blogPresenter.author?.username, data.author.username)
        XCTAssertEqual(testWorld.context.blogPresenter.authorPosts?.count, 1)
        XCTAssertEqual(testWorld.context.blogPresenter.authorPosts?.first?.title, data.post.title)
        XCTAssertEqual(testWorld.context.blogPresenter.authorPosts?.first?.contents, data.post.contents)
    }

}
