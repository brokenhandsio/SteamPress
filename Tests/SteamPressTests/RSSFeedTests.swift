import SteamPress
import XCTest
import Vapor
import FluentProvider

class RSSFeedTests: XCTestCase {

    // MARK: - allTests

    static var allTests = [
        ("testLinuxTestSuiteIncludesAllTests", testLinuxTestSuiteIncludesAllTests),
        ("testNoPostsReturnsCorrectRSSFeed", testNoPostsReturnsCorrectRSSFeed),
        ("testNoPostsReturnsCorrectRSSFeed", testNoPostsReturnsCorrectRSSFeed),
        ("testMultiplePostsReturnsCorrectRSSFeed", testMultiplePostsReturnsCorrectRSSFeed),
        ("testDraftsAreNotIncludedInFeed", testDraftsAreNotIncludedInFeed),
        ("testBlogTitleCanBeConfigured", testBlogTitleCanBeConfigured),
        ("testBlogTitleCanBeConfigured", testBlogTitleCanBeConfigured),
        ]

    // MARK: - Properties
    private var database: Database!
    private var drop: Droplet!
    private let rssRequest = Request(method: .get, uri: "/rss.xml")

    // MARK: - Overrides

    override func setUp() {
        database = try! Database(MemoryDriver())
        try! Droplet.prepare(database: database)
        try! setupDrop()
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

    func testOnePostReturnsCorrectRSSFeed() throws {
        let author = TestDataBuilder.anyUser()
        try author.save()
        let post1 = TestDataBuilder.anyPost(author: author)
        try post1.save()
        let expectedXML = "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>\n<rss version=\"2.0\">\n\n<channel>\n<title>SteamPress Blog</title>\n<link>https://www.steampress.io</link>\n<description>SteamPress is an open-source blogging engine written for Vapor in Swift</description>\n<item>\n<title>\n\(post1.title)\n</title>\n<description>\n\(post1.shortSnippet())\n</description>\n<link>\n/posts/\(post1.slugUrl)\n</link>\n</item>\n</channel>\n\n</rss>"

        let actualXmlResponse = try drop.respond(to: rssRequest)

        XCTAssertEqual(actualXmlResponse.body.bytes?.makeString(), expectedXML)
    }

    func testMultiplePostsReturnsCorrectRSSFeed() throws {
        let author = TestDataBuilder.anyUser()
        try author.save()
        let post1 = TestDataBuilder.anyPost(author: author)
        try post1.save()
        let anotherTitle = "Another Title"
        let contents = "This is some short contents"
        let post2 = BlogPost(title: anotherTitle, contents: contents, author: author, creationDate: Date(), slugUrl: "another-title", published: true)
        try post2.save()
        let expectedXML = "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>\n<rss version=\"2.0\">\n\n<channel>\n<title>SteamPress Blog</title>\n<link>https://www.steampress.io</link>\n<description>SteamPress is an open-source blogging engine written for Vapor in Swift</description>\n<item>\n<title>\n\(post1.title)\n</title>\n<description>\n\(post1.shortSnippet())\n</description>\n<link>\n/posts/\(post1.slugUrl)\n</link>\n</item>\n<item>\n<title>\n\(anotherTitle)\n</title>\n<description>\n\(contents)\n\n</description>\n<link>\n/posts/another-title\n</link>\n</item>\n</channel>\n\n</rss>"

        let actualXmlResponse = try drop.respond(to: rssRequest)

        XCTAssertEqual(actualXmlResponse.body.bytes?.makeString(), expectedXML)
    }

    func testDraftsAreNotIncludedInFeed() throws {
        let author = TestDataBuilder.anyUser()
        try author.save()
        let post1 = TestDataBuilder.anyPost(author: author)
        try post1.save()
        let anotherTitle = "Another Title"
        let contents = "This is some short contents"
        let post2 = BlogPost(title: anotherTitle, contents: contents, author: author, creationDate: Date(), slugUrl: "another-title", published: false)
        try post2.save()
        let expectedXML = "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>\n<rss version=\"2.0\">\n\n<channel>\n<title>SteamPress Blog</title>\n<link>https://www.steampress.io</link>\n<description>SteamPress is an open-source blogging engine written for Vapor in Swift</description>\n<item>\n<title>\n\(post1.title)\n</title>\n<description>\n\(post1.shortSnippet())\n</description>\n<link>\n/posts/\(post1.slugUrl)\n</link>\n</item>\n</channel>\n\n</rss>"

        let actualXmlResponse = try drop.respond(to: rssRequest)

        XCTAssertEqual(actualXmlResponse.body.bytes?.makeString(), expectedXML)
    }

    func testBlogTitleCanBeConfigured() throws {
        let title = "SteamPress - The Open Source Blog"
        try setupDrop(title: title)

        let author = TestDataBuilder.anyUser()
        try author.save()
        let post1 = TestDataBuilder.anyPost(author: author)
        try post1.save()
        let expectedXML = "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>\n<rss version=\"2.0\">\n\n<channel>\n<title>\(title)</title>\n<link>https://www.steampress.io</link>\n<description>SteamPress is an open-source blogging engine written for Vapor in Swift</description>\n<item>\n<title>\n\(post1.title)\n</title>\n<description>\n\(post1.shortSnippet())\n</description>\n<link>\n/posts/\(post1.slugUrl)\n</link>\n</item>\n</channel>\n\n</rss>"

        let actualXmlResponse = try drop.respond(to: rssRequest)

        XCTAssertEqual(actualXmlResponse.body.bytes?.makeString(), expectedXML)
    }

    func testBlogDescriptionCanBeConfigured() throws {
        let description = "Our fancy new RSS-feed blog"
        try setupDrop(description: description)

        let author = TestDataBuilder.anyUser()
        try author.save()
        let post1 = TestDataBuilder.anyPost(author: author)
        try post1.save()
        let expectedXML = "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>\n<rss version=\"2.0\">\n\n<channel>\n<title>SteamPress Blog</title>\n<link>https://www.steampress.io</link>\n<description>\(description)</description>\n<item>\n<title>\n\(post1.title)\n</title>\n<description>\n\(post1.shortSnippet())\n</description>\n<link>\n/posts/\(post1.slugUrl)\n</link>\n</item>\n</channel>\n\n</rss>"

        let actualXmlResponse = try drop.respond(to: rssRequest)

        XCTAssertEqual(actualXmlResponse.body.bytes?.makeString(), expectedXML)
    }

    // MARK: - Private functions

    private func setupDrop(title: String? = nil, description: String? = nil) throws {
        var config = Config([:])

        try config.set("steampress.postsPerPage", 5)

        if let title = title {
            try config.set("steampress.title", title)
        }

        if let description = description {
            try config.set("steampress.description", description)
        }

        try config.set("droplet.middleware", ["error", "steampress-sessions", "blog-persist"])
        try config.set("fluent.driver", "memory")
        try config.addProvider(SteamPress.Provider.self)
        try config.addProvider(FluentProvider.Provider.self)

        drop = try Droplet(config)
    }
}
