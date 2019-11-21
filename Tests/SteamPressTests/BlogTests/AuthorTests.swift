import XCTest
import Vapor
import SteamPress

class AuthorTests: XCTestCase {
    
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
    private var postsPerPage = 7
    
    // MARK: - Overrides
    
    override func setUp() {
        testWorld = try! TestWorld.create(postsPerPage: postsPerPage)
        user = testWorld.createUser(username: "leia")
        postData = try! testWorld.createPost(author: user)
    }
    
    // MARK: - Tests
    
    func testAllAuthorsPageGetAllAuthorsAndDoesNotShowAdminUser() throws {
        _ = try testWorld.getResponse(to: allAuthorsRequestPath)
        
        XCTAssertEqual(testWorld.context.blogPresenter.allAuthors?.count, 2)
        XCTAssertEqual(presenter.allAuthors?.last?.name, user.name)
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
    
    // MARK: - Pagination Tests
    func testAuthorViewOnlyGetsTheSpecifiedNumberOfPosts() throws {
        try testWorld.createPosts(count: 15, author: user)
        _ = try testWorld.getResponse(to: authorsRequestPath)
        XCTAssertEqual(presenter.authorPosts?.count, postsPerPage)
    }
    
    func testAuthorViewGetsCorrectPostsForPage() throws {
        try testWorld.createPosts(count: 15, author: user)
        _ = try testWorld.getResponse(to: "/authors/leia?page=3")
        XCTAssertEqual(presenter.authorPosts?.count, 2)
    }
    
}
