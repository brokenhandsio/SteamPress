@testable import SteamPress
import XCTest
import Vapor
import Fluent
import FluentSQLite

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
    private var app: Application!
    private let rssRequest = HTTPRequest(method: .get, uri: "/rss.xml")
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
        app = try TestDataBuilder.getSteamPressApp()
        let expectedXML = "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>\n<rss version=\"2.0\">\n\n<channel>\n<title>SteamPress Blog</title>\n<link>/</link>\n<description>SteamPress is an open-source blogging engine written for Vapor in Swift</description>\n<generator>SteamPress</generator>\n<ttl>60</ttl>\n<textinput>\n<description>Search SteamPress Blog</description>\n<title>Search</title>\n<link>/search?</link>\n<name>term</name>\n</textinput>\n</channel>\n\n</rss>"

        let actualXmlResponse = try TestDataBuilder.getResponse(to: rssRequest, using: app)

        XCTAssertEqual(actualXmlResponse.body.string, expectedXML)
    }

//    func testOnePostReturnsCorrectRSSFeed() throws {
//        let (post, _) = try createPost()
//        let expectedXML = "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>\n<rss version=\"2.0\">\n\n<channel>\n<title>SteamPress Blog</title>\n<link>/</link>\n<description>SteamPress is an open-source blogging engine written for Vapor in Swift</description>\n<generator>SteamPress</generator>\n<ttl>60</ttl>\n<pubDate>\(dateFormatter.string(from: post.created))</pubDate>\n<textinput>\n<description>Search SteamPress Blog</description>\n<title>Search</title>\n<link>/search?</link>\n<name>term</name>\n</textinput>\n<item>\n<title>\n\(post.title)\n</title>\n<description>\n\(try post.description())\n</description>\n<link>\n/posts/\(post.slugUrl)/\n</link>\n<pubDate>\(dateFormatter.string(from: post.created))</pubDate>\n</item>\n</channel>\n\n</rss>"
//
//        let actualXmlResponse = try drop.respond(to: rssRequest)
//
//        XCTAssertEqual(actualXmlResponse.body.bytes?.makeString(), expectedXML)
//    }
//
//    func testMultiplePostsReturnsCorrectRSSFeed() throws {
//        let (post, author) = try createPost()
//        let anotherTitle = "Another Title"
//        let contents = "This is some short contents"
//        let post2 = BlogPost(title: anotherTitle, contents: contents, author: author, creationDate: Date(), slugUrl: "another-title", published: true)
//        try post2.save()
//        let expectedXML = "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>\n<rss version=\"2.0\">\n\n<channel>\n<title>SteamPress Blog</title>\n<link>/</link>\n<description>SteamPress is an open-source blogging engine written for Vapor in Swift</description>\n<generator>SteamPress</generator>\n<ttl>60</ttl>\n<pubDate>\(dateFormatter.string(from: post2.created))</pubDate>\n<textinput>\n<description>Search SteamPress Blog</description>\n<title>Search</title>\n<link>/search?</link>\n<name>term</name>\n</textinput>\n<item>\n<title>\n\(anotherTitle)\n</title>\n<description>\n\(contents)\n</description>\n<link>\n/posts/another-title/\n</link>\n<pubDate>\(dateFormatter.string(from: post2.created))</pubDate>\n</item>\n<item>\n<title>\n\(post.title)\n</title>\n<description>\n\(try post.description())\n</description>\n<link>\n/posts/\(post.slugUrl)/\n</link>\n<pubDate>\(dateFormatter.string(from: post.created))</pubDate>\n</item>\n</channel>\n\n</rss>"
//
//        let actualXmlResponse = try drop.respond(to: rssRequest)
//
//        XCTAssertEqual(actualXmlResponse.body.bytes?.makeString(), expectedXML)
//    }
//
//    func testDraftsAreNotIncludedInFeed() throws {
//        let (post, author) = try createPost()
//        let anotherTitle = "Another Title"
//        let contents = "This is some short contents"
//        let post2 = BlogPost(title: anotherTitle, contents: contents, author: author, creationDate: Date(), slugUrl: "another-title", published: false)
//        try post2.save()
//        let expectedXML = "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>\n<rss version=\"2.0\">\n\n<channel>\n<title>SteamPress Blog</title>\n<link>/</link>\n<description>SteamPress is an open-source blogging engine written for Vapor in Swift</description>\n<generator>SteamPress</generator>\n<ttl>60</ttl>\n<pubDate>\(dateFormatter.string(from: post.created))</pubDate>\n<textinput>\n<description>Search SteamPress Blog</description>\n<title>Search</title>\n<link>/search?</link>\n<name>term</name>\n</textinput>\n<item>\n<title>\n\(post.title)\n</title>\n<description>\n\(try post.description())\n</description>\n<link>\n/posts/\(post.slugUrl)/\n</link>\n<pubDate>\(dateFormatter.string(from: post.created))</pubDate>\n</item>\n</channel>\n\n</rss>"
//
//        let actualXmlResponse = try drop.respond(to: rssRequest)
//
//        XCTAssertEqual(actualXmlResponse.body.bytes?.makeString(), expectedXML)
//    }
//
//    func testBlogTitleCanBeConfigured() throws {
//        let title = "SteamPress - The Open Source Blog"
//        drop = try TestDataBuilder.setupSteamPressDrop(title: title)
//
//        let (post, _) = try createPost()
//        let expectedXML = "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>\n<rss version=\"2.0\">\n\n<channel>\n<title>\(title)</title>\n<link>/</link>\n<description>SteamPress is an open-source blogging engine written for Vapor in Swift</description>\n<generator>SteamPress</generator>\n<ttl>60</ttl>\n<pubDate>\(dateFormatter.string(from: post.created))</pubDate>\n<textinput>\n<description>Search \(title)</description>\n<title>Search</title>\n<link>/search?</link>\n<name>term</name>\n</textinput>\n<item>\n<title>\n\(post.title)\n</title>\n<description>\n\(try post.description())\n</description>\n<link>\n/posts/\(post.slugUrl)/\n</link>\n<pubDate>\(dateFormatter.string(from: post.created))</pubDate>\n</item>\n</channel>\n\n</rss>"
//
//        let actualXmlResponse = try drop.respond(to: rssRequest)
//
//        XCTAssertEqual(actualXmlResponse.body.bytes?.makeString(), expectedXML)
//    }
//
//    func testBlogDescriptionCanBeConfigured() throws {
//        let description = "Our fancy new RSS-feed blog"
//        drop = try TestDataBuilder.setupSteamPressDrop(description: description)
//
//        let (post, _) = try createPost()
//        let expectedXML = "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>\n<rss version=\"2.0\">\n\n<channel>\n<title>SteamPress Blog</title>\n<link>/</link>\n<description>\(description)</description>\n<generator>SteamPress</generator>\n<ttl>60</ttl>\n<pubDate>\(dateFormatter.string(from: post.created))</pubDate>\n<textinput>\n<description>Search SteamPress Blog</description>\n<title>Search</title>\n<link>/search?</link>\n<name>term</name>\n</textinput>\n<item>\n<title>\n\(post.title)\n</title>\n<description>\n\(try post.description())\n</description>\n<link>\n/posts/\(post.slugUrl)/\n</link>\n<pubDate>\(dateFormatter.string(from: post.created))</pubDate>\n</item>\n</channel>\n\n</rss>"
//
//        let actualXmlResponse = try drop.respond(to: rssRequest)
//
//        XCTAssertEqual(actualXmlResponse.body.bytes?.makeString(), expectedXML)
//    }
//
//    func testRSSFeedEndpointAddedToCorrectEndpointWhenBlogInSubPath() throws {
//        drop = try TestDataBuilder.setupSteamPressDrop(path: "blog-path")
//
//        let expectedXML = "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>\n<rss version=\"2.0\">\n\n<channel>\n<title>SteamPress Blog</title>\n<link>/blog-path/</link>\n<description>SteamPress is an open-source blogging engine written for Vapor in Swift</description>\n<generator>SteamPress</generator>\n<ttl>60</ttl>\n<textinput>\n<description>Search SteamPress Blog</description>\n<title>Search</title>\n<link>/blog-path/search?</link>\n<name>term</name>\n</textinput>\n</channel>\n\n</rss>"
//
//        let request = Request(method: .get, uri: "/blog-path/rss.xml")
//        let actualXmlResponse = try drop.respond(to: request)
//
//        XCTAssertEqual(actualXmlResponse.body.bytes?.makeString(), expectedXML)
//    }
//
//    func testPostLinkWhenBlogIsPlacedAtSubPath() throws {
//        drop = try TestDataBuilder.setupSteamPressDrop(path: "blog-path")
//        let (post, _) = try createPost()
//        let expectedXML = "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>\n<rss version=\"2.0\">\n\n<channel>\n<title>SteamPress Blog</title>\n<link>/blog-path/</link>\n<description>SteamPress is an open-source blogging engine written for Vapor in Swift</description>\n<generator>SteamPress</generator>\n<ttl>60</ttl>\n<pubDate>\(dateFormatter.string(from: post.created))</pubDate>\n<textinput>\n<description>Search SteamPress Blog</description>\n<title>Search</title>\n<link>/blog-path/search?</link>\n<name>term</name>\n</textinput>\n<item>\n<title>\n\(post.title)\n</title>\n<description>\n\(try post.description())\n</description>\n<link>\n/blog-path/posts/\(post.slugUrl)/\n</link>\n<pubDate>\(dateFormatter.string(from: post.created))</pubDate>\n</item>\n</channel>\n\n</rss>"
//
//        let request = Request(method: .get, uri: "/blog-path/rss.xml")
//        let actualXmlResponse = try drop.respond(to: request)
//
//        XCTAssertEqual(actualXmlResponse.body.bytes?.makeString(), expectedXML)
//    }
//
//    func testCopyrightCanBeAddedToRSS() throws {
//        let copyright = "Copyright ©️ 2017 SteamPress"
//        drop = try TestDataBuilder.setupSteamPressDrop(copyright: copyright)
//
//        let expectedXML = "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>\n<rss version=\"2.0\">\n\n<channel>\n<title>SteamPress Blog</title>\n<link>/</link>\n<description>SteamPress is an open-source blogging engine written for Vapor in Swift</description>\n<generator>SteamPress</generator>\n<ttl>60</ttl>\n<copyright>\(copyright)</copyright>\n<textinput>\n<description>Search SteamPress Blog</description>\n<title>Search</title>\n<link>/search?</link>\n<name>term</name>\n</textinput>\n</channel>\n\n</rss>"
//
//        let actualXmlResponse = try drop.respond(to: rssRequest)
//
//        XCTAssertEqual(actualXmlResponse.body.bytes?.makeString(), expectedXML)
//    }
//
//    func testThatTagsAreAddedToPostCorrectly() throws {
//        let (post, _) = try createPost(tags: ["Vapor 2", "Engineering"])
//        let expectedXML = "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>\n<rss version=\"2.0\">\n\n<channel>\n<title>SteamPress Blog</title>\n<link>/</link>\n<description>SteamPress is an open-source blogging engine written for Vapor in Swift</description>\n<generator>SteamPress</generator>\n<ttl>60</ttl>\n<pubDate>\(dateFormatter.string(from: post.created))</pubDate>\n<textinput>\n<description>Search SteamPress Blog</description>\n<title>Search</title>\n<link>/search?</link>\n<name>term</name>\n</textinput>\n<item>\n<title>\n\(post.title)\n</title>\n<description>\n\(try post.description())\n</description>\n<link>\n/posts/\(post.slugUrl)/\n</link>\n<category>Vapor 2</category>\n<category>Engineering</category>\n<pubDate>\(dateFormatter.string(from: post.created))</pubDate>\n</item>\n</channel>\n\n</rss>"
//
//        let actualXmlResponse = try drop.respond(to: rssRequest)
//
//        XCTAssertEqual(actualXmlResponse.body.bytes?.makeString(), expectedXML)
//    }
//
//    func testThatLinksComesFromRequestCorrectly() throws {
//        drop = try TestDataBuilder.setupSteamPressDrop(path: "blog-path")
//        let (post, _) = try createPost()
//        let expectedXML = "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>\n<rss version=\"2.0\">\n\n<channel>\n<title>SteamPress Blog</title>\n<link>http://geeks.brokenhands.io/blog-path/</link>\n<description>SteamPress is an open-source blogging engine written for Vapor in Swift</description>\n<generator>SteamPress</generator>\n<ttl>60</ttl>\n<pubDate>\(dateFormatter.string(from: post.created))</pubDate>\n<textinput>\n<description>Search SteamPress Blog</description>\n<title>Search</title>\n<link>http://geeks.brokenhands.io/blog-path/search?</link>\n<name>term</name>\n</textinput>\n<item>\n<title>\n\(post.title)\n</title>\n<description>\n\(try post.description())\n</description>\n<link>\nhttp://geeks.brokenhands.io/blog-path/posts/\(post.slugUrl)/\n</link>\n<pubDate>\(dateFormatter.string(from: post.created))</pubDate>\n</item>\n</channel>\n\n</rss>"
//
//        let httpRequest = Request(method: .get, uri: "http://geeks.brokenhands.io/blog-path/rss.xml")
//
//        let actualXmlResponse = try drop.respond(to: httpRequest)
//
//        XCTAssertEqual(actualXmlResponse.body.bytes?.makeString(), expectedXML)
//    }
//
//    func testThatLinksSpecifyHTTPSWhenComingFromReverseProxy() throws {
//        drop = try TestDataBuilder.setupSteamPressDrop(path: "blog-path")
//        let (post, _) = try createPost()
//        let expectedXML = "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>\n<rss version=\"2.0\">\n\n<channel>\n<title>SteamPress Blog</title>\n<link>https://geeks.brokenhands.io/blog-path/</link>\n<description>SteamPress is an open-source blogging engine written for Vapor in Swift</description>\n<generator>SteamPress</generator>\n<ttl>60</ttl>\n<pubDate>\(dateFormatter.string(from: post.created))</pubDate>\n<textinput>\n<description>Search SteamPress Blog</description>\n<title>Search</title>\n<link>https://geeks.brokenhands.io/blog-path/search?</link>\n<name>term</name>\n</textinput>\n<item>\n<title>\n\(post.title)\n</title>\n<description>\n\(try post.description())\n</description>\n<link>\nhttps://geeks.brokenhands.io/blog-path/posts/\(post.slugUrl)/\n</link>\n<pubDate>\(dateFormatter.string(from: post.created))</pubDate>\n</item>\n</channel>\n\n</rss>"
//
//        let httpsReverseProxyRequest = Request(method: .get, uri: "http://geeks.brokenhands.io/blog-path/rss.xml")
//        httpsReverseProxyRequest.headers["X-Forwarded-Proto"] = "https"
//
//        let actualXmlResponse = try drop.respond(to: httpsReverseProxyRequest)
//
//        XCTAssertEqual(actualXmlResponse.body.bytes?.makeString(), expectedXML)
//    }
//
//    func testImageIsProvidedIfSupplied() throws {
//        let image = "https://static.brokenhands.io/images/brokenhands.png"
//        drop = try TestDataBuilder.setupSteamPressDrop(imageURL: image)
//
//        let expectedXML = "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>\n<rss version=\"2.0\">\n\n<channel>\n<title>SteamPress Blog</title>\n<link>https://geeks.brokenhands.io/</link>\n<description>SteamPress is an open-source blogging engine written for Vapor in Swift</description>\n<generator>SteamPress</generator>\n<ttl>60</ttl>\n<image>\n<url>\(image)</url>\n<title>SteamPress Blog</title>\n<link>https://geeks.brokenhands.io/</link>\n</image>\n<textinput>\n<description>Search SteamPress Blog</description>\n<title>Search</title>\n<link>https://geeks.brokenhands.io/search?</link>\n<name>term</name>\n</textinput>\n</channel>\n\n</rss>"
//
//        let httpsRequest = Request(method: .get, uri: "https://geeks.brokenhands.io/rss.xml")
//        let actualXmlResponse = try drop.respond(to: httpsRequest)
//
//        XCTAssertEqual(actualXmlResponse.body.bytes?.makeString(), expectedXML)
//    }
//
//    func testCorrectHeaderSetForRSSFeed() throws {
//        drop = try TestDataBuilder.setupSteamPressDrop()
//        let actualXmlResponse = try drop.respond(to: rssRequest)
//
//        XCTAssertEqual(actualXmlResponse.headers[.contentType], "application/rss+xml")
//    }
//
//    func testThatDateFormatterIsCorrect() throws {
//        let createDate = Date(timeIntervalSince1970: 1505867108)
//        let (post, _) = try createPost(createDate: createDate)
//        let expectedXML = "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>\n<rss version=\"2.0\">\n\n<channel>\n<title>SteamPress Blog</title>\n<link>/</link>\n<description>SteamPress is an open-source blogging engine written for Vapor in Swift</description>\n<generator>SteamPress</generator>\n<ttl>60</ttl>\n<pubDate>Wed, 20 Sep 2017 00:25:08 GMT</pubDate>\n<textinput>\n<description>Search SteamPress Blog</description>\n<title>Search</title>\n<link>/search?</link>\n<name>term</name>\n</textinput>\n<item>\n<title>\n\(post.title)\n</title>\n<description>\n\(try post.description())\n</description>\n<link>\n/posts/\(post.slugUrl)/\n</link>\n<pubDate>Wed, 20 Sep 2017 00:25:08 GMT</pubDate>\n</item>\n</channel>\n\n</rss>"
//
//        let actualXmlResponse = try drop.respond(to: rssRequest)
//
//        XCTAssertEqual(actualXmlResponse.body.bytes?.makeString(), expectedXML)
//    }
//
//    func testThatDescriptionContainsOnlyText() throws {
//        let (post, _) = try createPost(contents: "[This is](https://www.google.com) a post that contains some **text**. \n# Formatting should be removed")
//        let expectedXML = "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>\n<rss version=\"2.0\">\n\n<channel>\n<title>SteamPress Blog</title>\n<link>/</link>\n<description>SteamPress is an open-source blogging engine written for Vapor in Swift</description>\n<generator>SteamPress</generator>\n<ttl>60</ttl>\n<pubDate>\(dateFormatter.string(from: post.created))</pubDate>\n<textinput>\n<description>Search SteamPress Blog</description>\n<title>Search</title>\n<link>/search?</link>\n<name>term</name>\n</textinput>\n<item>\n<title>\n\(post.title)\n</title>\n<description>\nThis is a post that contains some text. Formatting should be removed\n</description>\n<link>\n/posts/\(post.slugUrl)/\n</link>\n<pubDate>\(dateFormatter.string(from: post.created))</pubDate>\n</item>\n</channel>\n\n</rss>"
//
//        let actualXmlResponse = try drop.respond(to: rssRequest)
//
//        XCTAssertEqual(actualXmlResponse.body.bytes?.makeString(), expectedXML)
//    }

    // MARK: - Private functions

//    private func createPost(tags: [String]? = nil, createDate: Date? = nil, contents: String? = nil) throws -> (BlogPost, BlogUser) {
//        let author = TestDataBuilder.anyUser()
//        try author.save()
//        let post = TestDataBuilder.anyPost(author: author, creationDate: createDate ?? Date())
//
//        if let contents = contents {
//            post.contents = contents
//        }
//
//        try post.save()
//
//        if let tags = tags {
//            for tag in tags {
//                try BlogTag.addTag(tag, to: post)
//            }
//        }
//
//        return (post, author)
//    }
}

