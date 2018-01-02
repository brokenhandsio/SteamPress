//import XCTest
//
//@testable import SteamPress
//import Fluent
//import Vapor
//import Foundation
//
//class BlogPostTests: XCTestCase {
//
//    static var allTests = [
//        ("testLinuxTestSuiteIncludesAllTests", testLinuxTestSuiteIncludesAllTests),
//        ("testThatSlugUrlCalculatedCorrectlyForTitleWithSpaces", testThatSlugUrlCalculatedCorrectlyForTitleWithSpaces),
//        ("testThatSlugUrlCalculatedCorrectlyForTitleWithPunctuation", testThatSlugUrlCalculatedCorrectlyForTitleWithPunctuation),
//        ("testThatSlugUrlNotChangedWhenSetWithValidSlugUrl", testThatSlugUrlNotChangedWhenSetWithValidSlugUrl),
//        ("testThatSlugUrlStripsWhitespace", testThatSlugUrlStripsWhitespace),
//        ("testNumbersRemainInUrl", testNumbersRemainInUrl),
//        ("testSlugUrlLowerCases", testSlugUrlLowerCases),
//        ("testEverythingWithLotsOfCharacters", testEverythingWithLotsOfCharacters),
//        ("testSlugUrlGivenUniqueNameIfDuplicate", testSlugUrlGivenUniqueNameIfDuplicate),
//        ("testShortSnippet", testShortSnippet),
//        ("testLongSnippet", testLongSnippet),
//        ("testCreatedAndEditedDateInISOFormForAllContext", testCreatedAndEditedDateInISOFormForAllContext)
//    ]
//
//    private var database: Database!
//
//    override func setUp() {
//        database = try! Database(MemoryDriver())
//        try! Droplet.prepare(database: database)
//    }
//
//    override func tearDown() {
//        try! Droplet.teardown(database: database)
//    }
//
//    func testLinuxTestSuiteIncludesAllTests() {
//        #if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
//            let thisClass = type(of: self)
//            let linuxCount = thisClass.allTests.count
//            let darwinCount = Int(thisClass
//                .defaultTestSuite.testCaseCount)
//            XCTAssertEqual(linuxCount, darwinCount,
//                           "\(darwinCount - linuxCount) tests are missing from allTests")
//        #endif
//    }
//
//    func testThatSlugUrlCalculatedCorrectlyForTitleWithSpaces() {
//        let title = "This is a title"
//        let expectedSlugUrl = "this-is-a-title"
//        let post = TestDataBuilder.anyPost(author: TestDataBuilder.anyUser(), slugUrl: title)
//        XCTAssertEqual(expectedSlugUrl, post.slugUrl)
//    }
//
//    func testThatSlugUrlCalculatedCorrectlyForTitleWithPunctuation() {
//        let title = "This is an awesome post!"
//        let expectedSlugUrl = "this-is-an-awesome-post"
//        let post = TestDataBuilder.anyPost(author: TestDataBuilder.anyUser(), slugUrl: title)
//        XCTAssertEqual(expectedSlugUrl, post.slugUrl)
//    }
//
//    func testThatSlugUrlNotChangedWhenSetWithValidSlugUrl() {
//        let slugUrl = "this-is-a-title"
//        let post = TestDataBuilder.anyPost(author: TestDataBuilder.anyUser(), slugUrl: slugUrl)
//        XCTAssertEqual(slugUrl, post.slugUrl)
//    }
//
//    func testThatSlugUrlStripsWhitespace() {
//        let title = "    Title  "
//        let expectedSlugUrl = "title"
//        let post = TestDataBuilder.anyPost(author: TestDataBuilder.anyUser(), slugUrl: title)
//        XCTAssertEqual(expectedSlugUrl, post.slugUrl)
//    }
//
//    func testNumbersRemainInUrl() {
//        let title = "The 2nd url"
//        let expectedSlugUrl = "the-2nd-url"
//        let post = TestDataBuilder.anyPost(author: TestDataBuilder.anyUser(), slugUrl: title)
//        XCTAssertEqual(expectedSlugUrl, post.slugUrl)
//    }
//
//    func testSlugUrlLowerCases() {
//        let title = "AN AMAZING POST"
//        let expectedSlugUrl = "an-amazing-post"
//        let post = TestDataBuilder.anyPost(author: TestDataBuilder.anyUser(), slugUrl: title)
//        XCTAssertEqual(expectedSlugUrl, post.slugUrl)
//    }
//
//    func testEverythingWithLotsOfCharacters() {
//        let title = " This should remove! \nalmost _all_ of the @ punctuation, but it doesn't?"
//        let expectedSlugUrl = "this-should-remove-almost-all-of-the-punctuation-but-it-doesnt"
//        let post = TestDataBuilder.anyPost(author: TestDataBuilder.anyUser(), slugUrl: title)
//        XCTAssertEqual(expectedSlugUrl, post.slugUrl)
//    }
//
//    func testSlugUrlGivenUniqueNameIfDuplicate() throws {
//        let title = "A duplicated title"
//        let expectedSlugUrl = "a-duplicated-title-2"
//        let author = TestDataBuilder.anyUser()
//        try author.save()
//        let post1 = TestDataBuilder.anyPost(author: author, slugUrl: title)
//        try post1.save()
//        let post2 = TestDataBuilder.anyPost(author: author, slugUrl: title)
//        XCTAssertEqual(expectedSlugUrl, post2.slugUrl)
//
//    }
//
//    func testShortSnippet() {
//        let post = TestDataBuilder.anyLongPost(author: TestDataBuilder.anyUser())
//        let shortSnippet = post.shortSnippet()
//        XCTAssertLessThan(shortSnippet.count, 500)
//    }
//
//    func testLongSnippet() {
//        let post = TestDataBuilder.anyLongPost(author: TestDataBuilder.anyUser())
//        let shortSnippet = post.longSnippet()
//        XCTAssertLessThan(shortSnippet.count, 1500)
//    }
//
//
//    func testCreatedAndEditedDateInISOFormForAllContext() throws {
//        let created = Date(timeIntervalSince1970: 1.0)
//        let lastEdited = Date(timeIntervalSince1970: 10.0)
//        let author = TestDataBuilder.anyUser()
//        try author.save()
//        let post = TestDataBuilder.anyPost(author: author, creationDate: created)
//        post.lastEdited = lastEdited
//        try post.save()
//        let node = try post.makeNode(in: BlogPostContext.all)
//
//        XCTAssertEqual(node["created_date_iso8601"]?.string, "1970-01-01T00:00:01+0000")
//        XCTAssertEqual(node["last_edited_date_iso8601"]?.string, "1970-01-01T00:00:10+0000")
//    }
//
//    // TODO test tag pivot logic
//    // TODO test context make node stuff
//
//}

