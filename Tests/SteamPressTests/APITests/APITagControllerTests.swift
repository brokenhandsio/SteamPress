import XCTest
import Vapor
import SteamPress

class APITagControllerTests: XCTestCase {
    
    // MARK: - allTests
    
    static var allTests = [
        ("testLinuxTestSuiteIncludesAllTests", testLinuxTestSuiteIncludesAllTests),
        ("testThatAllTagsAreReturnedFromAPI", testThatAllTagsAreReturnedFromAPI),
        ]
    
    //    // MARK: - Properties
    private var app: Application!
    
    // MARK: - Overrides
    
    override func setUp() {
    }
    
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
        //        let app = try TestDataBuilder.getSteamPressApp()
        //        let conn = try app.newConnection(to: .sqlite).wait()
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


struct TestWorld {
    
    static func create() throws -> TestWorld {
        let repository = InMemoryRepository()
        let application = try TestDataBuilder.getSteamPressApp(tagRepository: repository)
        let context = Context(app: application, repository: repository)
        return TestWorld(context: context)
    }

    let context: Context
    
    init(context: Context) {
        self.context = context
    }
    
    struct Context {
        let app: Application
        let repository: InMemoryRepository
    }
}

extension TestWorld {
    func getResponse<T>(to path: String, method: HTTPMethod = .GET, decodeTo type: T.Type) throws -> T where T: Content {
        let responder = try context.app.make(Responder.self)
        let request = HTTPRequest(method: method, url: URL(string: path)!)
        let wrappedRequest = Request(http: request, using: context.app)
        let response = try responder.respond(to: wrappedRequest).wait()
        return try response.content.decode(type).wait()
    }
}

class InMemoryRepository: TagRepository, Service {
    
    private var tags: [BlogTag]
    
    init() {
        tags = []
    }
    
    func getAllTags(on req: Request) -> Future<[BlogTag]> {
        return req.future(tags)
    }
    
    func addTag(name: String) {
        let newTag = BlogTag(id: tags.count + 1, name: name)
        tags.append(newTag)
    }
    
    
}
