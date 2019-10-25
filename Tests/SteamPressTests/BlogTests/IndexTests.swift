import XCTest
import SteamPress
import Vapor
import Foundation

class IndexTests: XCTestCase {
    
    // MARK: - Properties
    var testWorld: TestWorld!
    var firstData: TestData!
    private let blogIndexPath = "/"
    
    var presenter: CapturingBlogPresenter {
        return testWorld.context.blogPresenter
    }
    
    // MARK: - Overrides
    
    override func setUp() {
        testWorld = try! TestWorld.create()
        firstData = try! testWorld.createPost(title: "Test Path", slugUrl: "test-path")
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
}

