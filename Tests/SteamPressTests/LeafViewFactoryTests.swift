import XCTest
import Vapor
import URI
import Fluent
import HTTP
@testable import SteamPress

class LeafViewFactoryTests: XCTestCase {
    
    // MARK: - allTests
    
    static var allTests = [
        ("testParametersAreSetCorrectlyOnAllTagsPage", testParametersAreSetCorrectlyOnAllTagsPage),
        ("testTagsPageGetsPassedAllTagsWithBlogCount", testTagsPageGetsPassedAllTagsWithBlogCount),
        ("testTagsPageGetsPassedTagsSortedByPageCount", testTagsPageGetsPassedTagsSortedByPageCount),
        ("testTwitterHandleSetOnAllTagsPageIfGiven", testTwitterHandleSetOnAllTagsPageIfGiven),
        ("testLoggedInUserSetOnAllTagsPageIfPassedIn", testLoggedInUserSetOnAllTagsPageIfPassedIn),
        ("testNoTagsGivenIfEmptyArrayPassedToAllTagsPage", testNoTagsGivenIfEmptyArrayPassedToAllTagsPage),
        ("testParametersAreSetCorrectlyOnAllAuthorsPage", testParametersAreSetCorrectlyOnAllAuthorsPage),
        ("testAuthorsPageGetsPassedAllAuthorsWithBlogCount", testAuthorsPageGetsPassedAllAuthorsWithBlogCount),
        ("testTwitterHandleSetOnAllAuthorsPageIfProvided", testTwitterHandleSetOnAllAuthorsPageIfProvided),
        ("testNoLoggedInUserPassedToAllAuthorsPageIfNoneProvided", testNoLoggedInUserPassedToAllAuthorsPageIfNoneProvided),
        ("testTagPageGetsTagWithCorrectParamsAndPostCount", testTagPageGetsTagWithCorrectParamsAndPostCount),
        ("testNoLoggedInUserPassedToTagPageIfNoneProvided", testNoLoggedInUserPassedToTagPageIfNoneProvided),
        ("testDisqusNamePassedToTagPageIfSet", testDisqusNamePassedToTagPageIfSet),
        ("testTwitterHandlePassedToTagPageIfSet", testTwitterHandlePassedToTagPageIfSet),
        ]
    
    // MARK: - Properties
    private var viewFactory: LeafViewFactory!
    private var viewRenderer: CapturingViewRenderer!
    private let database = Database(MemoryDriver())
    
    private let tagsURI = URI(scheme: "https", host: "test.com", path: "tags/")
    private let authorsURI = URI(scheme: "https", host: "test.com", path: "authors/")
    private let tagURI = URI(scheme: "https", host: "test.com", path: "tags/tatooine/")
    private var tagRequest: Request!
    
    // MARK: - Overrides
    
    override func setUp() {
        let drop = Droplet(arguments: ["dummy/path/", "prepare"], config: nil)
        viewRenderer = CapturingViewRenderer()
        drop.view = viewRenderer
        drop.database = database
        viewFactory = LeafViewFactory(drop: drop)
        tagRequest = try! Request(method: .get, uri: tagURI)
        let printConsole = PrintConsole()
        let prepare = Prepare(console: printConsole, preparations: [BlogUser.self, BlogPost.self, BlogTag.self, Pivot<BlogPost, BlogTag>.self], database: database)
        do {
            try prepare.run(arguments: [])
        }
        catch {
            XCTFail("failed to prepapre DB")
        }
    }
    
    // MARK: - Tests
    
    func testParametersAreSetCorrectlyOnAllTagsPage() throws {
        let tags = [BlogTag(name: "tag1"), BlogTag(name: "tag2")]
        for var tag in tags {
            try tag.save()
        }
        _ = try viewFactory.allTagsView(uri: tagsURI, allTags: tags, user: nil, siteTwitterHandle: nil)
        
        XCTAssertEqual(viewRenderer.capturedContext?["tags"]?.array?.count, 2)
        XCTAssertEqual((viewRenderer.capturedContext?["tags"]?.array?.first as? Node)?["name"], "tag1")
        XCTAssertEqual((viewRenderer.capturedContext?["tags"]?.array?[1] as? Node)?["name"], "tag2")
        XCTAssertEqual(viewRenderer.capturedContext?["uri"]?.string, "https://test.com:443/tags/")
        XCTAssertNil(viewRenderer.capturedContext?["site_twitter_handle"]?.string)
        XCTAssertNil(viewRenderer.capturedContext?["user"])
    }
    
