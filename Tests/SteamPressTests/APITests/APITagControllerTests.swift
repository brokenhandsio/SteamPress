import XCTest
import Vapor
import SteamPress

class APITagControllerTests: XCTestCase {

    // MARK: - Properties
    var testWorld: TestWorld!
    
    // MARK: - Overrides
    
    override func setUp() {
        testWorld = TestWorld.create()
    }
    
    override func tearDownWithError() throws {
        try testWorld.shutdown()
    }
    
    // MARK: - Tests

    func testThatAllTagsAreReturnedFromAPI() throws {
        let tag1 = try testWorld.context.repository.addTag(name: "Vapor3")
        let tag2 = try testWorld.context.repository.addTag(name: "Engineering")

        let tags = try testWorld.getResponse(to: "/api/tags", decodeTo: [BlogTagJSON].self)

        XCTAssertEqual(tags[0].name, tag1.name)
        XCTAssertEqual(tags[1].name, tag2.name)
    }
    
}

struct BlogTagJSON: Content {
    let name: String
}
