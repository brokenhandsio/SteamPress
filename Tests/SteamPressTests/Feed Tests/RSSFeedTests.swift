@testable import SteamPress
import XCTest
import Vapor

class RSSFeedTests: XCTestCase {

    // MARK: - allTests

    static var allTests = [
        ("testLinuxTestSuiteIncludesAllTests", testLinuxTestSuiteIncludesAllTests),
        ("testNoPostsReturnsCorrectRSSFeed", testNoPostsReturnsCorrectRSSFeed),
//        ("testOnePostReturnsCorrectRSSFeed", testOnePostReturnsCorrectRSSFeed),
//        ("testMultiplePostsReturnsCorrectRSSFeed", testMultiplePostsReturnsCorrectRSSFeed),
//        ("testDraftsAreNotIncludedInFeed", testDraftsAreNotIncludedInFeed),
//        ("testBlogTitleCanBeConfigured", testBlogTitleCanBeConfigured),
//        ("testBlogDescriptionCanBeConfigured", testBlogDescriptionCanBeConfigured),
//        ("testRSSFeedEndpointAddedToCorrectEndpointWhenBlogInSubPath", testRSSFeedEndpointAddedToCorrectEndpointWhenBlogInSubPath),
//        ("testPostLinkWhenBlogIsPlacedAtSubPath", testPostLinkWhenBlogIsPlacedAtSubPath),
//        ("testCopyrightCanBeAddedToRSS", testCopyrightCanBeAddedToRSS),
//        ("testThatTagsAreAddedToPostCorrectly", testThatTagsAreAddedToPostCorrectly),
//        ("testThatLinksComesFromRequestCorrectly", testThatLinksComesFromRequestCorrectly),
//        ("testThatLinksSpecifyHTTPSWhenComingFromReverseProxy", testThatLinksSpecifyHTTPSWhenComingFromReverseProxy),
//        ("testImageIsProvidedIfSupplied", testImageIsProvidedIfSupplied),
//        ("testCorrectHeaderSetForRSSFeed", testCorrectHeaderSetForRSSFeed),
//        ("testThatDateFormatterIsCorrect", testThatDateFormatterIsCorrect),
//        ("testThatDescriptionContainsOnlyText", testThatDescriptionContainsOnlyText),
        ]

    // MARK: - Properties
    private var testWorld: TestWorld!
    private var rssPath = "/rss.xml"
    private let dateFormatter = DateFormatter()

    // MARK: - Overrides

