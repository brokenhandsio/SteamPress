import XCTest
@testable import Vapor
@testable import SteamPress
import HTTP
import Fluent

class BlogAdminControllerTests: XCTestCase {
    static var allTests = [
        ("testTagAPIEndpointReportsArrayOfTagsAsJson", testTagAPIEndpointReportsArrayOfTagsAsJson),
    ]
    
    func testTagAPIEndpointReportsArrayOfTagsAsJson() throws {
        let tag1 = BlogTag(name: "The first tag")
        let tag2 = BlogTag(name: "The second tag")
        
        let drop = try Droplet()
//        drop.database = Database(MemoryDriver())
        let steampress = SteamPress.Provider(postsPerPage: 5)
        steampress.setup(drop)
        let pathCreator = BlogPathCreator(blogPath: nil)
        // TODO change to Stub
        let viewFactory = CapturingViewFactory()

        let enableAuthorsPages = drop.config["enableAuthorsPages"]?.bool ?? true
        let enableTagsPages = drop.config["enableTagsPages"]?.bool ?? true

        let blogController = BlogController(drop: drop, pathCreator: pathCreator, viewFactory: viewFactory, postsPerPage: 5, enableAuthorsPages: enableAuthorsPages, enableTagsPages: enableTagsPages, config: drop.config)
        blogController.addRoutes()
        try drop.runCommands()
        
        try tag1.save()
        try tag2.save()
        
        let tagApiRequest = try! Request(method: .get, uri: "/api/tags/")
        let response = try drop.respond(to: tagApiRequest)
        
        let tagsJson = try JSON(bytes: response.body.bytes!)
        
        XCTAssertNotNil(tagsJson.array)
        XCTAssertEqual(tagsJson.array?.count, 2)
        
        guard let nodeArray = tagsJson.array else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(nodeArray[0]["name"]?.string, "The first tag")
        XCTAssertEqual(nodeArray[1]["name"]?.string, "The second tag")
    }
}
