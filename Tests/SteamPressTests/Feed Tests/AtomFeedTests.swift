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
        ("testThatFeedCorrectForTwoPosts", testThatFeedCorrectForTwoPosts),
        ("testThatDraftsDontAppearInFeed", testThatDraftsDontAppearInFeed),
        ("testThatEditedPostsHaveUpdatedTimes", testThatEditedPostsHaveUpdatedTimes),
        ("testThatTagsAppearWhenPostHasThem", testThatTagsAppearWhenPostHasThem),
        ("testThatFullLinksWorksForPosts", testThatFullLinksWorksForPosts),
        ("testThatHTTPSLinksWorkForPostsBehindReverseProxy", testThatHTTPSLinksWorkForPostsBehindReverseProxy),
        ("testCorrectHeaderSetForAtomFeed", testCorrectHeaderSetForAtomFeed),
        ("testThatDateFormatterIsCorrect", testThatDateFormatterIsCorrect),
        ]

//    // MARK: - Properties
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

        XCTAssertEqual(actualXmlResponse.string, expectedXML)
    }

    func testThatFeedTitleCanBeConfigured() throws {
        let title = "My Awesome Blog"
        app = try TestDataBuilder.getSteamPressApp(title: title)

        let expectedXML = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<feed xmlns=\"http://www.w3.org/2005/Atom\">\n\n<title>\(title)</title>\n<subtitle>SteamPress is an open-source blogging engine written for Vapor in Swift</subtitle>\n<id>/</id>\n<link rel=\"alternate\" type=\"text/html\" href=\"/\"/>\n<link rel=\"self\" type=\"application/atom+xml\" href=\"/atom.xml\"/>\n<generator uri=\"https://www.steampress.io/\">SteamPress</generator>\n<updated>\(dateFormatter.string(from: Date()))</updated>\n</feed>"

        let actualXmlResponse = try TestDataBuilder.getResponse(to: atomRequest, using: app)
        XCTAssertEqual(actualXmlResponse.string, expectedXML)
    }

    func testThatFeedSubtitleCanBeConfigured() throws {
        let description = "This is a test for my blog"
        app = try TestDataBuilder.getSteamPressApp(description: description)

        let expectedXML = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<feed xmlns=\"http://www.w3.org/2005/Atom\">\n\n<title>SteamPress Blog</title>\n<subtitle>\(description)</subtitle>\n<id>/</id>\n<link rel=\"alternate\" type=\"text/html\" href=\"/\"/>\n<link rel=\"self\" type=\"application/atom+xml\" href=\"/atom.xml\"/>\n<generator uri=\"https://www.steampress.io/\">SteamPress</generator>\n<updated>\(dateFormatter.string(from: Date()))</updated>\n</feed>"

        let actualXmlResponse = try TestDataBuilder.getResponse(to: atomRequest, using: app)
        XCTAssertEqual(actualXmlResponse.string, expectedXML)
    }

    func testThatRightsCanBeConifgured() throws {
        let copyright = "Copyright ©️ 2017 SteamPress"
        app = try TestDataBuilder.getSteamPressApp(copyright: copyright)

        let expectedXML = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<feed xmlns=\"http://www.w3.org/2005/Atom\">\n\n<title>SteamPress Blog</title>\n<subtitle>SteamPress is an open-source blogging engine written for Vapor in Swift</subtitle>\n<id>/</id>\n<link rel=\"alternate\" type=\"text/html\" href=\"/\"/>\n<link rel=\"self\" type=\"application/atom+xml\" href=\"/atom.xml\"/>\n<generator uri=\"https://www.steampress.io/\">SteamPress</generator>\n<updated>\(dateFormatter.string(from: Date()))</updated>\n<rights>\(copyright)</rights>\n</feed>"

        let actualXmlResponse = try TestDataBuilder.getResponse(to: atomRequest, using: app)
        XCTAssertEqual(actualXmlResponse.string, expectedXML)
    }

    func testThatLinksAreCorrectForFullURI() throws {
        app = try TestDataBuilder.getSteamPressApp(path: "blog")
        let expectedXML = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<feed xmlns=\"http://www.w3.org/2005/Atom\">\n\n<title>SteamPress Blog</title>\n<subtitle>SteamPress is an open-source blogging engine written for Vapor in Swift</subtitle>\n<id>https://geeks.brokenhands.io/blog/</id>\n<link rel=\"alternate\" type=\"text/html\" href=\"https://geeks.brokenhands.io/blog/\"/>\n<link rel=\"self\" type=\"application/atom+xml\" href=\"https://geeks.brokenhands.io/blog/atom.xml\"/>\n<generator uri=\"https://www.steampress.io/\">SteamPress</generator>\n<updated>\(dateFormatter.string(from: Date()))</updated>\n</feed>"

        let request = HTTPRequest(method: .get, uri: "https://geeks.brokenhands.io/blog/atom.xml")
        let actualXmlResponse = try TestDataBuilder.getResponse(to: request, using: app)
        XCTAssertEqual(actualXmlResponse.string, expectedXML)
    }

    func testThatHTTPSLinksWorkWhenBehindReverseProxy() throws {
        app = try TestDataBuilder.getSteamPressApp(path: "blog")
        let expectedXML = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<feed xmlns=\"http://www.w3.org/2005/Atom\">\n\n<title>SteamPress Blog</title>\n<subtitle>SteamPress is an open-source blogging engine written for Vapor in Swift</subtitle>\n<id>https://geeks.brokenhands.io/blog/</id>\n<link rel=\"alternate\" type=\"text/html\" href=\"https://geeks.brokenhands.io/blog/\"/>\n<link rel=\"self\" type=\"application/atom+xml\" href=\"https://geeks.brokenhands.io/blog/atom.xml\"/>\n<generator uri=\"https://www.steampress.io/\">SteamPress</generator>\n<updated>\(dateFormatter.string(from: Date()))</updated>\n</feed>"

        var request = HTTPRequest(method: .get, uri: "http://geeks.brokenhands.io/blog/atom.xml")
        request.headers["X-Forwarded-Proto"] = "https"
        let actualXmlResponse = try TestDataBuilder.getResponse(to: request, using: app)

        XCTAssertEqual(actualXmlResponse.string, expectedXML)
    }

    func testThatLogoCanBeConfigured() throws {
        let imageURL = "https://static.brokenhands.io/images/feeds/atom.png"
        app = try TestDataBuilder.getSteamPressApp(imageURL: imageURL)
        let expectedXML = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<feed xmlns=\"http://www.w3.org/2005/Atom\">\n\n<title>SteamPress Blog</title>\n<subtitle>SteamPress is an open-source blogging engine written for Vapor in Swift</subtitle>\n<id>/</id>\n<link rel=\"alternate\" type=\"text/html\" href=\"/\"/>\n<link rel=\"self\" type=\"application/atom+xml\" href=\"/atom.xml\"/>\n<generator uri=\"https://www.steampress.io/\">SteamPress</generator>\n<updated>\(dateFormatter.string(from: Date()))</updated>\n<logo>\(imageURL)</logo>\n</feed>"

        let actualXmlResponse = try TestDataBuilder.getResponse(to: atomRequest, using: app)
        XCTAssertEqual(actualXmlResponse.string, expectedXML)
    }

    func testThatFeedIsCorrectForOnePost() throws {
        app = try TestDataBuilder.getSteamPressApp()

        let testData = try app.withConnection(to: .sqlite) { (conn) -> Future<TestData> in
            return try Future(TestDataBuilder.createPost(for: conn))
        }.blockingAwait()

        let post = testData.post
        let author = testData.author

        let expectedXML = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<feed xmlns=\"http://www.w3.org/2005/Atom\">\n\n<title>SteamPress Blog</title>\n<subtitle>SteamPress is an open-source blogging engine written for Vapor in Swift</subtitle>\n<id>/</id>\n<link rel=\"alternate\" type=\"text/html\" href=\"/\"/>\n<link rel=\"self\" type=\"application/atom+xml\" href=\"/atom.xml\"/>\n<generator uri=\"https://www.steampress.io/\">SteamPress</generator>\n<updated>\(self.dateFormatter.string(from: Date()))</updated>\n<entry>\n<id>/posts-id/1/</id>\n<title>\(post.title)</title>\n<updated>\(self.dateFormatter.string(from: post.created))</updated>\n<published>\(self.dateFormatter.string(from: post.created))</published>\n<author>\n<name>\(author.name)</name>\n<uri>/authors/\(author.username)/</uri>\n</author>\n<summary>\(try post.description())</summary>\n<link rel=\"alternate\" href=\"/posts/\(post.slugUrl)/\" />\n</entry>\n</feed>"

        let actualXmlResponse = try TestDataBuilder.getResponse(to: atomRequest, using: app)
        XCTAssertEqual(actualXmlResponse.string, expectedXML)
    }

    func testThatFeedCorrectForTwoPosts() throws {
        app = try TestDataBuilder.getSteamPressApp()

        let testData = try app.withConnection(to: .sqlite) { (conn) -> Future<TestData> in
            return try Future(TestDataBuilder.createPost(for: conn))
        }.blockingAwait()

        let post = testData.post
        let author = testData.author

        let secondTitle = "Another Post"
        let secondPostDate = Date()
        let post2 = try BlogPost(title: secondTitle, contents: "#Some Interesting Post\nThis contains a load of contents...", author: author, creationDate: secondPostDate, slugUrl: "another-post", published: true)

        _ = try app.withConnection(to: .sqlite) { conn in
            return Future(post2.save(on: conn))
        }.blockingAwait()
        
        let expectedXML = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<feed xmlns=\"http://www.w3.org/2005/Atom\">\n\n<title>SteamPress Blog</title>\n<subtitle>SteamPress is an open-source blogging engine written for Vapor in Swift</subtitle>\n<id>/</id>\n<link rel=\"alternate\" type=\"text/html\" href=\"/\"/>\n<link rel=\"self\" type=\"application/atom+xml\" href=\"/atom.xml\"/>\n<generator uri=\"https://www.steampress.io/\">SteamPress</generator>\n<updated>\(dateFormatter.string(from: Date()))</updated>\n<entry>\n<id>/posts-id/2/</id>\n<title>\(secondTitle)</title>\n<updated>\(dateFormatter.string(from: secondPostDate))</updated>\n<published>\(dateFormatter.string(from: secondPostDate))</published>\n<author>\n<name>\(author.name)</name>\n<uri>/authors/\(author.username)/</uri>\n</author>\n<summary>\(try post2.description())</summary>\n<link rel=\"alternate\" href=\"/posts/\(post2.slugUrl)/\" />\n</entry>\n<entry>\n<id>/posts-id/1/</id>\n<title>\(post.title)</title>\n<updated>\(dateFormatter.string(from: post.created))</updated>\n<published>\(dateFormatter.string(from: post.created))</published>\n<author>\n<name>\(author.name)</name>\n<uri>/authors/\(author.username)/</uri>\n</author>\n<summary>\(try post.description())</summary>\n<link rel=\"alternate\" href=\"/posts/\(post.slugUrl)/\" />\n</entry>\n</feed>"

        let actualXmlResponse = try TestDataBuilder.getResponse(to: atomRequest, using: app)
        XCTAssertEqual(actualXmlResponse.string, expectedXML)
    }

    func testThatDraftsDontAppearInFeed() throws {
        app = try TestDataBuilder.getSteamPressApp()

        let testData = try app.withConnection(to: .sqlite) { (conn) -> Future<TestData> in
            return try Future(TestDataBuilder.createPost(for: conn))
            }.blockingAwait()

        let post = testData.post
        let author = testData.author

        let post2 = try BlogPost(title: "Another Post", contents: "#Some Interesting Post\nThis contains a load of contents...", author: author, creationDate: Date(), slugUrl: "another-post", published: false)

        _ = try app.withConnection(to: .sqlite) { conn in
            return Future(post2.save(on: conn))
        }.blockingAwait()

        let expectedXML = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<feed xmlns=\"http://www.w3.org/2005/Atom\">\n\n<title>SteamPress Blog</title>\n<subtitle>SteamPress is an open-source blogging engine written for Vapor in Swift</subtitle>\n<id>/</id>\n<link rel=\"alternate\" type=\"text/html\" href=\"/\"/>\n<link rel=\"self\" type=\"application/atom+xml\" href=\"/atom.xml\"/>\n<generator uri=\"https://www.steampress.io/\">SteamPress</generator>\n<updated>\(dateFormatter.string(from: Date()))</updated>\n<entry>\n<id>/posts-id/1/</id>\n<title>\(post.title)</title>\n<updated>\(dateFormatter.string(from: post.created))</updated>\n<published>\(dateFormatter.string(from: post.created))</published>\n<author>\n<name>\(author.name)</name>\n<uri>/authors/\(author.username)/</uri>\n</author>\n<summary>\(try post.description())</summary>\n<link rel=\"alternate\" href=\"/posts/\(post.slugUrl)/\" />\n</entry>\n</feed>"

        let actualXmlResponse = try TestDataBuilder.getResponse(to: atomRequest, using: app)
        XCTAssertEqual(actualXmlResponse.string, expectedXML)
    }

    func testThatEditedPostsHaveUpdatedTimes() throws {
        app = try TestDataBuilder.getSteamPressApp()

        let firstPostDate = Date().addingTimeInterval(-3600)
        let testData = try app.withConnection(to: .sqlite) { (conn) -> Future<TestData> in
            return try Future(TestDataBuilder.createPost(for: conn, createdDate: firstPostDate))
            }.blockingAwait()

        let post = testData.post
        let author = testData.author

        let secondTitle = "Another Post"
        let secondPostDate = Date().addingTimeInterval(-60)
        let newEditDate = Date()
        let post2 = try BlogPost(title: secondTitle, contents: "#Some Interesting Post\nThis contains a load of contents...", author: author, creationDate: secondPostDate, slugUrl: "another-post", published: true)
        post2.lastEdited = newEditDate

        _ = try app.withConnection(to: .sqlite) { conn in
            return Future(post2.save(on: conn))
        }.blockingAwait()

        let expectedXML = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<feed xmlns=\"http://www.w3.org/2005/Atom\">\n\n<title>SteamPress Blog</title>\n<subtitle>SteamPress is an open-source blogging engine written for Vapor in Swift</subtitle>\n<id>/</id>\n<link rel=\"alternate\" type=\"text/html\" href=\"/\"/>\n<link rel=\"self\" type=\"application/atom+xml\" href=\"/atom.xml\"/>\n<generator uri=\"https://www.steampress.io/\">SteamPress</generator>\n<updated>\(dateFormatter.string(from: newEditDate))</updated>\n<entry>\n<id>/posts-id/2/</id>\n<title>\(secondTitle)</title>\n<updated>\(dateFormatter.string(from: newEditDate))</updated>\n<published>\(dateFormatter.string(from: secondPostDate))</published>\n<author>\n<name>\(author.name)</name>\n<uri>/authors/\(author.username)/</uri>\n</author>\n<summary>\(try post2.description())</summary>\n<link rel=\"alternate\" href=\"/posts/\(post2.slugUrl)/\" />\n</entry>\n<entry>\n<id>/posts-id/1/</id>\n<title>\(post.title)</title>\n<updated>\(dateFormatter.string(from: firstPostDate))</updated>\n<published>\(dateFormatter.string(from: firstPostDate))</published>\n<author>\n<name>\(author.name)</name>\n<uri>/authors/\(author.username)/</uri>\n</author>\n<summary>\(try post.description())</summary>\n<link rel=\"alternate\" href=\"/posts/\(post.slugUrl)/\" />\n</entry>\n</feed>"

        let actualXmlResponse = try TestDataBuilder.getResponse(to: atomRequest, using: app)
        XCTAssertEqual(actualXmlResponse.string, expectedXML)
    }

    func testThatTagsAppearWhenPostHasThem() throws {
        app = try TestDataBuilder.getSteamPressApp()
        let tag1 = "Vapor 2"
        let tag2 = "Engineering"

        let testData = try app.withConnection(to: .sqlite) { (conn) -> Future<TestData> in
            return try Future(TestDataBuilder.createPost(for: conn, tags: [tag1, tag2]))
            }.blockingAwait()

        let post = testData.post
        let author = testData.author

        let expectedXML = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<feed xmlns=\"http://www.w3.org/2005/Atom\">\n\n<title>SteamPress Blog</title>\n<subtitle>SteamPress is an open-source blogging engine written for Vapor in Swift</subtitle>\n<id>/</id>\n<link rel=\"alternate\" type=\"text/html\" href=\"/\"/>\n<link rel=\"self\" type=\"application/atom+xml\" href=\"/atom.xml\"/>\n<generator uri=\"https://www.steampress.io/\">SteamPress</generator>\n<updated>\(dateFormatter.string(from: Date()))</updated>\n<entry>\n<id>/posts-id/1/</id>\n<title>\(post.title)</title>\n<updated>\(dateFormatter.string(from: post.created))</updated>\n<published>\(dateFormatter.string(from: post.created))</published>\n<author>\n<name>\(author.name)</name>\n<uri>/authors/\(author.username)/</uri>\n</author>\n<summary>\(try post.description())</summary>\n<link rel=\"alternate\" href=\"/posts/\(post.slugUrl)/\" />\n<category term=\"\(tag1)\"/>\n<category term=\"\(tag2)\"/>\n</entry>\n</feed>"

        let actualXmlResponse = try TestDataBuilder.getResponse(to: atomRequest, using: app)
        XCTAssertEqual(actualXmlResponse.string, expectedXML)
    }

    func testThatFullLinksWorksForPosts() throws {
        app = try TestDataBuilder.getSteamPressApp(path: "blog")

        let testData = try app.withConnection(to: .sqlite) { (conn) -> Future<TestData> in
            return try Future(TestDataBuilder.createPost(for: conn))
            }.blockingAwait()

        let post = testData.post
        let author = testData.author

        let expectedXML = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<feed xmlns=\"http://www.w3.org/2005/Atom\">\n\n<title>SteamPress Blog</title>\n<subtitle>SteamPress is an open-source blogging engine written for Vapor in Swift</subtitle>\n<id>https://geeks.brokenhands.io/blog/</id>\n<link rel=\"alternate\" type=\"text/html\" href=\"https://geeks.brokenhands.io/blog/\"/>\n<link rel=\"self\" type=\"application/atom+xml\" href=\"https://geeks.brokenhands.io/blog/atom.xml\"/>\n<generator uri=\"https://www.steampress.io/\">SteamPress</generator>\n<updated>\(dateFormatter.string(from: Date()))</updated>\n<entry>\n<id>https://geeks.brokenhands.io/blog/posts-id/1/</id>\n<title>\(post.title)</title>\n<updated>\(dateFormatter.string(from: post.created))</updated>\n<published>\(dateFormatter.string(from: post.created))</published>\n<author>\n<name>\(author.name)</name>\n<uri>https://geeks.brokenhands.io/blog/authors/\(author.username)/</uri>\n</author>\n<summary>\(try post.description())</summary>\n<link rel=\"alternate\" href=\"https://geeks.brokenhands.io/blog/posts/\(post.slugUrl)/\" />\n</entry>\n</feed>"

        let request = HTTPRequest(method: .get, uri: "https://geeks.brokenhands.io/blog/atom.xml")

        let actualXmlResponse = try TestDataBuilder.getResponse(to: request, using: app)
        XCTAssertEqual(actualXmlResponse.string, expectedXML)
    }

    func testThatHTTPSLinksWorkForPostsBehindReverseProxy() throws {
        app = try TestDataBuilder.getSteamPressApp(path: "blog")

        let testData = try app.withConnection(to: .sqlite) { (conn) -> Future<TestData> in
            return try Future(TestDataBuilder.createPost(for: conn))
            }.blockingAwait()

        let post = testData.post
        let author = testData.author

        let expectedXML = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<feed xmlns=\"http://www.w3.org/2005/Atom\">\n\n<title>SteamPress Blog</title>\n<subtitle>SteamPress is an open-source blogging engine written for Vapor in Swift</subtitle>\n<id>https://geeks.brokenhands.io/blog/</id>\n<link rel=\"alternate\" type=\"text/html\" href=\"https://geeks.brokenhands.io/blog/\"/>\n<link rel=\"self\" type=\"application/atom+xml\" href=\"https://geeks.brokenhands.io/blog/atom.xml\"/>\n<generator uri=\"https://www.steampress.io/\">SteamPress</generator>\n<updated>\(dateFormatter.string(from: Date()))</updated>\n<entry>\n<id>https://geeks.brokenhands.io/blog/posts-id/1/</id>\n<title>\(post.title)</title>\n<updated>\(dateFormatter.string(from: post.created))</updated>\n<published>\(dateFormatter.string(from: post.created))</published>\n<author>\n<name>\(author.name)</name>\n<uri>https://geeks.brokenhands.io/blog/authors/\(author.username)/</uri>\n</author>\n<summary>\(try post.description())</summary>\n<link rel=\"alternate\" href=\"https://geeks.brokenhands.io/blog/posts/\(post.slugUrl)/\" />\n</entry>\n</feed>"

        var request = HTTPRequest(method: .get, uri: "http://geeks.brokenhands.io/blog/atom.xml")
        request.headers["X-Forwarded-Proto"] = "https"

        let actualXmlResponse = try TestDataBuilder.getResponse(to: request, using: app)
        XCTAssertEqual(actualXmlResponse.string, expectedXML)
    }

    func testCorrectHeaderSetForAtomFeed() throws {
        app = try TestDataBuilder.getSteamPressApp()
        let actualXmlResponse = try TestDataBuilder.getResponse(to: atomRequest, using: app)
        XCTAssertEqual(actualXmlResponse.http.headers[.contentType], "application/atom+xml")
    }

    func testThatDateFormatterIsCorrect() throws {
        app = try TestDataBuilder.getSteamPressApp()
        let createDate = Date(timeIntervalSince1970: 1505867108)

        let testData = try app.withConnection(to: .sqlite) { (conn) -> Future<TestData> in
            return try Future(TestDataBuilder.createPost(for: conn, createdDate: createDate))
        }.blockingAwait()

        let post = testData.post
        let author = testData.author

        let expectedXML = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<feed xmlns=\"http://www.w3.org/2005/Atom\">\n\n<title>SteamPress Blog</title>\n<subtitle>SteamPress is an open-source blogging engine written for Vapor in Swift</subtitle>\n<id>/</id>\n<link rel=\"alternate\" type=\"text/html\" href=\"/\"/>\n<link rel=\"self\" type=\"application/atom+xml\" href=\"/atom.xml\"/>\n<generator uri=\"https://www.steampress.io/\">SteamPress</generator>\n<updated>2017-09-20T00:25:08Z</updated>\n<entry>\n<id>/posts-id/1/</id>\n<title>\(post.title)</title>\n<updated>2017-09-20T00:25:08Z</updated>\n<published>2017-09-20T00:25:08Z</published>\n<author>\n<name>\(author.name)</name>\n<uri>/authors/\(author.username)/</uri>\n</author>\n<summary>\(try post.description())</summary>\n<link rel=\"alternate\" href=\"/posts/\(post.slugUrl)/\" />\n</entry>\n</feed>"

        let actualXmlResponse = try TestDataBuilder.getResponse(to: atomRequest, using: app)
        XCTAssertEqual(actualXmlResponse.string, expectedXML)
    }
}

struct TestData {
    let post: BlogPost<SQLiteDatabase>
    let author: BlogUser<SQLiteDatabase>
}

// TODO Move
extension Response {
    var string: String? {
        let data = try! self.http.body.makeData(max: 1000).blockingAwait()
        return String(data: data, encoding: .utf8)
    }
}

