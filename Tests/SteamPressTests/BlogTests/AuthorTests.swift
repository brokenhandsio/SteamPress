import XCTest
import Vapor
import SteamPress

class AuthorTests: XCTestCase {
    
    // MARK: - allTests
    
    static var allTests = [
        ("testLinuxTestSuiteIncludesAllTests", testLinuxTestSuiteIncludesAllTests),
        ("testAllAuthorsPageGetAllAuthors", testAllAuthorsPageGetAllAuthors),
        ("testAuthorPageGetsOnlyPublishedPostsInDescendingOrder", testAuthorPageGetsOnlyPublishedPostsInDescendingOrder),
        ("testDisabledBlogAuthorsPath", testDisabledBlogAuthorsPath),
        ("testAuthorView", testAuthorView)
    ]
    
    // MARK: - Properties
    private var app: Application!
    private var testWorld: TestWorld!
    private let allAuthorsRequestPath = "/authors"
    private let authorsRequestPath = "/authors/leia"
    private var user: BlogUser!
    private var postData: TestData!
    private var presenter: CapturingBlogPresenter {
        return testWorld.context.blogPresenter
    }
    
    // MARK: - Overrides
    
    override func setUp() {
        testWorld = try! TestWorld.create()
        user = testWorld.createUser(username: "leia")
        postData = try! testWorld.createPost(author: user)
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
    
    func testAllAuthorsPageGetAllAuthors() throws {
        _ = try testWorld.getResponse(to: allAuthorsRequestPath)
        
        XCTAssertEqual(testWorld.context.blogPresenter.allAuthors?.count, 1)
        XCTAssertEqual(presenter.allAuthors?.first?.name, user.name)
    }
    
    func testAuthorPageGetsOnlyPublishedPostsInDescendingOrder() throws {
        let secondPostData = try testWorld.createPost(title: "A later post", author: user)
        _ = try testWorld.createPost(author: user, published: false)
        
        _ = try testWorld.getResponse(to: authorsRequestPath)
        
        XCTAssertEqual(presenter.authorPosts?.count, 2)
        XCTAssertEqual(presenter.authorPosts?.first?.title, secondPostData.post.title)
    }
    
    func testDisabledBlogAuthorsPath() throws {
        testWorld = try TestWorld.create(enableAuthorPages: false)
        _ = testWorld.createUser(username: "leia")
        
        let authorResponse = try testWorld.getResponse(to: authorsRequestPath)
        let allAuthorsResponse = try testWorld.getResponse(to: allAuthorsRequestPath)
        
        XCTAssertEqual(authorResponse.http.status, .notFound)
        XCTAssertEqual(allAuthorsResponse.http.status, .notFound)
    }
    
    func testAuthorView() throws {
        _ = try testWorld.getResponse(to: authorsRequestPath)
        
        XCTAssertEqual(presenter.author?.username, user.username)
        XCTAssertEqual(presenter.authorPosts?.count, 1)
        XCTAssertEqual(presenter.authorPosts?.first?.title, postData.post.title)
        XCTAssertEqual(presenter.authorPosts?.first?.contents, postData.post.contents)
    }
    
}
