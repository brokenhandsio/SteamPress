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
        let app = try TestDataBuilder.getSteamPressApp()

        let tag1 = "Vapor 2"
        let tag2 = "Engineering"

        _ = try app.withConnection(to: .sqlite) { (conn) -> Future<TestData> in
            return try Future(TestDataBuilder.createPost(for: conn, tags: [tag1, tag2]))
            }.blockingAwait()

        let response = try TestDataBuilder.getResponse(to: HTTPRequest(method: .get, uri: "/api/tags"), using: app)

        print("Response is \(response.body.string!)")

        let data = try response.content.decode([BlogTagJSON].self).blockingAwait()

        XCTAssertEqual(data[0].name, "Vapor 2")
        XCTAssertEqual(data[1].name, "Engineering")
    }
}

struct BlogTagJSON: Content {
    let name: String
}
