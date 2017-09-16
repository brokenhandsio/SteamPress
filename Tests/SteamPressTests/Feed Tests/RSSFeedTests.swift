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
        ("testRSSFeedEndpointAddedToCorrectEndpointWhenBlogInSubPath", testRSSFeedEndpointAddedToCorrectEndpointWhenBlogInSubPath),
        ("testPostLinkWhenBlogIsPlacedAtSubPath", testPostLinkWhenBlogIsPlacedAtSubPath),
        ("testCopyrightCanBeAddedToRSS", testCopyrightCanBeAddedToRSS),
        ("testThatTagsAreAddedToPostCorrectly", testThatTagsAreAddedToPostCorrectly),
        ("testThatLinksComesFromRequestCorrectly", testThatLinksComesFromRequestCorrectly),
        ("testThatLinksSpecifyHTTPSWhenComingFromReverseProxy", testThatLinksSpecifyHTTPSWhenComingFromReverseProxy),
        ("testImageIsProvidedIfSupplied", testImageIsProvidedIfSupplied),
        ]

    // MARK: - Properties
    private var database: Database!
    private var drop: Droplet!
    private let rssRequest = Request(method: .get, uri: "/rss.xml")
    private let dateFormatter = DateFormatter()

    // MARK: - Overrides

    override func setUp() {
        database = try! Database(MemoryDriver())
        try! Droplet.prepare(database: database)
        try! setupDrop()
        dateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss z"
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
        let expectedXML = "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>\n<rss version=\"2.0\">\n\n<channel>\n<title>SteamPress Blog</title>\n<link>/</link>\n<description>SteamPress is an open-source blogging engine written for Vapor in Swift</description>\n<generator>SteamPress</generator>\n<ttl>60</ttl>\n</channel>\n\n</rss>"

        let actualXmlResponse = try drop.respond(to: rssRequest)

        XCTAssertEqual(actualXmlResponse.body.bytes?.makeString(), expectedXML)
    }

    func testOnePostReturnsCorrectRSSFeed() throws {
        let (post, _) = try createPost()
        let expectedXML = "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>\n<rss version=\"2.0\">\n\n<channel>\n<title>SteamPress Blog</title>\n<link>/</link>\n<description>SteamPress is an open-source blogging engine written for Vapor in Swift</description>\n<generator>SteamPress</generator>\n<ttl>60</ttl>\n<pubDate>\(dateFormatter.string(from: post.created))</pubDate>\n<item>\n<title>\n\(post.title)\n</title>\n<description>\n\(post.shortSnippet())\n</description>\n<link>\n/posts/\(post.slugUrl)/\n</link>\n<pubDate>\(dateFormatter.string(from: post.created))</pubDate>\n</item>\n</channel>\n\n</rss>"

        let actualXmlResponse = try drop.respond(to: rssRequest)

        XCTAssertEqual(actualXmlResponse.body.bytes?.makeString(), expectedXML)
    }

    func testMultiplePostsReturnsCorrectRSSFeed() throws {
        let (post, author) = try createPost()
        let anotherTitle = "Another Title"
        let contents = "This is some short contents"
        let post2 = BlogPost(title: anotherTitle, contents: contents, author: author, creationDate: Date(), slugUrl: "another-title", published: true)
        try post2.save()
        let expectedXML = "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>\n<rss version=\"2.0\">\n\n<channel>\n<title>SteamPress Blog</title>\n<link>/</link>\n<description>SteamPress is an open-source blogging engine written for Vapor in Swift</description>\n<generator>SteamPress</generator>\n<ttl>60</ttl>\n<pubDate>\(dateFormatter.string(from: post2.created))</pubDate>\n<item>\n<title>\n\(anotherTitle)\n</title>\n<description>\n\(contents)\n\n</description>\n<link>\n/posts/another-title/\n</link>\n<pubDate>\(dateFormatter.string(from: post2.created))</pubDate>\n</item>\n<item>\n<title>\n\(post.title)\n</title>\n<description>\n\(post.shortSnippet())\n</description>\n<link>\n/posts/\(post.slugUrl)/\n</link>\n<pubDate>\(dateFormatter.string(from: post.created))</pubDate>\n</item>\n</channel>\n\n</rss>"

        let actualXmlResponse = try drop.respond(to: rssRequest)

        XCTAssertEqual(actualXmlResponse.body.bytes?.makeString(), expectedXML)
    }

    func testDraftsAreNotIncludedInFeed() throws {
        let (post, author) = try createPost()
        let anotherTitle = "Another Title"
        let contents = "This is some short contents"
        let post2 = BlogPost(title: anotherTitle, contents: contents, author: author, creationDate: Date(), slugUrl: "another-title", published: false)
        try post2.save()
        let expectedXML = "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>\n<rss version=\"2.0\">\n\n<channel>\n<title>SteamPress Blog</title>\n<link>/</link>\n<description>SteamPress is an open-source blogging engine written for Vapor in Swift</description>\n<generator>SteamPress</generator>\n<ttl>60</ttl>\n<pubDate>\(dateFormatter.string(from: post.created))</pubDate>\n<item>\n<title>\n\(post.title)\n</title>\n<description>\n\(post.shortSnippet())\n</description>\n<link>\n/posts/\(post.slugUrl)/\n</link>\n<pubDate>\(dateFormatter.string(from: post.created))</pubDate>\n</item>\n</channel>\n\n</rss>"

        let actualXmlResponse = try drop.respond(to: rssRequest)

        XCTAssertEqual(actualXmlResponse.body.bytes?.makeString(), expectedXML)
    }

    func testBlogTitleCanBeConfigured() throws {
        let title = "SteamPress - The Open Source Blog"
        try setupDrop(title: title)

        let (post, _) = try createPost()
        let expectedXML = "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>\n<rss version=\"2.0\">\n\n<channel>\n<title>\(title)</title>\n<link>/</link>\n<description>SteamPress is an open-source blogging engine written for Vapor in Swift</description>\n<generator>SteamPress</generator>\n<ttl>60</ttl>\n<pubDate>\(dateFormatter.string(from: post.created))</pubDate>\n<item>\n<title>\n\(post.title)\n</title>\n<description>\n\(post.shortSnippet())\n</description>\n<link>\n/posts/\(post.slugUrl)/\n</link>\n<pubDate>\(dateFormatter.string(from: post.created))</pubDate>\n</item>\n</channel>\n\n</rss>"

        let actualXmlResponse = try drop.respond(to: rssRequest)

        XCTAssertEqual(actualXmlResponse.body.bytes?.makeString(), expectedXML)
    }

    func testBlogDescriptionCanBeConfigured() throws {
        let description = "Our fancy new RSS-feed blog"
        try setupDrop(description: description)

        let (post, _) = try createPost()
        let expectedXML = "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>\n<rss version=\"2.0\">\n\n<channel>\n<title>SteamPress Blog</title>\n<link>/</link>\n<description>\(description)</description>\n<generator>SteamPress</generator>\n<ttl>60</ttl>\n<pubDate>\(dateFormatter.string(from: post.created))</pubDate>\n<item>\n<title>\n\(post.title)\n</title>\n<description>\n\(post.shortSnippet())\n</description>\n<link>\n/posts/\(post.slugUrl)/\n</link>\n<pubDate>\(dateFormatter.string(from: post.created))</pubDate>\n</item>\n</channel>\n\n</rss>"

        let actualXmlResponse = try drop.respond(to: rssRequest)

        XCTAssertEqual(actualXmlResponse.body.bytes?.makeString(), expectedXML)
    }

    func testRSSFeedEndpointAddedToCorrectEndpointWhenBlogInSubPath() throws {
        try setupDrop(path: "blog-path")

        let expectedXML = "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>\n<rss version=\"2.0\">\n\n<channel>\n<title>SteamPress Blog</title>\n<link>/blog-path/</link>\n<description>SteamPress is an open-source blogging engine written for Vapor in Swift</description>\n<generator>SteamPress</generator>\n<ttl>60</ttl>\n</channel>\n\n</rss>"

        let request = Request(method: .get, uri: "/blog-path/rss.xml")
        let actualXmlResponse = try drop.respond(to: request)

        XCTAssertEqual(actualXmlResponse.body.bytes?.makeString(), expectedXML)
    }
    
    func testPostLinkWhenBlogIsPlacedAtSubPath() throws {
        try setupDrop(path: "blog-path")
        let (post, _) = try createPost()
        let expectedXML = "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>\n<rss version=\"2.0\">\n\n<channel>\n<title>SteamPress Blog</title>\n<link>/blog-path/</link>\n<description>SteamPress is an open-source blogging engine written for Vapor in Swift</description>\n<generator>SteamPress</generator>\n<ttl>60</ttl>\n<pubDate>\(dateFormatter.string(from: post.created))</pubDate>\n<item>\n<title>\n\(post.title)\n</title>\n<description>\n\(post.shortSnippet())\n</description>\n<link>\n/blog-path/posts/\(post.slugUrl)/\n</link>\n<pubDate>\(dateFormatter.string(from: post.created))</pubDate>\n</item>\n</channel>\n\n</rss>"
        
        let request = Request(method: .get, uri: "/blog-path/rss.xml")
        let actualXmlResponse = try drop.respond(to: request)
        
        XCTAssertEqual(actualXmlResponse.body.bytes?.makeString(), expectedXML)
    }
    
    func testCopyrightCanBeAddedToRSS() throws {
        let copyright = "Copyright ©️ 2017 SteamPress"
        try setupDrop(copyright: copyright)
        
        let expectedXML = "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>\n<rss version=\"2.0\">\n\n<channel>\n<title>SteamPress Blog</title>\n<link>/</link>\n<description>SteamPress is an open-source blogging engine written for Vapor in Swift</description>\n<generator>SteamPress</generator>\n<ttl>60</ttl>\n<copyright>\(copyright)</copyright>\n</channel>\n\n</rss>"
        
        let actualXmlResponse = try drop.respond(to: rssRequest)
        
        XCTAssertEqual(actualXmlResponse.body.bytes?.makeString(), expectedXML)
    }
    
    func testThatTagsAreAddedToPostCorrectly() throws {
        let (post, _) = try createPost(tags: ["Vapor 2", "Engineering"])
        let expectedXML = "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>\n<rss version=\"2.0\">\n\n<channel>\n<title>SteamPress Blog</title>\n<link>/</link>\n<description>SteamPress is an open-source blogging engine written for Vapor in Swift</description>\n<generator>SteamPress</generator>\n<ttl>60</ttl>\n<pubDate>\(dateFormatter.string(from: post.created))</pubDate>\n<item>\n<title>\n\(post.title)\n</title>\n<description>\n\(post.shortSnippet())\n</description>\n<link>\n/posts/\(post.slugUrl)/\n</link>\n<category>Vapor 2</category>\n<category>Engineering</category>\n<pubDate>\(dateFormatter.string(from: post.created))</pubDate>\n</item>\n</channel>\n\n</rss>"
        
        let actualXmlResponse = try drop.respond(to: rssRequest)
        
        XCTAssertEqual(actualXmlResponse.body.bytes?.makeString(), expectedXML)
    }
    
    func testThatLinksComesFromRequestCorrectly() throws {
        try setupDrop(path: "blog-path")
        let (post, _) = try createPost()
        let expectedXML = "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>\n<rss version=\"2.0\">\n\n<channel>\n<title>SteamPress Blog</title>\n<link>http://geeks.brokenhands.io/blog-path/</link>\n<description>SteamPress is an open-source blogging engine written for Vapor in Swift</description>\n<generator>SteamPress</generator>\n<ttl>60</ttl>\n<pubDate>\(dateFormatter.string(from: post.created))</pubDate>\n<item>\n<title>\n\(post.title)\n</title>\n<description>\n\(post.shortSnippet())\n</description>\n<link>\nhttp://geeks.brokenhands.io/blog-path/posts/\(post.slugUrl)/\n</link>\n<pubDate>\(dateFormatter.string(from: post.created))</pubDate>\n</item>\n</channel>\n\n</rss>"
        
        let httpRequest = Request(method: .get, uri: "http://geeks.brokenhands.io/blog-path/rss.xml")
        
        let actualXmlResponse = try drop.respond(to: httpRequest)
        
        XCTAssertEqual(actualXmlResponse.body.bytes?.makeString(), expectedXML)
    }
    
    func testThatLinksSpecifyHTTPSWhenComingFromReverseProxy() throws {
        try setupDrop(path: "blog-path")
        let (post, _) = try createPost()
        let expectedXML = "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>\n<rss version=\"2.0\">\n\n<channel>\n<title>SteamPress Blog</title>\n<link>https://geeks.brokenhands.io/blog-path/</link>\n<description>SteamPress is an open-source blogging engine written for Vapor in Swift</description>\n<generator>SteamPress</generator>\n<ttl>60</ttl>\n<pubDate>\(dateFormatter.string(from: post.created))</pubDate>\n<item>\n<title>\n\(post.title)\n</title>\n<description>\n\(post.shortSnippet())\n</description>\n<link>\nhttps://geeks.brokenhands.io/blog-path/posts/\(post.slugUrl)/\n</link>\n<pubDate>\(dateFormatter.string(from: post.created))</pubDate>\n</item>\n</channel>\n\n</rss>"
        
        let httpsReverseProxyRequest = Request(method: .get, uri: "http://geeks.brokenhands.io/blog-path/rss.xml")
        httpsReverseProxyRequest.headers["X-Forwarded-Proto"] = "https"
        
        let actualXmlResponse = try drop.respond(to: httpsReverseProxyRequest)
        
        XCTAssertEqual(actualXmlResponse.body.bytes?.makeString(), expectedXML)
    }
    
    func testImageIsProvidedIfSupplied() throws {
        let image = "https://static.brokenhands.io/images/brokenhands.png"
        try setupDrop(rssImage: image)
        
        let expectedXML = "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>\n<rss version=\"2.0\">\n\n<channel>\n<title>SteamPress Blog</title>\n<link>https://geeks.brokenhands.io/</link>\n<description>SteamPress is an open-source blogging engine written for Vapor in Swift</description>\n<generator>SteamPress</generator>\n<ttl>60</ttl>\n<image>\n<url>\(image)</url>\n<title>SteamPress Blog</title>\n<link>https://geeks.brokenhands.io/</link>\n</image>\n</channel>\n\n</rss>"
        
        let httpsRequest = Request(method: .get, uri: "https://geeks.brokenhands.io/rss.xml")
        let actualXmlResponse = try drop.respond(to: httpsRequest)
        
        XCTAssertEqual(actualXmlResponse.body.bytes?.makeString(), expectedXML)
    }

    // MARK: - Private functions
    
    private func createPost(tags: [String]? = nil) throws -> (BlogPost, BlogUser) {
        let author = TestDataBuilder.anyUser()
        try author.save()
        let post = TestDataBuilder.anyPost(author: author)
        try post.save()
        
        if let tags = tags {
            for tag in tags {
                try BlogTag.addTag(tag, to: post)
            }
        }
        
        return (post, author)
    }

    private func setupDrop(title: String? = nil, description: String? = nil, path: String? = nil, copyright: String? = nil, rssImage: String? = nil) throws {
        var config = Config([:])

        try config.set("steampress.postsPerPage", 5)

        if let title = title {
            try config.set("steampress.title", title)
        }

        if let description = description {
            try config.set("steampress.description", description)
        }

        if let path = path {
            try config.set("steampress.blogPath", path)
        }
        
        if let copyright = copyright {
            try config.set("steampress.copyright", copyright)
        }
        
        if let image = rssImage {
            try config.set("steampress.imageURL", image)
        }

        try config.set("droplet.middleware", ["error", "steampress-sessions", "blog-persist"])
        try config.set("fluent.driver", "memory")
        try config.addProvider(SteamPress.Provider.self)
        try config.addProvider(FluentProvider.Provider.self)

        drop = try Droplet(config)
    }
}
