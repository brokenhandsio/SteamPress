import XCTest
import Vapor
@testable import SteamPress
import HTTP
import FluentProvider

class BlogAdminControllerTests: XCTestCase {
    static var allTests = [
        ("testTagAPIEndpointReportsArrayOfTagsAsJson", testTagAPIEndpointReportsArrayOfTagsAsJson),
    ]
    
    var database: Database!
    
    override func setUp() {
        database = Database(try! MemoryDriver(()))
        try! Droplet.prepare(database: database)
    }
    
    override func tearDown() {
        try! Droplet.teardown(database: database)
    }
    
    func testTagAPIEndpointReportsArrayOfTagsAsJson() throws {
        let tag1 = BlogTag(name: "The first tag")
        let tag2 = BlogTag(name: "The second tag")
        
        let config = try Config()
        let drop = try Droplet(config)
        let pathCreator = BlogPathCreator(blogPath: nil)
        // TODO change to Stub
        let viewFactory = CapturingViewFactory()

        let enableAuthorsPages = drop.config["enableAuthorsPages"]?.bool ?? true
        let enableTagsPages = drop.config["enableTagsPages"]?.bool ?? true

        let blogController = BlogController(drop: drop, pathCreator: pathCreator, viewFactory: viewFactory, enableAuthorsPages: enableAuthorsPages, enableTagsPages: enableTagsPages)
        blogController.addRoutes()
            
        try tag1.save()
        try tag2.save()
        
        let tagApiRequest = Request(method: .get, uri: "/api/tags/")
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
