import XCTest

class DisabledBlogTagTests: XCTestCase {
    func testDisabledBlogTagsPath() throws {
        print("Setting up test world")
        let testWorld = try TestWorld.create(enableTagPages: false)
        print("Will now create tag")
        _ = try testWorld.createTag("Engineering")
        let tagResponse = try testWorld.getResponse(to: "/tags/Engineering")
        let allTagsResponse = try testWorld.getResponse(to: "/tags")

        XCTAssertEqual(.notFound, tagResponse.http.status)
        XCTAssertEqual(.notFound, allTagsResponse.http.status)
    }
}
