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

    // MARK: - Tests

    func testBlogPassedToSearchPageCorrectly() throws {
        let response = try testWorld.getResponse(to: "/search?term=Test")

        XCTAssertEqual(response.http.status, .ok)
        XCTAssertEqual(presenter.searchTerm, "Test")
        XCTAssertEqual(presenter.searchPosts?.first?.title, firstData.post.title)
    }

    func testThatSearchTermNilIfEmptySearch() throws {
        let response = try testWorld.getResponse(to: "/search?term=")

        XCTAssertEqual(response.http.status, .ok)
        XCTAssertEqual(presenter.searchPosts?.count, 0)
        XCTAssertNil(presenter.searchTerm)
    }

    func testThatSearchTermNilIfNoSearchTerm() throws {
        let response = try testWorld.getResponse(to: "/search")

        XCTAssertEqual(response.http.status, .ok)
        XCTAssertEqual(presenter.searchPosts?.count, 0)
        XCTAssertNil(presenter.searchTerm)
    }
}
