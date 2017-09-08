import SteamPress
import XCTest
import Vapor
import FluentProvider

class RSSFeedTests: XCTestCase {

    // MARK: - allTests

    static var allTests = [
        ("testLinuxTestSuiteIncludesAllTests", testLinuxTestSuiteIncludesAllTests),
        ("testNoPostsReturnsCorrectRSSFeed", testNoPostsReturnsCorrectRSSFeed),
        ]

    // MARK: - Properties
    private var database: Database!
    private var drop: Droplet!
    private let rssRequest = Request(method: .get, uri: "blog/feed.xml")

    // MARK: - Overrides

    override func setUp() {
        database = try! Database(MemoryDriver())
        try! Droplet.prepare(database: database)
        drop = try! Droplet()
    }

    override func tearDown() {
        try! Droplet.teardown(database: database)
    }

    // MARK: - Tests

    func testLinuxTestSuiteIncludesAllTests() {
        #if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
            let thisClass = type(of: self)
            let linuxCount = thisClass.allTests.count
            let darwinCount = Int(thisClass
                .defaultTestSuite().testCaseCount)
            XCTAssertEqual(linuxCount, darwinCount,
                           "\(darwinCount - linuxCount) tests are missing from allTests")
        #endif
    }

    func testNoPostsReturnsCorrectRSSFeed() throws {
        let expectedXML = "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>\n<rss version=\"2.0\">\n\n<channel>\n<title>SteamPress Blog</title>\n<link>https://www.steampress.io</link>\n<description>SteamPress is an open-source blogging engine written for Vapor in Swift</description>\n</channel>\n\n</rss>"

        let actualXmlResponse = try drop.respond(to: rssRequest)

        XCTAssertEqual(actualXmlResponse.body.bytes?.makeString(), expectedXML)
    }
}
