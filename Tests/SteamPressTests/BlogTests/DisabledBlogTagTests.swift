import XCTest
import Vapor

class DisabledBlogTagTests: XCTestCase {
    func testDisabledBlogTagsPath() throws {
        var testWorld = try TestWorld.create(enableTagPages: false)
        _ = try testWorld.createTag("Engineering")
        var tagResponse: Response? = try testWorld.getResponse(to: "/tags/Engineering")
        var allTagsResponse: Response? = try testWorld.getResponse(to: "/tags")

        XCTAssertEqual(.notFound, tagResponse?.http.status)
        XCTAssertEqual(.notFound, allTagsResponse?.http.status)
        
        tagResponse = nil
        allTagsResponse = nil
        
        XCTAssertNoThrow(try testWorld.tryAsHardAsWeCanToShutdownApplication())
    }
}
