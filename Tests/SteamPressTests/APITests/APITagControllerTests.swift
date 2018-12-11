import XCTest
import Vapor
import SteamPress

class APITagControllerTests: XCTestCase {
    
    // MARK: - allTests
    
    static var allTests = [
        ("testLinuxTestSuiteIncludesAllTests", testLinuxTestSuiteIncludesAllTests),
        ("testThatAllTagsAreReturnedFromAPI", testThatAllTagsAreReturnedFromAPI),
        ]
    
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
    
    func testThatAllTagsAreReturnedFromAPI() throws {
        let testWorld = try TestWorld.create()
        
        let tag1 = "Vapor 3"
        let tag2 = "Engineering"
        
        testWorld.context.repository.addTag(name: tag1)
        testWorld.context.repository.addTag(name: tag2)
        
        let tags = try testWorld.getResponse(to: "/api/tags", decodeTo: [BlogTagJSON].self)
        
        XCTAssertEqual(tags[0].name, tag1)
        XCTAssertEqual(tags[1].name, tag2)
    }
}

struct BlogTagJSON: Content {
    let name: String
}
