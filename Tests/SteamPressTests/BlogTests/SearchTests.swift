import XCTest
import SteamPress
import Vapor
import Foundation

class SearchTests: XCTestCase {
    
    
    // MARK: - all tests
    static var allTests = [
        ("testLinuxTestSuiteIncludesAllTests", testLinuxTestSuiteIncludesAllTests),
        ("testBlogPassedToSearchPageCorrectly", testBlogPassedToSearchPageCorrectly),
        ("testThatSearchTermNilIfEmptySearch", testThatSearchTermNilIfEmptySearch),
        ("testThatSearchTermNilIfNoSearchTerm", testThatSearchTermNilIfNoSearchTerm),
        ]
    
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
    
    func testBlogPassedToSearchPageCorrectly() throws {
        let response = try testWorld.getResponse(to: "/search?term=Test")
        
        XCTAssertEqual(response.http.status, .ok)
        XCTAssertEqual(presenter.searchTerm, "Test")
        XCTAssertEqual(presenter.searchPosts?.first?.title, firstData.post.title)
    }
    
    func testThatSearchTermNilIfEmptySearch() throws {
        let response = try testWorld.getResponse(to: "/search?term=")
        
        XCTAssertEqual(response.http.status, .ok)
        XCTAssertNil(presenter.searchPosts)
        XCTAssertNil(presenter.searchTerm)
    }
    
    func testThatSearchTermNilIfNoSearchTerm() throws {
        let response = try testWorld.getResponse(to: "/search")
        
        XCTAssertEqual(response.http.status, .ok)
        XCTAssertNil(presenter.searchPosts)
        XCTAssertNil(presenter.searchTerm)
    }
}