    func testTagsPageGetsPassedAllTagsWithBlogCount() throws {
        var tag = BlogTag(name: "test tag")
        try tag.save()
        var post1 = TestDataBuilder.anyPost()
        try post1.save()
        try BlogTag.addTag(tag.name, to: post1)
        
        _ = try viewFactory.allTagsView(uri: tagsURI, allTags: [tag], user: nil, siteTwitterHandle: nil)
        XCTAssertEqual((viewRenderer.capturedContext?["tags"]?.array?.first as? Node)?["post_count"], 1)
    }
    
    func testTagsPageGetsPassedTagsSortedByPageCount() throws {
        var tag = BlogTag(name: "test tag")
        var tag2 = BlogTag(name: "tatooine")
        try tag.save()
        try tag2.save()
        var post1 = TestDataBuilder.anyPost()
        try post1.save()
        try BlogTag.addTag(tag.name, to: post1)
        var post2 = TestDataBuilder.anyPost()
        try post2.save()
        try BlogTag.addTag(tag2.name, to: post2)
        var post3 = TestDataBuilder.anyLongPost()
        try post3.save()
        try BlogTag.addTag(tag2.name, to: post3)
        
        _ = try viewFactory.allTagsView(uri: tagsURI, allTags: [tag, tag2], user: nil, siteTwitterHandle: nil)
        XCTAssertEqual(viewRenderer.capturedContext?["tags"]?.array?.count, 2)
        XCTAssertEqual((viewRenderer.capturedContext?["tags"]?.array?.first as? Node)?["name"], "tatooine")
    }
    
    func testTwitterHandleSetOnAllTagsPageIfGiven() throws {
        _ = try viewFactory.allTagsView(uri: tagsURI, allTags: [], user: nil, siteTwitterHandle: "brokenhandsio")
        XCTAssertEqual(viewRenderer.capturedContext?["site_twitter_handle"]?.string, "brokenhandsio")
    }
    
    func testLoggedInUserSetOnAllTagsPageIfPassedIn() throws {
        let user = BlogUser(name: "Luke", username: "luke", password: "")
        _ = try viewFactory.allTagsView(uri: tagsURI, allTags: [], user: user, siteTwitterHandle: nil)
        XCTAssertEqual(viewRenderer.capturedContext?["user"]?["name"]?.string, "Luke")
    }
    
    func testNoTagsGivenIfEmptyArrayPassedToAllTagsPage() throws {
        _ = try viewFactory.allTagsView(uri: tagsURI, allTags: [], user: nil, siteTwitterHandle: nil)
        XCTAssertNil(viewRenderer.capturedContext?["tags"])
    }
    
    func testParametersAreSetCorrectlyOnAllAuthorsPage() throws {
        var user1 = BlogUser(name: "Luke", username: "luke", password: "")
        try user1.save()
        var user2 = BlogUser(name: "Han", username: "han", password: "")
        try user2.save()
        let authors = [user1, user2]
        _ = try viewFactory.allAuthorsView(uri: authorsURI, allAuthors: authors, user: user1, siteTwitterHandle: nil)
        
        XCTAssertEqual(viewRenderer.capturedContext?["authors"]?.array?.count, 2)
        XCTAssertEqual((viewRenderer.capturedContext?["authors"]?.array?.first as? Node)?["name"], "Luke")
        XCTAssertEqual((viewRenderer.capturedContext?["authors"]?.array?[1] as? Node)?["name"], "Han")
        XCTAssertEqual(viewRenderer.capturedContext?["uri"]?.string, "https://test.com:443/authors/")
        XCTAssertNil(viewRenderer.capturedContext?["site_twitter_handle"]?.string)
        XCTAssertEqual(viewRenderer.capturedContext?["user"]?["name"]?.string, "Luke")
    }
    
    func testAuthorsPageGetsPassedAllAuthorsWithBlogCount() throws {
        var user1 = BlogUser(name: "Luke", username: "luke", password: "")
        try user1.save()
        var post1 = TestDataBuilder.anyPost(author: user1)
        try post1.save()
        _ = try viewFactory.allAuthorsView(uri: authorsURI, allAuthors: [user1], user: nil, siteTwitterHandle: nil)
        XCTAssertEqual((viewRenderer.capturedContext?["authors"]?.array?.first as? Node)?["post_count"], 1)
    }
    
    func testAuthorsPageGetsPassedAuthorsSortedByPageCount() throws {
        var user1 = BlogUser(name: "Luke", username: "luke", password: "")
        try user1.save()
        var user2 = BlogUser(name: "Han", username: "han", password: "")
        try user2.save()
        var post1 = TestDataBuilder.anyPost(author: user1)
        try post1.save()
        var post2 = TestDataBuilder.anyPost(author: user2)
        try post2.save()
        var post3 = TestDataBuilder.anyPost(author: user2)
        try post3.save()
        _ = try viewFactory.allAuthorsView(uri: authorsURI, allAuthors: [user1, user2], user: nil, siteTwitterHandle: nil)
        XCTAssertEqual(viewRenderer.capturedContext?["authors"]?.array?.count, 2)
        XCTAssertEqual((viewRenderer.capturedContext?["authors"]?.array?.first as? Node)?["name"], "Han")
    }
    
