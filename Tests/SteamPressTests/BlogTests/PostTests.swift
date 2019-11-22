import XCTest
import SteamPress
import Vapor
import Foundation

class PostTests: XCTestCase {

    // MARK: - Properties
    var testWorld: TestWorld!
    var firstData: TestData!
    private let blogPostPath = "/posts/test-path/"

    var presenter: CapturingBlogPresenter {
        return testWorld.context.blogPresenter
    }

    // MARK: - Overrides

    override func setUp() {
        testWorld = try! TestWorld.create()
        firstData = try! testWorld.createPost(title: "Test Path", slugUrl: "test-path")
    }

    // MARK: - Tests

    func testBlogPostRetrievedCorrectlyFromSlugUrl() throws {
        _ = try testWorld.getResponse(to: blogPostPath)

        XCTAssertEqual(presenter.post?.title, firstData.post.title)
        XCTAssertEqual(presenter.post?.contents, firstData.post.contents)
        XCTAssertEqual(presenter.postAuthor?.name, firstData.author.name)
        XCTAssertEqual(presenter.postAuthor?.username, firstData.author.username)
    }
}
