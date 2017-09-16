import SteamPress
import XCTest
import Vapor
import FluentProvider

class AtomFeedTests: XCTestCase {
    
    // MARK: - allTests
    
    static var allTests = [
        ("testLinuxTestSuiteIncludesAllTests", testLinuxTestSuiteIncludesAllTests),
        ("testNoPostsReturnsCorrectAtomFeed", testNoPostsReturnsCorrectAtomFeed),
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
    
    func testNoPostsReturnsCorrectAtomFeed() throws {
        let expectedXML = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n\n<feed xmlns=\"http://www.w3.org/2005/Atom\">\n\n<title>SteamPress Blog</title>\n<subtitle>SteamPress is an open-source blogging engine written for Vapor in Swift</subtitle>\n<link href=\"/atom.xml\" rel=\"self\" />\n<link href=\"/\" />\n<id>urn:uuid:60a76c80-d399-11d9-b91C-0003939e0af6</id>\n<updated>2003-12-13T18:30:02Z</updated>\n\n</feed>"
        
        let actualXmlResponse = try drop.respond(to: atomRequest)
        
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