    override func setUp() {
        dateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss z"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
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

    func testNoPostsReturnsCorrectRSSFeed() throws {
        testWorld = try TestWorld.create()
        
        let expectedXML = "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>\n<rss version=\"2.0\">\n\n<channel>\n<title>SteamPress Blog</title>\n<link>/</link>\n<description>SteamPress is an open-source blogging engine written for Vapor in Swift</description>\n<generator>SteamPress</generator>\n<ttl>60</ttl>\n<textinput>\n<description>Search SteamPress Blog</description>\n<title>Search</title>\n<link>/search?</link>\n<name>term</name>\n</textinput>\n</channel>\n\n</rss>"

        let actualXmlResponse = try testWorld.getResponseString(to: rssPath)

        XCTAssertEqual(actualXmlResponse, expectedXML)
    }
//
//    func testOnePostReturnsCorrectRSSFeed() throws {
//        app = try TestDataBuilder.getSteamPressApp()
//        let post = try app.withConnection(to: .sqlite) { (conn) -> Future<TestData> in
//            return try Future(TestDataBuilder.createPost(for: conn))
//            }.blockingAwait().post
//
//        let expectedXML = "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>\n<rss version=\"2.0\">\n\n<channel>\n<title>SteamPress Blog</title>\n<link>/</link>\n<description>SteamPress is an open-source blogging engine written for Vapor in Swift</description>\n<generator>SteamPress</generator>\n<ttl>60</ttl>\n<pubDate>\(dateFormatter.string(from: post.created))</pubDate>\n<textinput>\n<description>Search SteamPress Blog</description>\n<title>Search</title>\n<link>/search?</link>\n<name>term</name>\n</textinput>\n<item>\n<title>\n\(post.title)\n</title>\n<description>\n\(try post.description())\n</description>\n<link>\n/posts/\(post.slugUrl)/\n</link>\n<pubDate>\(dateFormatter.string(from: post.created))</pubDate>\n</item>\n</channel>\n\n</rss>"
//
//        let actualXmlResponse = try TestDataBuilder.getResponse(to: rssRequest, using: app)
//
//        XCTAssertEqual(actualXmlResponse.string, expectedXML)
//    }
//
//    func testMultiplePostsReturnsCorrectRSSFeed() throws {
//        app = try TestDataBuilder.getSteamPressApp()
//        let testData = try app.withConnection(to: .sqlite) { (conn) -> Future<TestData> in
//            return try Future(TestDataBuilder.createPost(for: conn))
//            }.blockingAwait()
//        let post = testData.post
//        let author = testData.author
//
//        let anotherTitle = "Another Title"
//        let contents = "This is some short contents"
//        let post2 = try BlogPost(title: anotherTitle, contents: contents, author: author, creationDate: Date(), slugUrl: "another-title", published: true)
//
//        _ = try app.withConnection(to: .sqlite) { conn in
//            return post2.save(on: conn)
//            }.blockingAwait()
//
//        let expectedXML = "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>\n<rss version=\"2.0\">\n\n<channel>\n<title>SteamPress Blog</title>\n<link>/</link>\n<description>SteamPress is an open-source blogging engine written for Vapor in Swift</description>\n<generator>SteamPress</generator>\n<ttl>60</ttl>\n<pubDate>\(dateFormatter.string(from: post2.created))</pubDate>\n<textinput>\n<description>Search SteamPress Blog</description>\n<title>Search</title>\n<link>/search?</link>\n<name>term</name>\n</textinput>\n<item>\n<title>\n\(anotherTitle)\n</title>\n<description>\n\(contents)\n</description>\n<link>\n/posts/another-title/\n</link>\n<pubDate>\(dateFormatter.string(from: post2.created))</pubDate>\n</item>\n<item>\n<title>\n\(post.title)\n</title>\n<description>\n\(try post.description())\n</description>\n<link>\n/posts/\(post.slugUrl)/\n</link>\n<pubDate>\(dateFormatter.string(from: post.created))</pubDate>\n</item>\n</channel>\n\n</rss>"
//
//        let actualXmlResponse = try TestDataBuilder.getResponse(to: rssRequest, using: app)
//
//        XCTAssertEqual(actualXmlResponse.string, expectedXML)
//    }
//
//    func testDraftsAreNotIncludedInFeed() throws {
//        app = try TestDataBuilder.getSteamPressApp()
//        let testData = try app.withConnection(to: .sqlite) { (conn) -> Future<TestData> in
//            return try Future(TestDataBuilder.createPost(for: conn))
//            }.blockingAwait()
//        let post = testData.post
//        let author = testData.author
//
//        let anotherTitle = "Another Title"
//        let contents = "This is some short contents"
//        let post2 = try BlogPost(title: anotherTitle, contents: contents, author: author, creationDate: Date(), slugUrl: "another-title", published: false)
//
//        _ = try app.withConnection(to: .sqlite) { conn in
//            return post2.save(on: conn)
//            }.blockingAwait()
//
//        let expectedXML = "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>\n<rss version=\"2.0\">\n\n<channel>\n<title>SteamPress Blog</title>\n<link>/</link>\n<description>SteamPress is an open-source blogging engine written for Vapor in Swift</description>\n<generator>SteamPress</generator>\n<ttl>60</ttl>\n<pubDate>\(dateFormatter.string(from: post.created))</pubDate>\n<textinput>\n<description>Search SteamPress Blog</description>\n<title>Search</title>\n<link>/search?</link>\n<name>term</name>\n</textinput>\n<item>\n<title>\n\(post.title)\n</title>\n<description>\n\(try post.description())\n</description>\n<link>\n/posts/\(post.slugUrl)/\n</link>\n<pubDate>\(dateFormatter.string(from: post.created))</pubDate>\n</item>\n</channel>\n\n</rss>"
//
//        let actualXmlResponse = try TestDataBuilder.getResponse(to: rssRequest, using: app)
//
//        XCTAssertEqual(actualXmlResponse.string, expectedXML)
//    }
//
//    func testBlogTitleCanBeConfigured() throws {
//        let title = "SteamPress - The Open Source Blog"
//        app = try TestDataBuilder.getSteamPressApp(title: title)
//
//        let post = try app.withConnection(to: .sqlite) { (conn) -> Future<TestData> in
//            return try Future(TestDataBuilder.createPost(for: conn))
//            }.blockingAwait().post
//
//        let expectedXML = "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>\n<rss version=\"2.0\">\n\n<channel>\n<title>\(title)</title>\n<link>/</link>\n<description>SteamPress is an open-source blogging engine written for Vapor in Swift</description>\n<generator>SteamPress</generator>\n<ttl>60</ttl>\n<pubDate>\(dateFormatter.string(from: post.created))</pubDate>\n<textinput>\n<description>Search \(title)</description>\n<title>Search</title>\n<link>/search?</link>\n<name>term</name>\n</textinput>\n<item>\n<title>\n\(post.title)\n</title>\n<description>\n\(try post.description())\n</description>\n<link>\n/posts/\(post.slugUrl)/\n</link>\n<pubDate>\(dateFormatter.string(from: post.created))</pubDate>\n</item>\n</channel>\n\n</rss>"
//
//        let actualXmlResponse = try TestDataBuilder.getResponse(to: rssRequest, using: app)
//
//        XCTAssertEqual(actualXmlResponse.string, expectedXML)
//    }
//
//    func testBlogDescriptionCanBeConfigured() throws {
//        let description = "Our fancy new RSS-feed blog"
//        app = try TestDataBuilder.getSteamPressApp(description: description)
//
//        let post = try app.withConnection(to: .sqlite) { (conn) -> Future<TestData> in
//            return try Future(TestDataBuilder.createPost(for: conn))
//            }.blockingAwait().post
//
//        let expectedXML = "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>\n<rss version=\"2.0\">\n\n<channel>\n<title>SteamPress Blog</title>\n<link>/</link>\n<description>\(description)</description>\n<generator>SteamPress</generator>\n<ttl>60</ttl>\n<pubDate>\(dateFormatter.string(from: post.created))</pubDate>\n<textinput>\n<description>Search SteamPress Blog</description>\n<title>Search</title>\n<link>/search?</link>\n<name>term</name>\n</textinput>\n<item>\n<title>\n\(post.title)\n</title>\n<description>\n\(try post.description())\n</description>\n<link>\n/posts/\(post.slugUrl)/\n</link>\n<pubDate>\(dateFormatter.string(from: post.created))</pubDate>\n</item>\n</channel>\n\n</rss>"
//
//        let actualXmlResponse = try TestDataBuilder.getResponse(to: rssRequest, using: app)
//
//        XCTAssertEqual(actualXmlResponse.string, expectedXML)
//    }
//
//    func testRSSFeedEndpointAddedToCorrectEndpointWhenBlogInSubPath() throws {
//        app = try TestDataBuilder.getSteamPressApp(path: "blog-path")
//
//        let expectedXML = "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>\n<rss version=\"2.0\">\n\n<channel>\n<title>SteamPress Blog</title>\n<link>/blog-path/</link>\n<description>SteamPress is an open-source blogging engine written for Vapor in Swift</description>\n<generator>SteamPress</generator>\n<ttl>60</ttl>\n<textinput>\n<description>Search SteamPress Blog</description>\n<title>Search</title>\n<link>/blog-path/search?</link>\n<name>term</name>\n</textinput>\n</channel>\n\n</rss>"
//
//        let request = HTTPRequest(method: .get, uri: "/blog-path/rss.xml")
//        let actualXmlResponse = try TestDataBuilder.getResponse(to: request, using: app)
//        XCTAssertEqual(actualXmlResponse.string, expectedXML)
//    }
//
//    func testPostLinkWhenBlogIsPlacedAtSubPath() throws {
//        app = try TestDataBuilder.getSteamPressApp(path: "blog-path")
//
//        let post = try app.withConnection(to: .sqlite) { (conn) -> Future<TestData> in
//            return try Future(TestDataBuilder.createPost(for: conn))
//            }.blockingAwait().post
//
//        let expectedXML = "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>\n<rss version=\"2.0\">\n\n<channel>\n<title>SteamPress Blog</title>\n<link>/blog-path/</link>\n<description>SteamPress is an open-source blogging engine written for Vapor in Swift</description>\n<generator>SteamPress</generator>\n<ttl>60</ttl>\n<pubDate>\(dateFormatter.string(from: post.created))</pubDate>\n<textinput>\n<description>Search SteamPress Blog</description>\n<title>Search</title>\n<link>/blog-path/search?</link>\n<name>term</name>\n</textinput>\n<item>\n<title>\n\(post.title)\n</title>\n<description>\n\(try post.description())\n</description>\n<link>\n/blog-path/posts/\(post.slugUrl)/\n</link>\n<pubDate>\(dateFormatter.string(from: post.created))</pubDate>\n</item>\n</channel>\n\n</rss>"
//
//        let request = HTTPRequest(method: .get, uri: "/blog-path/rss.xml")
//        let actualXmlResponse = try TestDataBuilder.getResponse(to: request, using: app)
//        XCTAssertEqual(actualXmlResponse.string, expectedXML)
//    }
//
//    func testCopyrightCanBeAddedToRSS() throws {
//        let copyright = "Copyright ©️ 2017 SteamPress"
//        app = try TestDataBuilder.getSteamPressApp(copyright: copyright)
//
//        let expectedXML = "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>\n<rss version=\"2.0\">\n\n<channel>\n<title>SteamPress Blog</title>\n<link>/</link>\n<description>SteamPress is an open-source blogging engine written for Vapor in Swift</description>\n<generator>SteamPress</generator>\n<ttl>60</ttl>\n<copyright>\(copyright)</copyright>\n<textinput>\n<description>Search SteamPress Blog</description>\n<title>Search</title>\n<link>/search?</link>\n<name>term</name>\n</textinput>\n</channel>\n\n</rss>"
//
//        let actualXmlResponse = try TestDataBuilder.getResponse(to: rssRequest, using: app)
//
//        XCTAssertEqual(actualXmlResponse.string, expectedXML)
//    }
//
//    func testThatTagsAreAddedToPostCorrectly() throws {
//        app = try TestDataBuilder.getSteamPressApp()
//        let post = try app.withConnection(to: .sqlite) { (conn) -> Future<TestData> in
//            return try Future(TestDataBuilder.createPost(for: conn, tags: ["Vapor 2", "Engineering"]))
//            }.blockingAwait().post
//
//        let expectedXML = "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>\n<rss version=\"2.0\">\n\n<channel>\n<title>SteamPress Blog</title>\n<link>/</link>\n<description>SteamPress is an open-source blogging engine written for Vapor in Swift</description>\n<generator>SteamPress</generator>\n<ttl>60</ttl>\n<pubDate>\(dateFormatter.string(from: post.created))</pubDate>\n<textinput>\n<description>Search SteamPress Blog</description>\n<title>Search</title>\n<link>/search?</link>\n<name>term</name>\n</textinput>\n<item>\n<title>\n\(post.title)\n</title>\n<description>\n\(try post.description())\n</description>\n<link>\n/posts/\(post.slugUrl)/\n</link>\n<category>Vapor 2</category>\n<category>Engineering</category>\n<pubDate>\(dateFormatter.string(from: post.created))</pubDate>\n</item>\n</channel>\n\n</rss>"
//
//        let actualXmlResponse = try TestDataBuilder.getResponse(to: rssRequest, using: app)
//
//        XCTAssertEqual(actualXmlResponse.string, expectedXML)
//    }
//
//    func testThatLinksComesFromRequestCorrectly() throws {
//        app = try TestDataBuilder.getSteamPressApp(path: "blog-path")
//        let post = try app.withConnection(to: .sqlite) { (conn) -> Future<TestData> in
//            return try Future(TestDataBuilder.createPost(for: conn))
//            }.blockingAwait().post
//
//        let expectedXML = "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>\n<rss version=\"2.0\">\n\n<channel>\n<title>SteamPress Blog</title>\n<link>http://geeks.brokenhands.io/blog-path/</link>\n<description>SteamPress is an open-source blogging engine written for Vapor in Swift</description>\n<generator>SteamPress</generator>\n<ttl>60</ttl>\n<pubDate>\(dateFormatter.string(from: post.created))</pubDate>\n<textinput>\n<description>Search SteamPress Blog</description>\n<title>Search</title>\n<link>http://geeks.brokenhands.io/blog-path/search?</link>\n<name>term</name>\n</textinput>\n<item>\n<title>\n\(post.title)\n</title>\n<description>\n\(try post.description())\n</description>\n<link>\nhttp://geeks.brokenhands.io/blog-path/posts/\(post.slugUrl)/\n</link>\n<pubDate>\(dateFormatter.string(from: post.created))</pubDate>\n</item>\n</channel>\n\n</rss>"
//
//        let httpRequest = HTTPRequest(method: .get, uri: "http://geeks.brokenhands.io/blog-path/rss.xml")
//
//        let actualXmlResponse = try TestDataBuilder.getResponse(to: httpRequest, using: app)
//
//        XCTAssertEqual(actualXmlResponse.string, expectedXML)
//    }
//
//    func testThatLinksSpecifyHTTPSWhenComingFromReverseProxy() throws {
//        app = try TestDataBuilder.getSteamPressApp(path: "blog-path")
//        let post = try app.withConnection(to: .sqlite) { (conn) -> Future<TestData> in
//            return try Future(TestDataBuilder.createPost(for: conn))
//            }.blockingAwait().post
//
//        let expectedXML = "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>\n<rss version=\"2.0\">\n\n<channel>\n<title>SteamPress Blog</title>\n<link>https://geeks.brokenhands.io/blog-path/</link>\n<description>SteamPress is an open-source blogging engine written for Vapor in Swift</description>\n<generator>SteamPress</generator>\n<ttl>60</ttl>\n<pubDate>\(dateFormatter.string(from: post.created))</pubDate>\n<textinput>\n<description>Search SteamPress Blog</description>\n<title>Search</title>\n<link>https://geeks.brokenhands.io/blog-path/search?</link>\n<name>term</name>\n</textinput>\n<item>\n<title>\n\(post.title)\n</title>\n<description>\n\(try post.description())\n</description>\n<link>\nhttps://geeks.brokenhands.io/blog-path/posts/\(post.slugUrl)/\n</link>\n<pubDate>\(dateFormatter.string(from: post.created))</pubDate>\n</item>\n</channel>\n\n</rss>"
//
//        var httpsReverseProxyRequest = HTTPRequest(method: .get, uri: "http://geeks.brokenhands.io/blog-path/rss.xml")
//        httpsReverseProxyRequest.headers["X-Forwarded-Proto"] = "https"
//
//        let actualXmlResponse = try TestDataBuilder.getResponse(to: httpsReverseProxyRequest, using: app)
//
//        XCTAssertEqual(actualXmlResponse.string, expectedXML)
//    }
//
//    func testImageIsProvidedIfSupplied() throws {
//        let image = "https://static.brokenhands.io/images/brokenhands.png"
//        app = try TestDataBuilder.getSteamPressApp(imageURL: image)
//
//        let expectedXML = "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>\n<rss version=\"2.0\">\n\n<channel>\n<title>SteamPress Blog</title>\n<link>https://geeks.brokenhands.io/</link>\n<description>SteamPress is an open-source blogging engine written for Vapor in Swift</description>\n<generator>SteamPress</generator>\n<ttl>60</ttl>\n<image>\n<url>\(image)</url>\n<title>SteamPress Blog</title>\n<link>https://geeks.brokenhands.io/</link>\n</image>\n<textinput>\n<description>Search SteamPress Blog</description>\n<title>Search</title>\n<link>https://geeks.brokenhands.io/search?</link>\n<name>term</name>\n</textinput>\n</channel>\n\n</rss>"
//
//        let httpsRequest = HTTPRequest(method: .get, uri: "https://geeks.brokenhands.io/rss.xml")
//        let actualXmlResponse = try TestDataBuilder.getResponse(to: httpsRequest, using: app)
//
//        XCTAssertEqual(actualXmlResponse.string, expectedXML)
//    }
//
//    func testCorrectHeaderSetForRSSFeed() throws {
//        app = try TestDataBuilder.getSteamPressApp()
//        let actualXmlResponse = try TestDataBuilder.getResponse(to: rssRequest, using: app)
//
//        XCTAssertEqual(actualXmlResponse.http.headers[.contentType], "application/rss+xml")
//    }
//
//    func testThatDateFormatterIsCorrect() throws {
//        let createDate = Date(timeIntervalSince1970: 1505867108)
//
//        app = try TestDataBuilder.getSteamPressApp()
//        let post = try app.withConnection(to: .sqlite) { (conn) -> Future<TestData> in
//            return try Future(TestDataBuilder.createPost(for: conn, createdDate: createDate))
//            }.blockingAwait().post
//
//        let expectedXML = "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>\n<rss version=\"2.0\">\n\n<channel>\n<title>SteamPress Blog</title>\n<link>/</link>\n<description>SteamPress is an open-source blogging engine written for Vapor in Swift</description>\n<generator>SteamPress</generator>\n<ttl>60</ttl>\n<pubDate>Wed, 20 Sep 2017 00:25:08 GMT</pubDate>\n<textinput>\n<description>Search SteamPress Blog</description>\n<title>Search</title>\n<link>/search?</link>\n<name>term</name>\n</textinput>\n<item>\n<title>\n\(post.title)\n</title>\n<description>\n\(try post.description())\n</description>\n<link>\n/posts/\(post.slugUrl)/\n</link>\n<pubDate>Wed, 20 Sep 2017 00:25:08 GMT</pubDate>\n</item>\n</channel>\n\n</rss>"
//
//        let actualXmlResponse = try TestDataBuilder.getResponse(to: rssRequest, using: app)
//
//        XCTAssertEqual(actualXmlResponse.string, expectedXML)
//    }
//
//    func testThatDescriptionContainsOnlyText() throws {
//        app = try TestDataBuilder.getSteamPressApp()
//        let contents = "[This is](https://www.google.com) a post that contains some **text**. \n# Formatting should be removed"
//        let post = try app.withConnection(to: .sqlite) { (conn) -> Future<TestData> in
//            return try Future(TestDataBuilder.createPost(for: conn, contents: contents))
//            }.blockingAwait().post
//
//        let expectedXML = "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>\n<rss version=\"2.0\">\n\n<channel>\n<title>SteamPress Blog</title>\n<link>/</link>\n<description>SteamPress is an open-source blogging engine written for Vapor in Swift</description>\n<generator>SteamPress</generator>\n<ttl>60</ttl>\n<pubDate>\(dateFormatter.string(from: post.created))</pubDate>\n<textinput>\n<description>Search SteamPress Blog</description>\n<title>Search</title>\n<link>/search?</link>\n<name>term</name>\n</textinput>\n<item>\n<title>\n\(post.title)\n</title>\n<description>\nThis is a post that contains some text. Formatting should be removed\n</description>\n<link>\n/posts/\(post.slugUrl)/\n</link>\n<pubDate>\(dateFormatter.string(from: post.created))</pubDate>\n</item>\n</channel>\n\n</rss>"
//
//        let actualXmlResponse = try TestDataBuilder.getResponse(to: rssRequest, using: app)
//
//        XCTAssertEqual(actualXmlResponse.string, expectedXML)
//    }

}

