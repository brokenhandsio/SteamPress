import SteamPress
import XCTest
import Vapor
import FluentProvider

class AtomFeedTests: XCTestCase {
    
    // MARK: - allTests
    
    static var allTests = [
        ("testLinuxTestSuiteIncludesAllTests", testLinuxTestSuiteIncludesAllTests),
        ("testNoPostsReturnsCorrectAtomFeed", testNoPostsReturnsCorrectAtomFeed),
        ("testThatFeedTitleCanBeConfigured", testThatFeedTitleCanBeConfigured),
        ("testThatFeedSubtitleCanBeConfigured", testThatFeedSubtitleCanBeConfigured),
        ("testThatRightsCanBeConifgured", testThatRightsCanBeConifgured),
        ("testThatLinksAreCorrectForFullURI", testThatLinksAreCorrectForFullURI),
        ("testThatHTTPSLinksWorkWhenBehindReverseProxy", testThatHTTPSLinksWorkWhenBehindReverseProxy),
        ("testThatLogoCanBeConfigured", testThatLogoCanBeConfigured),
        ]
    
    // MARK: - Properties
    private var database: Database!
    private var drop: Droplet!
    private let atomRequest = Request(method: .get, uri: "/atom.xml")
    private let dateFormatter = DateFormatter()
    
    // MARK: - Overrides
    
