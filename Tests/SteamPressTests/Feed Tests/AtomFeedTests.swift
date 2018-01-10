@testable import SteamPress
import XCTest
import Vapor
import Fluent
import FluentSQLite

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
        ("testThatFeedIsCorrectForOnePost", testThatFeedIsCorrectForOnePost),
//        ("testThatFeedCorrectForTwoPosts", testThatFeedCorrectForTwoPosts),
//        ("testThatDraftsDontAppearInFeed", testThatDraftsDontAppearInFeed),
//        ("testThatEditedPostsHaveUpdatedTimes", testThatEditedPostsHaveUpdatedTimes),
//        ("testThatTagsAppearWhenPostHasThem", testThatTagsAppearWhenPostHasThem),
//        ("testThatFullLinksWorksForPosts", testThatFullLinksWorksForPosts),
//        ("testThatHTTPSLinksWorkForPostsBehindReverseProxy", testThatHTTPSLinksWorkForPostsBehindReverseProxy),
//        ("testCorrectHeaderSetForAtomFeed", testCorrectHeaderSetForAtomFeed),
//        ("testThatDateFormatterIsCorrect", testThatDateFormatterIsCorrect),
        ]

//    // MARK: - Properties
//    private var database: Database!
    private var app: Application!
    private let atomRequest = HTTPRequest(method: .get, uri: "/atom.xml")
    private let dateFormatter = DateFormatter()

    // MARK: - Overrides

    override func setUp() {
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
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

    func testNoPostsReturnsCorrectAtomFeed() throws {
        app = try TestDataBuilder.getSteamPressApp()

        let expectedXML = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<feed xmlns=\"http://www.w3.org/2005/Atom\">\n\n<title>SteamPress Blog</title>\n<subtitle>SteamPress is an open-source blogging engine written for Vapor in Swift</subtitle>\n<id>/</id>\n<link rel=\"alternate\" type=\"text/html\" href=\"/\"/>\n<link rel=\"self\" type=\"application/atom+xml\" href=\"/atom.xml\"/>\n<generator uri=\"https://www.steampress.io/\">SteamPress</generator>\n<updated>\(dateFormatter.string(from: Date()))</updated>\n</feed>"

        let actualXmlResponse = try TestDataBuilder.getResponse(to: atomRequest, using: app)

        XCTAssertEqual(actualXmlResponse.body.string, expectedXML)
    }

    func testThatFeedTitleCanBeConfigured() throws {
        let title = "My Awesome Blog"
        app = try TestDataBuilder.getSteamPressApp(title: title)

        let expectedXML = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<feed xmlns=\"http://www.w3.org/2005/Atom\">\n\n<title>\(title)</title>\n<subtitle>SteamPress is an open-source blogging engine written for Vapor in Swift</subtitle>\n<id>/</id>\n<link rel=\"alternate\" type=\"text/html\" href=\"/\"/>\n<link rel=\"self\" type=\"application/atom+xml\" href=\"/atom.xml\"/>\n<generator uri=\"https://www.steampress.io/\">SteamPress</generator>\n<updated>\(dateFormatter.string(from: Date()))</updated>\n</feed>"

        let actualXmlResponse = try TestDataBuilder.getResponse(to: atomRequest, using: app)
        XCTAssertEqual(actualXmlResponse.body.string, expectedXML)
    }

    func testThatFeedSubtitleCanBeConfigured() throws {
        let description = "This is a test for my blog"
        app = try TestDataBuilder.getSteamPressApp(description: description)

        let expectedXML = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<feed xmlns=\"http://www.w3.org/2005/Atom\">\n\n<title>SteamPress Blog</title>\n<subtitle>\(description)</subtitle>\n<id>/</id>\n<link rel=\"alternate\" type=\"text/html\" href=\"/\"/>\n<link rel=\"self\" type=\"application/atom+xml\" href=\"/atom.xml\"/>\n<generator uri=\"https://www.steampress.io/\">SteamPress</generator>\n<updated>\(dateFormatter.string(from: Date()))</updated>\n</feed>"

        let actualXmlResponse = try TestDataBuilder.getResponse(to: atomRequest, using: app)
        XCTAssertEqual(actualXmlResponse.body.string, expectedXML)
    }

    func testThatRightsCanBeConifgured() throws {
        let copyright = "Copyright ©️ 2017 SteamPress"
        app = try TestDataBuilder.getSteamPressApp(copyright: copyright)

        let expectedXML = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<feed xmlns=\"http://www.w3.org/2005/Atom\">\n\n<title>SteamPress Blog</title>\n<subtitle>SteamPress is an open-source blogging engine written for Vapor in Swift</subtitle>\n<id>/</id>\n<link rel=\"alternate\" type=\"text/html\" href=\"/\"/>\n<link rel=\"self\" type=\"application/atom+xml\" href=\"/atom.xml\"/>\n<generator uri=\"https://www.steampress.io/\">SteamPress</generator>\n<updated>\(dateFormatter.string(from: Date()))</updated>\n<rights>\(copyright)</rights>\n</feed>"

        let actualXmlResponse = try TestDataBuilder.getResponse(to: atomRequest, using: app)
        XCTAssertEqual(actualXmlResponse.body.string, expectedXML)
    }

    func testThatLinksAreCorrectForFullURI() throws {
        app = try TestDataBuilder.getSteamPressApp(path: "blog")
        let expectedXML = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<feed xmlns=\"http://www.w3.org/2005/Atom\">\n\n<title>SteamPress Blog</title>\n<subtitle>SteamPress is an open-source blogging engine written for Vapor in Swift</subtitle>\n<id>https://geeks.brokenhands.io/blog/</id>\n<link rel=\"alternate\" type=\"text/html\" href=\"https://geeks.brokenhands.io/blog/\"/>\n<link rel=\"self\" type=\"application/atom+xml\" href=\"https://geeks.brokenhands.io/blog/atom.xml\"/>\n<generator uri=\"https://www.steampress.io/\">SteamPress</generator>\n<updated>\(dateFormatter.string(from: Date()))</updated>\n</feed>"

        let request = HTTPRequest(method: .get, uri: "https://geeks.brokenhands.io/blog/atom.xml")
        let actualXmlResponse = try TestDataBuilder.getResponse(to: request, using: app)
        XCTAssertEqual(actualXmlResponse.body.string, expectedXML)
    }

    func testThatHTTPSLinksWorkWhenBehindReverseProxy() throws {
        app = try TestDataBuilder.getSteamPressApp(path: "blog")
        let expectedXML = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<feed xmlns=\"http://www.w3.org/2005/Atom\">\n\n<title>SteamPress Blog</title>\n<subtitle>SteamPress is an open-source blogging engine written for Vapor in Swift</subtitle>\n<id>https://geeks.brokenhands.io/blog/</id>\n<link rel=\"alternate\" type=\"text/html\" href=\"https://geeks.brokenhands.io/blog/\"/>\n<link rel=\"self\" type=\"application/atom+xml\" href=\"https://geeks.brokenhands.io/blog/atom.xml\"/>\n<generator uri=\"https://www.steampress.io/\">SteamPress</generator>\n<updated>\(dateFormatter.string(from: Date()))</updated>\n</feed>"

        var request = HTTPRequest(method: .get, uri: "http://geeks.brokenhands.io/blog/atom.xml")
        request.headers["X-Forwarded-Proto"] = "https"
        let actualXmlResponse = try TestDataBuilder.getResponse(to: request, using: app)

        XCTAssertEqual(actualXmlResponse.body.string, expectedXML)
    }

    func testThatLogoCanBeConfigured() throws {
        let imageURL = "https://static.brokenhands.io/images/feeds/atom.png"
        app = try TestDataBuilder.getSteamPressApp(imageURL: imageURL)
        let expectedXML = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<feed xmlns=\"http://www.w3.org/2005/Atom\">\n\n<title>SteamPress Blog</title>\n<subtitle>SteamPress is an open-source blogging engine written for Vapor in Swift</subtitle>\n<id>/</id>\n<link rel=\"alternate\" type=\"text/html\" href=\"/\"/>\n<link rel=\"self\" type=\"application/atom+xml\" href=\"/atom.xml\"/>\n<generator uri=\"https://www.steampress.io/\">SteamPress</generator>\n<updated>\(dateFormatter.string(from: Date()))</updated>\n<logo>\(imageURL)</logo>\n</feed>"

        let actualXmlResponse = try TestDataBuilder.getResponse(to: atomRequest, using: app)
        XCTAssertEqual(actualXmlResponse.body.string, expectedXML)
    }

    func testThatFeedIsCorrectForOnePost() throws {
        app = try TestDataBuilder.getSteamPressApp()

        let testData = try app.withConnection(to: .sqlite) { (conn) -> Future<TestData> in
            return try Future(self.createPost(for: conn))
        }.blockingAwait()

        let post = testData.post
        let author = testData.author

        let expectedXML = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<feed xmlns=\"http://www.w3.org/2005/Atom\">\n\n<title>SteamPress Blog</title>\n<subtitle>SteamPress is an open-source blogging engine written for Vapor in Swift</subtitle>\n<id>/</id>\n<link rel=\"alternate\" type=\"text/html\" href=\"/\"/>\n<link rel=\"self\" type=\"application/atom+xml\" href=\"/atom.xml\"/>\n<generator uri=\"https://www.steampress.io/\">SteamPress</generator>\n<updated>\(self.dateFormatter.string(from: Date()))</updated>\n<entry>\n<id>/posts-id/1/</id>\n<title>\(post.title)</title>\n<updated>\(self.dateFormatter.string(from: post.created))</updated>\n<published>\(self.dateFormatter.string(from: post.created))</published>\n<author>\n<name>\(author.name)</name>\n<uri>/authors/\(author.username)/</uri>\n</author>\n<summary>\(try post.description())</summary>\n<link rel=\"alternate\" href=\"/posts/\(post.slugUrl)/\" />\n</entry>\n</feed>"

        let actualXmlResponse = try TestDataBuilder.getResponse(to: atomRequest, using: app) { req in

        }
        XCTAssertEqual(actualXmlResponse.body.string, expectedXML)
    }

//    func testThatFeedCorrectForTwoPosts() throws {
//        drop = try TestDataBuilder.setupSteamPressDrop()
//        let (post, author) = try createPost()
//        let secondTitle = "Another Post"
//        let secondPostDate = Date()
//        let post2 = BlogPost(title: secondTitle, contents: "#Some Interesting Post\nThis contains a load of contents...", author: author, creationDate: secondPostDate, slugUrl: "another-post", published: true)
//        try post2.save()
//        let expectedXML = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<feed xmlns=\"http://www.w3.org/2005/Atom\">\n\n<title>SteamPress Blog</title>\n<subtitle>SteamPress is an open-source blogging engine written for Vapor in Swift</subtitle>\n<id>/</id>\n<link rel=\"alternate\" type=\"text/html\" href=\"/\"/>\n<link rel=\"self\" type=\"application/atom+xml\" href=\"/atom.xml\"/>\n<generator uri=\"https://www.steampress.io/\">SteamPress</generator>\n<updated>\(dateFormatter.string(from: Date()))</updated>\n<entry>\n<id>/posts-id/2/</id>\n<title>\(secondTitle)</title>\n<updated>\(dateFormatter.string(from: secondPostDate))</updated>\n<published>\(dateFormatter.string(from: secondPostDate))</published>\n<author>\n<name>\(author.name)</name>\n<uri>/authors/\(author.username)/</uri>\n</author>\n<summary>\(try post2.description())</summary>\n<link rel=\"alternate\" href=\"/posts/\(post2.slugUrl)/\" />\n</entry>\n<entry>\n<id>/posts-id/1/</id>\n<title>\(post.title)</title>\n<updated>\(dateFormatter.string(from: post.created))</updated>\n<published>\(dateFormatter.string(from: post.created))</published>\n<author>\n<name>\(author.name)</name>\n<uri>/authors/\(author.username)/</uri>\n</author>\n<summary>\(try post.description())</summary>\n<link rel=\"alternate\" href=\"/posts/\(post.slugUrl)/\" />\n</entry>\n</feed>"
//        
//        let actualXmlResponse = try drop.respond(to: atomRequest)
//        
//        XCTAssertEqual(actualXmlResponse.body.bytes?.makeString(), expectedXML)
//    }
//    
//    func testThatDraftsDontAppearInFeed() throws {
//        drop = try TestDataBuilder.setupSteamPressDrop()
//        let (post, author) = try createPost()
//        let post2 = BlogPost(title: "Another Post", contents: "#Some Interesting Post\nThis contains a load of contents...", author: author, creationDate: Date(), slugUrl: "another-post", published: false)
//        try post2.save()
//        let expectedXML = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<feed xmlns=\"http://www.w3.org/2005/Atom\">\n\n<title>SteamPress Blog</title>\n<subtitle>SteamPress is an open-source blogging engine written for Vapor in Swift</subtitle>\n<id>/</id>\n<link rel=\"alternate\" type=\"text/html\" href=\"/\"/>\n<link rel=\"self\" type=\"application/atom+xml\" href=\"/atom.xml\"/>\n<generator uri=\"https://www.steampress.io/\">SteamPress</generator>\n<updated>\(dateFormatter.string(from: Date()))</updated>\n<entry>\n<id>/posts-id/1/</id>\n<title>\(post.title)</title>\n<updated>\(dateFormatter.string(from: post.created))</updated>\n<published>\(dateFormatter.string(from: post.created))</published>\n<author>\n<name>\(author.name)</name>\n<uri>/authors/\(author.username)/</uri>\n</author>\n<summary>\(try post.description())</summary>\n<link rel=\"alternate\" href=\"/posts/\(post.slugUrl)/\" />\n</entry>\n</feed>"
//        
//        let actualXmlResponse = try drop.respond(to: atomRequest)
//        
//        XCTAssertEqual(actualXmlResponse.body.bytes?.makeString(), expectedXML)
//    }
//    
//    func testThatEditedPostsHaveUpdatedTimes() throws {
//        drop = try TestDataBuilder.setupSteamPressDrop()
//        let firstPostDate = Date().addingTimeInterval(-3600)
//        let (post, author) = try createPost(createDate: firstPostDate)
//        let secondTitle = "Another Post"
//        let secondPostDate = Date().addingTimeInterval(-60)
//        let newEditDate = Date()
//        let post2 = BlogPost(title: secondTitle, contents: "#Some Interesting Post\nThis contains a load of contents...", author: author, creationDate: secondPostDate, slugUrl: "another-post", published: true)
//        post2.lastEdited = newEditDate
//        try post2.save()
//        let expectedXML = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<feed xmlns=\"http://www.w3.org/2005/Atom\">\n\n<title>SteamPress Blog</title>\n<subtitle>SteamPress is an open-source blogging engine written for Vapor in Swift</subtitle>\n<id>/</id>\n<link rel=\"alternate\" type=\"text/html\" href=\"/\"/>\n<link rel=\"self\" type=\"application/atom+xml\" href=\"/atom.xml\"/>\n<generator uri=\"https://www.steampress.io/\">SteamPress</generator>\n<updated>\(dateFormatter.string(from: newEditDate))</updated>\n<entry>\n<id>/posts-id/2/</id>\n<title>\(secondTitle)</title>\n<updated>\(dateFormatter.string(from: newEditDate))</updated>\n<published>\(dateFormatter.string(from: secondPostDate))</published>\n<author>\n<name>\(author.name)</name>\n<uri>/authors/\(author.username)/</uri>\n</author>\n<summary>\(try post2.description())</summary>\n<link rel=\"alternate\" href=\"/posts/\(post2.slugUrl)/\" />\n</entry>\n<entry>\n<id>/posts-id/1/</id>\n<title>\(post.title)</title>\n<updated>\(dateFormatter.string(from: firstPostDate))</updated>\n<published>\(dateFormatter.string(from: firstPostDate))</published>\n<author>\n<name>\(author.name)</name>\n<uri>/authors/\(author.username)/</uri>\n</author>\n<summary>\(try post.description())</summary>\n<link rel=\"alternate\" href=\"/posts/\(post.slugUrl)/\" />\n</entry>\n</feed>"
//
//        let actualXmlResponse = try drop.respond(to: atomRequest)
//
//        XCTAssertEqual(actualXmlResponse.body.bytes?.makeString(), expectedXML)
//    }
//    
//    func testThatTagsAppearWhenPostHasThem() throws {
//        drop = try TestDataBuilder.setupSteamPressDrop()
//        let tag1 = "Vapor 2"
//        let tag2 = "Engineering"
//        let (post, author) = try createPost(tags: [tag1, tag2])
//        let expectedXML = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<feed xmlns=\"http://www.w3.org/2005/Atom\">\n\n<title>SteamPress Blog</title>\n<subtitle>SteamPress is an open-source blogging engine written for Vapor in Swift</subtitle>\n<id>/</id>\n<link rel=\"alternate\" type=\"text/html\" href=\"/\"/>\n<link rel=\"self\" type=\"application/atom+xml\" href=\"/atom.xml\"/>\n<generator uri=\"https://www.steampress.io/\">SteamPress</generator>\n<updated>\(dateFormatter.string(from: Date()))</updated>\n<entry>\n<id>/posts-id/1/</id>\n<title>\(post.title)</title>\n<updated>\(dateFormatter.string(from: post.created))</updated>\n<published>\(dateFormatter.string(from: post.created))</published>\n<author>\n<name>\(author.name)</name>\n<uri>/authors/\(author.username)/</uri>\n</author>\n<summary>\(try post.description())</summary>\n<link rel=\"alternate\" href=\"/posts/\(post.slugUrl)/\" />\n<category term=\"\(tag1)\"/>\n<category term=\"\(tag2)\"/>\n</entry>\n</feed>"
//
//        let actualXmlResponse = try drop.respond(to: atomRequest)
//
//        XCTAssertEqual(actualXmlResponse.body.bytes?.makeString(), expectedXML)
//    }
//    
//    func testThatFullLinksWorksForPosts() throws {
//        drop = try TestDataBuilder.setupSteamPressDrop(path: "blog")
//        let (post, author) = try createPost()
//        let expectedXML = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<feed xmlns=\"http://www.w3.org/2005/Atom\">\n\n<title>SteamPress Blog</title>\n<subtitle>SteamPress is an open-source blogging engine written for Vapor in Swift</subtitle>\n<id>https://geeks.brokenhands.io/blog/</id>\n<link rel=\"alternate\" type=\"text/html\" href=\"https://geeks.brokenhands.io/blog/\"/>\n<link rel=\"self\" type=\"application/atom+xml\" href=\"https://geeks.brokenhands.io/blog/atom.xml\"/>\n<generator uri=\"https://www.steampress.io/\">SteamPress</generator>\n<updated>\(dateFormatter.string(from: Date()))</updated>\n<entry>\n<id>https://geeks.brokenhands.io/blog/posts-id/1/</id>\n<title>\(post.title)</title>\n<updated>\(dateFormatter.string(from: post.created))</updated>\n<published>\(dateFormatter.string(from: post.created))</published>\n<author>\n<name>\(author.name)</name>\n<uri>https://geeks.brokenhands.io/blog/authors/\(author.username)/</uri>\n</author>\n<summary>\(try post.description())</summary>\n<link rel=\"alternate\" href=\"https://geeks.brokenhands.io/blog/posts/\(post.slugUrl)/\" />\n</entry>\n</feed>"
//
//        let request = Request(method: .get, uri: "https://geeks.brokenhands.io/blog/atom.xml")
//        let actualXmlResponse = try drop.respond(to: request)
//
//        XCTAssertEqual(actualXmlResponse.body.bytes?.makeString(), expectedXML)
//    }
//    
//    func testThatHTTPSLinksWorkForPostsBehindReverseProxy() throws {
//        drop = try TestDataBuilder.setupSteamPressDrop(path: "blog")
//        let (post, author) = try createPost()
//        let expectedXML = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<feed xmlns=\"http://www.w3.org/2005/Atom\">\n\n<title>SteamPress Blog</title>\n<subtitle>SteamPress is an open-source blogging engine written for Vapor in Swift</subtitle>\n<id>https://geeks.brokenhands.io/blog/</id>\n<link rel=\"alternate\" type=\"text/html\" href=\"https://geeks.brokenhands.io/blog/\"/>\n<link rel=\"self\" type=\"application/atom+xml\" href=\"https://geeks.brokenhands.io/blog/atom.xml\"/>\n<generator uri=\"https://www.steampress.io/\">SteamPress</generator>\n<updated>\(dateFormatter.string(from: Date()))</updated>\n<entry>\n<id>https://geeks.brokenhands.io/blog/posts-id/1/</id>\n<title>\(post.title)</title>\n<updated>\(dateFormatter.string(from: post.created))</updated>\n<published>\(dateFormatter.string(from: post.created))</published>\n<author>\n<name>\(author.name)</name>\n<uri>https://geeks.brokenhands.io/blog/authors/\(author.username)/</uri>\n</author>\n<summary>\(try post.description())</summary>\n<link rel=\"alternate\" href=\"https://geeks.brokenhands.io/blog/posts/\(post.slugUrl)/\" />\n</entry>\n</feed>"
//
//        let request = Request(method: .get, uri: "http://geeks.brokenhands.io/blog/atom.xml")
//        request.headers["X-Forwarded-Proto"] = "https"
//
//        let actualXmlResponse = try drop.respond(to: request)
//
//        XCTAssertEqual(actualXmlResponse.body.bytes?.makeString(), expectedXML)
//    }
//
//    func testCorrectHeaderSetForAtomFeed() throws {
//        drop = try TestDataBuilder.setupSteamPressDrop()
//        let actualXmlResponse = try drop.respond(to: atomRequest)
//
//        XCTAssertEqual(actualXmlResponse.headers[.contentType], "application/atom+xml")
//    }
//    
//    func testThatDateFormatterIsCorrect() throws {
//        drop = try TestDataBuilder.setupSteamPressDrop()
//        let createDate = Date(timeIntervalSince1970: 1505867108)
//        let (post, author) = try createPost(createDate: createDate)
//        let expectedXML = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<feed xmlns=\"http://www.w3.org/2005/Atom\">\n\n<title>SteamPress Blog</title>\n<subtitle>SteamPress is an open-source blogging engine written for Vapor in Swift</subtitle>\n<id>/</id>\n<link rel=\"alternate\" type=\"text/html\" href=\"/\"/>\n<link rel=\"self\" type=\"application/atom+xml\" href=\"/atom.xml\"/>\n<generator uri=\"https://www.steampress.io/\">SteamPress</generator>\n<updated>2017-09-20T00:25:08Z</updated>\n<entry>\n<id>/posts-id/1/</id>\n<title>\(post.title)</title>\n<updated>2017-09-20T00:25:08Z</updated>\n<published>2017-09-20T00:25:08Z</published>\n<author>\n<name>\(author.name)</name>\n<uri>/authors/\(author.username)/</uri>\n</author>\n<summary>\(try post.description())</summary>\n<link rel=\"alternate\" href=\"/posts/\(post.slugUrl)/\" />\n</entry>\n</feed>"
//        
//        let actualXmlResponse = try drop.respond(to: atomRequest)
//        
//        XCTAssertEqual(actualXmlResponse.body.bytes?.makeString(), expectedXML)
//    }

    // MARK: - Private functions

    private func createPost(for db: DatabaseConnectable, tags: [String]? = nil, createDate: Date? = nil) throws -> TestData {
        let author = TestDataBuilder.anyUser()
        try author.save(on: db).blockingAwait()
        let post = TestDataBuilder.anyPost(author: author, creationDate: createDate ?? Date())
        try post.save(on: db).blockingAwait()

//        if let tags = tags {
//            for tag in tags {
//                try BlogTag.addTag(tag, to: post)
//            }
//        }

        return TestData(post: post, author: author)
    }
}

struct TestData {
    let post: BlogPost<SQLiteDatabase>
    let author: BlogUser<SQLiteDatabase>
}

// TODO Move
extension HTTPBody {
    var string: String? {
        guard let data = self.data else {
            return nil
        }

        return String(data: data, encoding: .utf8)
    }
}

