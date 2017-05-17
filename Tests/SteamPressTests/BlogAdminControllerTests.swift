import XCTest
import Vapor
@testable import SteamPress
import HTTP
import FluentProvider

class BlogAdminControllerTests: XCTestCase {
    static var allTests = [
        ("testLogin", testLogin),
    ]
    
    var database: Database!
    var drop: Droplet!
    
    override func setUp() {
        database = Database(try! MemoryDriver(()))
        try! Droplet.prepare(database: database)
        let config = try! Config()
        drop = try! Droplet(config)
        let adminController = BlogAdminController(drop: drop, pathCreator: BlogPathCreator(blogPath: "blog"), viewFactory: CapturingViewFactory())
        adminController.addRoutes()
    }
    
    override func tearDown() {
        try! Droplet.teardown(database: database)
    }
    
    func testLogin() throws {
        let hashedPassword = try BlogUser.passwordHasher.make("password")
        let newUser = TestDataBuilder.anyUser()
        newUser.password = hashedPassword
        try newUser.save()
        
        let loginJson = JSON(try Node(node: [
                "inputUsername": newUser.username,
                "inputPassword": "password"
            ]))
        let loginRequest = Request(method: .post, uri: "/blog/admin/login/")
        loginRequest.json = loginJson
        let response = try drop.respond(to: loginRequest)
        
        XCTAssertEqual(response.status, .found)
        XCTAssertEqual(response.headers[HeaderKey.location], "/blog/admin/")
    }
}