    override func setUp() {
        database = try! Database(MemoryDriver())
        try! Droplet.prepare(database: database)
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
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
    
    func testNoPostsReturnsCorrectAtomFeed() throws {
        try setupDrop()
        let expectedXML = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<feed xmlns=\"http://www.w3.org/2005/Atom\">\n\n<title>SteamPress Blog</title>\n<subtitle>SteamPress is an open-source blogging engine written for Vapor in Swift</subtitle>\n<id>/</id>\n<link rel=\"alternate\" type=\"text/html\" href=\"/\"/>\n<link rel=\"self\" type=\"application/atom+xml\" href=\"/atom.xml\"/>\n<generator uri=\"https://www.steampress.io/\">SteamPress</generator>\n<updated>\(dateFormatter.string(from: Date()))</updated>\n</feed>"
        
        let actualXmlResponse = try drop.respond(to: atomRequest)
        
        XCTAssertEqual(actualXmlResponse.body.bytes?.makeString(), expectedXML)
    }
    
    func testThatFeedTitleCanBeConfigured() throws {
        let title = "My Awesome Blog"
        try setupDrop(title: title)
        
        let expectedXML = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<feed xmlns=\"http://www.w3.org/2005/Atom\">\n\n<title>\(title)</title>\n<subtitle>SteamPress is an open-source blogging engine written for Vapor in Swift</subtitle>\n<id>/</id>\n<link rel=\"alternate\" type=\"text/html\" href=\"/\"/>\n<link rel=\"self\" type=\"application/atom+xml\" href=\"/atom.xml\"/>\n<generator uri=\"https://www.steampress.io/\">SteamPress</generator>\n<updated>\(dateFormatter.string(from: Date()))</updated>\n</feed>"
        
        let actualXmlResponse = try drop.respond(to: atomRequest)
        
        XCTAssertEqual(actualXmlResponse.body.bytes?.makeString(), expectedXML)
    }
    
    func testThatFeedSubtitleCanBeConfigured() throws {
        let description = "This is a test for my blog"
        try setupDrop(description: description)
        
        let expectedXML = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<feed xmlns=\"http://www.w3.org/2005/Atom\">\n\n<title>SteamPress Blog</title>\n<subtitle>\(description)</subtitle>\n<id>/</id>\n<link rel=\"alternate\" type=\"text/html\" href=\"/\"/>\n<link rel=\"self\" type=\"application/atom+xml\" href=\"/atom.xml\"/>\n<generator uri=\"https://www.steampress.io/\">SteamPress</generator>\n<updated>\(dateFormatter.string(from: Date()))</updated>\n</feed>"
        
        let actualXmlResponse = try drop.respond(to: atomRequest)
        
        XCTAssertEqual(actualXmlResponse.body.bytes?.makeString(), expectedXML)
    }
    
    func testThatRightsCanBeConifgured() throws {
        let copyright = "Copyright ©️ 2017 SteamPress"
        try setupDrop(copyright: copyright)
        
        let expectedXML = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<feed xmlns=\"http://www.w3.org/2005/Atom\">\n\n<title>SteamPress Blog</title>\n<subtitle>SteamPress is an open-source blogging engine written for Vapor in Swift</subtitle>\n<id>/</id>\n<link rel=\"alternate\" type=\"text/html\" href=\"/\"/>\n<link rel=\"self\" type=\"application/atom+xml\" href=\"/atom.xml\"/>\n<generator uri=\"https://www.steampress.io/\">SteamPress</generator>\n<updated>\(dateFormatter.string(from: Date()))</updated>\n<rights>\(copyright)</rights>\n</feed>"
        
        let actualXmlResponse = try drop.respond(to: atomRequest)
        
        XCTAssertEqual(actualXmlResponse.body.bytes?.makeString(), expectedXML)
    }
    
    func testThatLinksAreCorrectForFullURI() throws {
        try setupDrop(path: "blog")
        let expectedXML = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<feed xmlns=\"http://www.w3.org/2005/Atom\">\n\n<title>SteamPress Blog</title>\n<subtitle>SteamPress is an open-source blogging engine written for Vapor in Swift</subtitle>\n<id>https://geeks.brokenhands.io/blog/</id>\n<link rel=\"alternate\" type=\"text/html\" href=\"https://geeks.brokenhands.io/blog/\"/>\n<link rel=\"self\" type=\"application/atom+xml\" href=\"https://geeks.brokenhands.io/blog/atom.xml\"/>\n<generator uri=\"https://www.steampress.io/\">SteamPress</generator>\n<updated>\(dateFormatter.string(from: Date()))</updated>\n</feed>"
        
        let request = Request(method: .get, uri: "https://geeks.brokenhands.io/blog/atom.xml")
        let actualXmlResponse = try drop.respond(to: request)
        
        XCTAssertEqual(actualXmlResponse.body.bytes?.makeString(), expectedXML)
    }
    
    func testThatHTTPSLinksWorkWhenBehindReverseProxy() throws {
        try setupDrop(path: "blog")
        let expectedXML = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<feed xmlns=\"http://www.w3.org/2005/Atom\">\n\n<title>SteamPress Blog</title>\n<subtitle>SteamPress is an open-source blogging engine written for Vapor in Swift</subtitle>\n<id>https://geeks.brokenhands.io/blog/</id>\n<link rel=\"alternate\" type=\"text/html\" href=\"https://geeks.brokenhands.io/blog/\"/>\n<link rel=\"self\" type=\"application/atom+xml\" href=\"https://geeks.brokenhands.io/blog/atom.xml\"/>\n<generator uri=\"https://www.steampress.io/\">SteamPress</generator>\n<updated>\(dateFormatter.string(from: Date()))</updated>\n</feed>"
        
        let request = Request(method: .get, uri: "http://geeks.brokenhands.io/blog/atom.xml")
        request.headers["X-Forwarded-Proto"] = "https"
        let actualXmlResponse = try drop.respond(to: request)
        
        XCTAssertEqual(actualXmlResponse.body.bytes?.makeString(), expectedXML)
    }
    
    func testThatLogoCanBeConfigured() throws {
        let imageURL = "https://static.brokenhands.io/images/feeds/atom.png"
        try setupDrop(imageURL: imageURL)
        let expectedXML = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<feed xmlns=\"http://www.w3.org/2005/Atom\">\n\n<title>SteamPress Blog</title>\n<subtitle>SteamPress is an open-source blogging engine written for Vapor in Swift</subtitle>\n<id>/</id>\n<link rel=\"alternate\" type=\"text/html\" href=\"/\"/>\n<link rel=\"self\" type=\"application/atom+xml\" href=\"/atom.xml\"/>\n<generator uri=\"https://www.steampress.io/\">SteamPress</generator>\n<updated>\(dateFormatter.string(from: Date()))</updated>\n<logo>\(imageURL)</logo>\n</feed>"
        
        let actualXmlResponse = try drop.respond(to: atomRequest)
        
        XCTAssertEqual(actualXmlResponse.body.bytes?.makeString(), expectedXML)
    }
    
    func testThatFeedIsCorrectForOnePost() throws {
        
    }
    
    func testThatFeedCorrectForTwoPosts() throws {
        
    }
    
    func testThatDraftsDontAppearInFeed() throws {
        
    }
    
    func testThatEditedPostsHaveNewIDAndUpdatedTimes() throws {
        
    }
    
    func testThatFullLinksWorksForPosts() throws {
        
    }
    
    func testThatHTTPSLinksWorkForPostsBehindReverseProxy() throws {
        
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
    
    private func setupDrop(title: String? = nil, description: String? = nil, path: String? = nil, copyright: String? = nil, imageURL: String? = nil) throws {
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
        
        if let image = imageURL {
            try config.set("steampress.imageURL", image)
        }
        
        try config.set("droplet.middleware", ["error", "steampress-sessions", "blog-persist"])
        try config.set("fluent.driver", "memory")
        try config.addProvider(SteamPress.Provider.self)
        try config.addProvider(FluentProvider.Provider.self)
        
        drop = try Droplet(config)
    }
}
