@testable import SteamPress
import XCTest
import Vapor

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
        ("testThatFeedIsCorrectForOnePostUnderPath", testThatFeedIsCorrectForOnePostUnderPath),
        ("testThatFeedCorrectForTwoPosts", testThatFeedCorrectForTwoPosts),
        ("testThatDraftsDontAppearInFeed", testThatDraftsDontAppearInFeed),
        ("testThatEditedPostsHaveUpdatedTimes", testThatEditedPostsHaveUpdatedTimes),
        ("testThatTagsAppearWhenPostHasThem", testThatTagsAppearWhenPostHasThem),
        ("testThatFullLinksWorksForPosts", testThatFullLinksWorksForPosts),
        ("testThatHTTPSLinksWorkForPostsBehindReverseProxy", testThatHTTPSLinksWorkForPostsBehindReverseProxy),
        ("testCorrectHeaderSetForAtomFeed", testCorrectHeaderSetForAtomFeed),
        ("testThatDateFormatterIsCorrect", testThatDateFormatterIsCorrect),
        ]

    // MARK: - Properties
    private var testWorld: TestWorld!
    private let atomPath = "/atom.xml"
    private let blogAtomPath = "/blog/atom.xml"
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
        testWorld = try TestWorld.create()

        let expectedXML = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<feed xmlns=\"http://www.w3.org/2005/Atom\">\n\n<title>SteamPress Blog</title>\n<subtitle>SteamPress is an open-source blogging engine written for Vapor in Swift</subtitle>\n<id>/</id>\n<link rel=\"alternate\" type=\"text/html\" href=\"/\"/>\n<link rel=\"self\" type=\"application/atom+xml\" href=\"/atom.xml\"/>\n<generator uri=\"https://www.steampress.io/\">SteamPress</generator>\n<updated>\(dateFormatter.string(from: Date()))</updated>\n</feed>"

        let actualXmlResponse = try testWorld.getResponseString(to: atomPath)

        XCTAssertEqual(actualXmlResponse, expectedXML)
    }

    func testThatFeedTitleCanBeConfigured() throws {
        let title = "My Awesome Blog"
        let feedInformation = FeedInformation(title: title)
        testWorld = try TestWorld.create(feedInformation: feedInformation)

        let expectedXML = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<feed xmlns=\"http://www.w3.org/2005/Atom\">\n\n<title>\(title)</title>\n<subtitle>SteamPress is an open-source blogging engine written for Vapor in Swift</subtitle>\n<id>/</id>\n<link rel=\"alternate\" type=\"text/html\" href=\"/\"/>\n<link rel=\"self\" type=\"application/atom+xml\" href=\"/atom.xml\"/>\n<generator uri=\"https://www.steampress.io/\">SteamPress</generator>\n<updated>\(dateFormatter.string(from: Date()))</updated>\n</feed>"

        let actualXmlResponse = try testWorld.getResponseString(to: atomPath)
        XCTAssertEqual(actualXmlResponse, expectedXML)
    }

    func testThatFeedSubtitleCanBeConfigured() throws {
        let description = "This is a test for my blog"
        let feedInformation = FeedInformation(description: description)
        testWorld = try TestWorld.create(feedInformation: feedInformation)

        let expectedXML = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<feed xmlns=\"http://www.w3.org/2005/Atom\">\n\n<title>SteamPress Blog</title>\n<subtitle>\(description)</subtitle>\n<id>/</id>\n<link rel=\"alternate\" type=\"text/html\" href=\"/\"/>\n<link rel=\"self\" type=\"application/atom+xml\" href=\"/atom.xml\"/>\n<generator uri=\"https://www.steampress.io/\">SteamPress</generator>\n<updated>\(dateFormatter.string(from: Date()))</updated>\n</feed>"

        let actualXmlResponse = try testWorld.getResponseString(to: atomPath)
        XCTAssertEqual(actualXmlResponse, expectedXML)
    }

    func testThatRightsCanBeConifgured() throws {
        let copyright = "Copyright ©️ 2019 SteamPress"
        let feedInformation = FeedInformation(copyright: copyright)
        testWorld = try TestWorld.create(feedInformation: feedInformation)

        let expectedXML = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<feed xmlns=\"http://www.w3.org/2005/Atom\">\n\n<title>SteamPress Blog</title>\n<subtitle>SteamPress is an open-source blogging engine written for Vapor in Swift</subtitle>\n<id>/</id>\n<link rel=\"alternate\" type=\"text/html\" href=\"/\"/>\n<link rel=\"self\" type=\"application/atom+xml\" href=\"/atom.xml\"/>\n<generator uri=\"https://www.steampress.io/\">SteamPress</generator>\n<updated>\(dateFormatter.string(from: Date()))</updated>\n<rights>\(copyright)</rights>\n</feed>"

        let actualXmlResponse = try testWorld.getResponseString(to: atomPath)
        XCTAssertEqual(actualXmlResponse, expectedXML)
    }

    func testThatLinksAreCorrectForFullURI() throws {
        testWorld = try TestWorld.create(path: "blog")
        let expectedXML = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<feed xmlns=\"http://www.w3.org/2005/Atom\">\n\n<title>SteamPress Blog</title>\n<subtitle>SteamPress is an open-source blogging engine written for Vapor in Swift</subtitle>\n<id>https://geeks.brokenhands.io/blog/</id>\n<link rel=\"alternate\" type=\"text/html\" href=\"https://geeks.brokenhands.io/blog/\"/>\n<link rel=\"self\" type=\"application/atom+xml\" href=\"https://geeks.brokenhands.io/blog/atom.xml\"/>\n<generator uri=\"https://www.steampress.io/\">SteamPress</generator>\n<updated>\(dateFormatter.string(from: Date()))</updated>\n</feed>"

        let fullPath = "https://geeks.brokenhands.io/blog/atom.xml"
        let actualXmlResponse = try testWorld.getResponseString(to: fullPath)
        XCTAssertEqual(actualXmlResponse, expectedXML)
    }

    func testThatHTTPSLinksWorkWhenBehindReverseProxy() throws {
        testWorld = try TestWorld.create()
        let expectedXML = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<feed xmlns=\"http://www.w3.org/2005/Atom\">\n\n<title>SteamPress Blog</title>\n<subtitle>SteamPress is an open-source blogging engine written for Vapor in Swift</subtitle>\n<id>https://geeks.brokenhands.io/</id>\n<link rel=\"alternate\" type=\"text/html\" href=\"https://geeks.brokenhands.io/\"/>\n<link rel=\"self\" type=\"application/atom+xml\" href=\"https://geeks.brokenhands.io/atom.xml\"/>\n<generator uri=\"https://www.steampress.io/\">SteamPress</generator>\n<updated>\(dateFormatter.string(from: Date()))</updated>\n</feed>"

        let fullPath = "http://geeks.brokenhands.io/atom.xml"
        let actualXmlResponse = try testWorld.getResponseString(to: fullPath, headers: ["X-Forwarded-Proto": "https"])
        XCTAssertEqual(actualXmlResponse, expectedXML)
    }

    func testThatLogoCanBeConfigured() throws {
        let imageURL = "https://static.brokenhands.io/images/feeds/atom.png"
        let feedInformation = FeedInformation(imageURL: imageURL)
        testWorld = try TestWorld.create(feedInformation: feedInformation)
        let expectedXML = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<feed xmlns=\"http://www.w3.org/2005/Atom\">\n\n<title>SteamPress Blog</title>\n<subtitle>SteamPress is an open-source blogging engine written for Vapor in Swift</subtitle>\n<id>/</id>\n<link rel=\"alternate\" type=\"text/html\" href=\"/\"/>\n<link rel=\"self\" type=\"application/atom+xml\" href=\"/atom.xml\"/>\n<generator uri=\"https://www.steampress.io/\">SteamPress</generator>\n<updated>\(dateFormatter.string(from: Date()))</updated>\n<logo>\(imageURL)</logo>\n</feed>"

        let actualXmlResponse = try testWorld.getResponseString(to: atomPath)
        XCTAssertEqual(actualXmlResponse, expectedXML)
    }

    func testThatFeedIsCorrectForOnePost() throws {
        testWorld = try TestWorld.create()
        let testData = try testWorld.createPost()

        let post = testData.post
        let author = testData.author

        let expectedXML = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<feed xmlns=\"http://www.w3.org/2005/Atom\">\n\n<title>SteamPress Blog</title>\n<subtitle>SteamPress is an open-source blogging engine written for Vapor in Swift</subtitle>\n<id>/</id>\n<link rel=\"alternate\" type=\"text/html\" href=\"/\"/>\n<link rel=\"self\" type=\"application/atom+xml\" href=\"/atom.xml\"/>\n<generator uri=\"https://www.steampress.io/\">SteamPress</generator>\n<updated>\(self.dateFormatter.string(from: Date()))</updated>\n<entry>\n<id>/posts-id/1/</id>\n<title>\(post.title)</title>\n<updated>\(self.dateFormatter.string(from: post.created))</updated>\n<published>\(self.dateFormatter.string(from: post.created))</published>\n<author>\n<name>\(author.name)</name>\n<uri>/authors/\(author.username)/</uri>\n</author>\n<summary>\(try post.description())</summary>\n<link rel=\"alternate\" href=\"/posts/\(post.slugUrl)/\" />\n</entry>\n</feed>"

        let actualXmlResponse = try testWorld.getResponseString(to: atomPath)
        XCTAssertEqual(actualXmlResponse, expectedXML)
    }
    
    func testThatFeedIsCorrectForOnePostUnderPath() throws {
        testWorld = try TestWorld.create(path: "blog")
        let testData = try testWorld.createPost()
        
        let post = testData.post
        let author = testData.author
        
        let expectedXML = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<feed xmlns=\"http://www.w3.org/2005/Atom\">\n\n<title>SteamPress Blog</title>\n<subtitle>SteamPress is an open-source blogging engine written for Vapor in Swift</subtitle>\n<id>/blog/</id>\n<link rel=\"alternate\" type=\"text/html\" href=\"/blog/\"/>\n<link rel=\"self\" type=\"application/atom+xml\" href=\"/blog/atom.xml\"/>\n<generator uri=\"https://www.steampress.io/\">SteamPress</generator>\n<updated>\(self.dateFormatter.string(from: Date()))</updated>\n<entry>\n<id>/blog/posts-id/1/</id>\n<title>\(post.title)</title>\n<updated>\(self.dateFormatter.string(from: post.created))</updated>\n<published>\(self.dateFormatter.string(from: post.created))</published>\n<author>\n<name>\(author.name)</name>\n<uri>/blog/authors/\(author.username)/</uri>\n</author>\n<summary>\(try post.description())</summary>\n<link rel=\"alternate\" href=\"/blog/posts/\(post.slugUrl)/\" />\n</entry>\n</feed>"
        
        let actualXmlResponse = try testWorld.getResponseString(to: blogAtomPath)
        XCTAssertEqual(actualXmlResponse, expectedXML)
    }

    func testThatFeedCorrectForTwoPosts() throws {
        testWorld = try TestWorld.create()
        let testData = try testWorld.createPost()
        
        let post = testData.post
        let author = testData.author

        let secondTitle = "Another Post"
        let secondPostDate = Date()
        let post2 = try testWorld.createPost(createdDate: secondPostDate, title: secondTitle, author: author).post

        let expectedXML = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<feed xmlns=\"http://www.w3.org/2005/Atom\">\n\n<title>SteamPress Blog</title>\n<subtitle>SteamPress is an open-source blogging engine written for Vapor in Swift</subtitle>\n<id>/</id>\n<link rel=\"alternate\" type=\"text/html\" href=\"/\"/>\n<link rel=\"self\" type=\"application/atom+xml\" href=\"/atom.xml\"/>\n<generator uri=\"https://www.steampress.io/\">SteamPress</generator>\n<updated>\(dateFormatter.string(from: Date()))</updated>\n<entry>\n<id>/posts-id/2/</id>\n<title>\(secondTitle)</title>\n<updated>\(dateFormatter.string(from: secondPostDate))</updated>\n<published>\(dateFormatter.string(from: secondPostDate))</published>\n<author>\n<name>\(author.name)</name>\n<uri>/authors/\(author.username)/</uri>\n</author>\n<summary>\(try post2.description())</summary>\n<link rel=\"alternate\" href=\"/posts/\(post2.slugUrl)/\" />\n</entry>\n<entry>\n<id>/posts-id/1/</id>\n<title>\(post.title)</title>\n<updated>\(dateFormatter.string(from: post.created))</updated>\n<published>\(dateFormatter.string(from: post.created))</published>\n<author>\n<name>\(author.name)</name>\n<uri>/authors/\(author.username)/</uri>\n</author>\n<summary>\(try post.description())</summary>\n<link rel=\"alternate\" href=\"/posts/\(post.slugUrl)/\" />\n</entry>\n</feed>"

        let actualXmlResponse = try testWorld.getResponseString(to: atomPath)
        XCTAssertEqual(actualXmlResponse, expectedXML)
    }

    func testThatDraftsDontAppearInFeed() throws {
        testWorld = try TestWorld.create()
        let testData = try testWorld.createPost()
        
        let post = testData.post
        let author = testData.author
        
        _ = try testWorld.createPost(title: "A Draft Post", published: false)

        let expectedXML = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<feed xmlns=\"http://www.w3.org/2005/Atom\">\n\n<title>SteamPress Blog</title>\n<subtitle>SteamPress is an open-source blogging engine written for Vapor in Swift</subtitle>\n<id>/</id>\n<link rel=\"alternate\" type=\"text/html\" href=\"/\"/>\n<link rel=\"self\" type=\"application/atom+xml\" href=\"/atom.xml\"/>\n<generator uri=\"https://www.steampress.io/\">SteamPress</generator>\n<updated>\(dateFormatter.string(from: Date()))</updated>\n<entry>\n<id>/posts-id/1/</id>\n<title>\(post.title)</title>\n<updated>\(dateFormatter.string(from: post.created))</updated>\n<published>\(dateFormatter.string(from: post.created))</published>\n<author>\n<name>\(author.name)</name>\n<uri>/authors/\(author.username)/</uri>\n</author>\n<summary>\(try post.description())</summary>\n<link rel=\"alternate\" href=\"/posts/\(post.slugUrl)/\" />\n</entry>\n</feed>"

        let actualXmlResponse = try testWorld.getResponseString(to: atomPath)
        XCTAssertEqual(actualXmlResponse, expectedXML)
    }

    func testThatEditedPostsHaveUpdatedTimes() throws {
        testWorld = try TestWorld.create()
        let firstPostDate = Date().addingTimeInterval(-3600)
        let testData = try testWorld.createPost(createdDate: firstPostDate)

        let post = testData.post
        let author = testData.author

        let secondTitle = "Another Post"
        let secondPostDate = Date().addingTimeInterval(-60)
        let newEditDate = Date()
        let post2 = try testWorld.createPost(createdDate: secondPostDate, title: secondTitle, author: author).post
        post2.lastEdited = newEditDate

        let expectedXML = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<feed xmlns=\"http://www.w3.org/2005/Atom\">\n\n<title>SteamPress Blog</title>\n<subtitle>SteamPress is an open-source blogging engine written for Vapor in Swift</subtitle>\n<id>/</id>\n<link rel=\"alternate\" type=\"text/html\" href=\"/\"/>\n<link rel=\"self\" type=\"application/atom+xml\" href=\"/atom.xml\"/>\n<generator uri=\"https://www.steampress.io/\">SteamPress</generator>\n<updated>\(dateFormatter.string(from: newEditDate))</updated>\n<entry>\n<id>/posts-id/2/</id>\n<title>\(secondTitle)</title>\n<updated>\(dateFormatter.string(from: newEditDate))</updated>\n<published>\(dateFormatter.string(from: secondPostDate))</published>\n<author>\n<name>\(author.name)</name>\n<uri>/authors/\(author.username)/</uri>\n</author>\n<summary>\(try post2.description())</summary>\n<link rel=\"alternate\" href=\"/posts/\(post2.slugUrl)/\" />\n</entry>\n<entry>\n<id>/posts-id/1/</id>\n<title>\(post.title)</title>\n<updated>\(dateFormatter.string(from: firstPostDate))</updated>\n<published>\(dateFormatter.string(from: firstPostDate))</published>\n<author>\n<name>\(author.name)</name>\n<uri>/authors/\(author.username)/</uri>\n</author>\n<summary>\(try post.description())</summary>\n<link rel=\"alternate\" href=\"/posts/\(post.slugUrl)/\" />\n</entry>\n</feed>"

        let actualXmlResponse = try testWorld.getResponseString(to: atomPath)
        XCTAssertEqual(actualXmlResponse, expectedXML)
    }

    func testThatTagsAppearWhenPostHasThem() throws {
        testWorld = try TestWorld.create()
        let tag1 = "Vapor 2"
        let tag2 = "Engineering"

        let testData = try testWorld.createPost(tags: [tag1, tag2])

        let post = testData.post
        let author = testData.author

        let expectedXML = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<feed xmlns=\"http://www.w3.org/2005/Atom\">\n\n<title>SteamPress Blog</title>\n<subtitle>SteamPress is an open-source blogging engine written for Vapor in Swift</subtitle>\n<id>/</id>\n<link rel=\"alternate\" type=\"text/html\" href=\"/\"/>\n<link rel=\"self\" type=\"application/atom+xml\" href=\"/atom.xml\"/>\n<generator uri=\"https://www.steampress.io/\">SteamPress</generator>\n<updated>\(dateFormatter.string(from: Date()))</updated>\n<entry>\n<id>/posts-id/1/</id>\n<title>\(post.title)</title>\n<updated>\(dateFormatter.string(from: post.created))</updated>\n<published>\(dateFormatter.string(from: post.created))</published>\n<author>\n<name>\(author.name)</name>\n<uri>/authors/\(author.username)/</uri>\n</author>\n<summary>\(try post.description())</summary>\n<link rel=\"alternate\" href=\"/posts/\(post.slugUrl)/\" />\n<category term=\"\(tag1)\"/>\n<category term=\"\(tag2)\"/>\n</entry>\n</feed>"

        let actualXmlResponse = try testWorld.getResponseString(to: atomPath)
        XCTAssertEqual(actualXmlResponse, expectedXML)
    }

    func testThatFullLinksWorksForPosts() throws {
        testWorld = try TestWorld.create(path: "blog")

        let testData = try testWorld.createPost()

        let post = testData.post
        let author = testData.author

        let expectedXML = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<feed xmlns=\"http://www.w3.org/2005/Atom\">\n\n<title>SteamPress Blog</title>\n<subtitle>SteamPress is an open-source blogging engine written for Vapor in Swift</subtitle>\n<id>https://geeks.brokenhands.io/blog/</id>\n<link rel=\"alternate\" type=\"text/html\" href=\"https://geeks.brokenhands.io/blog/\"/>\n<link rel=\"self\" type=\"application/atom+xml\" href=\"https://geeks.brokenhands.io/blog/atom.xml\"/>\n<generator uri=\"https://www.steampress.io/\">SteamPress</generator>\n<updated>\(dateFormatter.string(from: Date()))</updated>\n<entry>\n<id>https://geeks.brokenhands.io/blog/posts-id/1/</id>\n<title>\(post.title)</title>\n<updated>\(dateFormatter.string(from: post.created))</updated>\n<published>\(dateFormatter.string(from: post.created))</published>\n<author>\n<name>\(author.name)</name>\n<uri>https://geeks.brokenhands.io/blog/authors/\(author.username)/</uri>\n</author>\n<summary>\(try post.description())</summary>\n<link rel=\"alternate\" href=\"https://geeks.brokenhands.io/blog/posts/\(post.slugUrl)/\" />\n</entry>\n</feed>"

        let fullPath = "http://geeks.brokenhands.io/blog/atom.xml"
        let actualXmlResponse = try testWorld.getResponseString(to: fullPath)
        XCTAssertEqual(actualXmlResponse, expectedXML)
    }

    func testThatHTTPSLinksWorkForPostsBehindReverseProxy() throws {
        testWorld = try TestWorld.create(path: "blog")

        let testData = try testWorld.createPost()

        let post = testData.post
        let author = testData.author

        let expectedXML = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<feed xmlns=\"http://www.w3.org/2005/Atom\">\n\n<title>SteamPress Blog</title>\n<subtitle>SteamPress is an open-source blogging engine written for Vapor in Swift</subtitle>\n<id>https://geeks.brokenhands.io/blog/</id>\n<link rel=\"alternate\" type=\"text/html\" href=\"https://geeks.brokenhands.io/blog/\"/>\n<link rel=\"self\" type=\"application/atom+xml\" href=\"https://geeks.brokenhands.io/blog/atom.xml\"/>\n<generator uri=\"https://www.steampress.io/\">SteamPress</generator>\n<updated>\(dateFormatter.string(from: Date()))</updated>\n<entry>\n<id>https://geeks.brokenhands.io/blog/posts-id/1/</id>\n<title>\(post.title)</title>\n<updated>\(dateFormatter.string(from: post.created))</updated>\n<published>\(dateFormatter.string(from: post.created))</published>\n<author>\n<name>\(author.name)</name>\n<uri>https://geeks.brokenhands.io/blog/authors/\(author.username)/</uri>\n</author>\n<summary>\(try post.description())</summary>\n<link rel=\"alternate\" href=\"https://geeks.brokenhands.io/blog/posts/\(post.slugUrl)/\" />\n</entry>\n</feed>"

        
        let fullPath = "http://geeks.brokenhands.io/blog/atom.xml"
        let actualXmlResponse = try testWorld.getResponseString(to: fullPath, headers: ["X-Forwarded-Proto": "https"])
        XCTAssertEqual(actualXmlResponse, expectedXML)
    }

    func testCorrectHeaderSetForAtomFeed() throws {
        testWorld = try TestWorld.create()
        let actualXmlResponse = try testWorld.getResponse(to: atomPath)
        XCTAssertEqual(actualXmlResponse.http.headers.firstValue(name: .contentType), "application/atom+xml")
    }

    func testThatDateFormatterIsCorrect() throws {
        testWorld = try TestWorld.create()
        
        let createDate = Date(timeIntervalSince1970: 1505867108)
        let testData = try testWorld.createPost(createdDate: createDate)

        let post = testData.post
        let author = testData.author

        let expectedXML = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<feed xmlns=\"http://www.w3.org/2005/Atom\">\n\n<title>SteamPress Blog</title>\n<subtitle>SteamPress is an open-source blogging engine written for Vapor in Swift</subtitle>\n<id>/</id>\n<link rel=\"alternate\" type=\"text/html\" href=\"/\"/>\n<link rel=\"self\" type=\"application/atom+xml\" href=\"/atom.xml\"/>\n<generator uri=\"https://www.steampress.io/\">SteamPress</generator>\n<updated>2017-09-20T00:25:08Z</updated>\n<entry>\n<id>/posts-id/1/</id>\n<title>\(post.title)</title>\n<updated>2017-09-20T00:25:08Z</updated>\n<published>2017-09-20T00:25:08Z</published>\n<author>\n<name>\(author.name)</name>\n<uri>/authors/\(author.username)/</uri>\n</author>\n<summary>\(try post.description())</summary>\n<link rel=\"alternate\" href=\"/posts/\(post.slugUrl)/\" />\n</entry>\n</feed>"

        let actualXmlResponse = try testWorld.getResponseString(to: atomPath)
        XCTAssertEqual(actualXmlResponse, expectedXML)
    }
}

struct TestData {
    let post: BlogPost
    let author: BlogUser
}
