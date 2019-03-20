import XCTest
@testable import SteamPress
import Vapor

class BlogTagTests: XCTestCase {

    static var allTests = [
        ("testLinuxTestSuiteIncludesAllTests", testLinuxTestSuiteIncludesAllTests),
        ("testMakeNodeContainsUrlEncodedName", testMakeNodeContainsUrlEncodedName),
    ]
    
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

    func testMakeNodeContainsUrlEncodedName() throws {
        let tag = try BlogTag(name: "Luke's Tatooine")
        XCTAssertEqual(tag.name, "Luke's%20Tatooine")
    }

}
