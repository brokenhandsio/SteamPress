import XCTest
import Vapor
import SteamPress

class APITagControllerTests: XCTestCase {

    // MARK: - Tests

    func testThatAllTagsAreReturnedFromAPI() throws {
        var testWorld = try TestWorld.create()

        let tag1 = try testWorld.context.repository.addTag(name: "Vapor3")
        let tag2 = try testWorld.context.repository.addTag(name: "Engineering")

        let tags = try testWorld.getResponse(to: "/api/tags", decodeTo: [BlogTagJSON].self)

        XCTAssertEqual(tags[0].name, tag1.name)
        XCTAssertEqual(tags[1].name, tag2.name)
        
        XCTAssertNoThrow(try testWorld.shutdown())
    }
    
}

struct BlogTagJSON: Content {
    let name: String
}
