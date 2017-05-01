import XCTest
@testable import SteamPress
import Fluent
import Vapor

class BlogTagTests: XCTestCase {

    static var allTests = [
        ("testMakeNodeContainsUrlEncodedName", testMakeNodeContainsUrlEncodedName),
    ]

    func testMakeNodeContainsUrlEncodedName() throws {
        let tag = BlogTag(name: "Luke's Tatooine")
        let node = try tag.makeNode(in: nil)
        XCTAssertEqual(node["url_encoded_name"], "Luke's%20Tatooine")
    }
    
}