    func testTwitterHandleSetOnAllAuthorsPageIfProvided() throws {
        _ = try viewFactory.allAuthorsView(uri: authorsURI, allAuthors: [], user: nil, siteTwitterHandle: "brokenhandsio")
        XCTAssertEqual(viewRenderer.capturedContext?["site_twitter_handle"]?.string, "brokenhandsio")
    }
    
    func testNoLoggedInUserPassedToAllAuthorsPageIfNoneProvided() throws {
        _ = try viewFactory.allAuthorsView(uri: authorsURI, allAuthors: [], user: nil, siteTwitterHandle: nil)
        XCTAssertNil(viewRenderer.capturedContext?["user"])
    }
    
    func testNoAuthorsGivenToAuthorsPageIfNonePassedToAllAuthorsPage() throws {
        _ = try viewFactory.allAuthorsView(uri: authorsURI, allAuthors: [], user: nil, siteTwitterHandle: nil)
        XCTAssertNil(viewRenderer.capturedContext?["authors"])
    }
    
    func testTagPageGetsTagWithCorrectParamsAndPostCount() throws {
        let testTag = try setupTagPage()
        _ = try viewFactory.tagView(uri: tagURI, tag: testTag, paginatedPosts: try testTag.blogPosts().paginator(5, request: tagRequest), user: TestDataBuilder.anyUser(name: "Luke"), disqusName: nil, siteTwitterHandle: nil)
        XCTAssertEqual((viewRenderer.capturedContext?["tag"])?["post_count"], 1)
        XCTAssertEqual((viewRenderer.capturedContext?["tag"])?["name"], "tatooine")
        XCTAssertEqual(viewRenderer.capturedContext?["posts"]?["data"]?.array?.count, 1)
        XCTAssertEqual((viewRenderer.capturedContext?["posts"]?["data"]?.array?.first as? Node)?["title"]?.string, TestDataBuilder.anyPost().title)
        XCTAssertEqual(viewRenderer.capturedContext?["uri"]?.string, "https://test.com:443/tags/tatooine/")
        XCTAssertEqual(viewRenderer.capturedContext?["tagPage"]?.bool, true)
        XCTAssertEqual(viewRenderer.capturedContext?["user"]?["name"]?.string, "Luke")
        XCTAssertNil(viewRenderer.capturedContext?["disqusName"])
        XCTAssertNil(viewRenderer.capturedContext?["site_twitter_handle"])
    }
    
    func testNoLoggedInUserPassedToTagPageIfNoneProvided() throws {
        let testTag = try setupTagPage()
        _ = try viewFactory.tagView(uri: tagURI, tag: testTag, paginatedPosts: try testTag.blogPosts().paginator(5, request: tagRequest), user: nil, disqusName: nil, siteTwitterHandle: nil)
        XCTAssertNil(viewRenderer.capturedContext?["user"])
    }
    
    func testDisqusNamePassedToTagPageIfSet() throws {
        let testTag = try setupTagPage()
        _ = try viewFactory.tagView(uri: tagURI, tag: testTag, paginatedPosts: try testTag.blogPosts().paginator(5, request: tagRequest), user: nil, disqusName: "brokenhands", siteTwitterHandle: nil)
        XCTAssertEqual(viewRenderer.capturedContext?["disqusName"]?.string, "brokenhands")
    }
    
    func testTwitterHandlePassedToTagPageIfSet() throws {
        let testTag = try setupTagPage()
        _ = try viewFactory.tagView(uri: tagURI, tag: testTag, paginatedPosts: try testTag.blogPosts().paginator(5, request: tagRequest), user: nil, disqusName: nil, siteTwitterHandle: "brokenhandsio")
        XCTAssertEqual(viewRenderer.capturedContext?["site_twitter_handle"]?.string, "brokenhandsio")
    }
    
    private func setupTagPage() throws -> BlogTag {
        var tag = BlogTag(name: "tatooine")
        try tag.save()
        var user = BlogUser(name: "Luke", username: "luke", password: "")
        try user.save()
        var post1 = TestDataBuilder.anyPost(author: user)
        try post1.save()
        try BlogTag.addTag(tag.name, to: post1)
        return tag
    }
    
}

class CapturingViewRenderer: ViewRenderer {
    required init(viewsDir: String = "tests") {}
    
    private(set) var capturedContext: Node? = nil
    func make(_ path: String, _ context: Node) throws -> View {
        self.capturedContext = context
        return View(data: try "Test".makeBytes())
    }
}
