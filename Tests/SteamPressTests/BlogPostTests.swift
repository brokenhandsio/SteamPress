import XCTest

@testable import SteamPress

class BlogPostTests: XCTestCase {
    
    static var allTests = [
        ("testThatSlugUrlCalculatedCorrectlyForTitleWithSpaces", testThatSlugUrlCalculatedCorrectlyForTitleWithSpaces),
    ]
    
    func testThatSlugUrlCalculatedCorrectlyForTitleWithSpaces() {
        let title = "This is a title"
        let expectedSlugUrl = "this-is-a-title"
        let post = TestDataBuilder.anyPost(slugUrl: title)
        XCTAssertEqual(expectedSlugUrl, post.slugUrl)
        
    }
    
    func testThatSlugUrlCalculatedCorrectlyForTitleWithPunctuation() {
        let title = "This is an awesome post!"
        let expectedSlugUrl = "this-is-an-awesome-post"
        let post = TestDataBuilder.anyPost(slugUrl: title)
        XCTAssertEqual(expectedSlugUrl, post.slugUrl)
    }
    
    func testThatSlugUrlNotChangedWhenSetWithValidSlugUrl() {
        let slugUrl = "this-is-a-title"
        let post = TestDataBuilder.anyPost(slugUrl: slugUrl)
        XCTAssertEqual(slugUrl, post.slugUrl)
    }
    
    func testThatSlugUrlStripsWhitespace() {
        let title = "    Title  "
        let expectedSlugUrl = "title"
        let post = TestDataBuilder.anyPost(slugUrl: title)
        XCTAssertEqual(expectedSlugUrl, post.slugUrl)
    }
    
    func testNumbersRemainInUrl() {
        let title = "The 2nd url"
        let expectedSlugUrl = "the-2nd-url"
        let post = TestDataBuilder.anyPost(slugUrl: title)
        XCTAssertEqual(expectedSlugUrl, post.slugUrl)
    }
    
    func testSlugUrlLowerCases() {
        let title = "AN AMAZING POST"
        let expectedSlugUrl = "an-amazing-post"
        let post = TestDataBuilder.anyPost(slugUrl: title)
        XCTAssertEqual(expectedSlugUrl, post.slugUrl)
    }
    
    func testEverythingWithLotsOfCharacters() {
        let title = " This should remove! \nalmost _all_ of the @ punctuation, but it doesn't?"
        let expectedSlugUrl = "this-should-remove-almost-all-of-the-punctuation-but-it-doesnt"
        let post = TestDataBuilder.anyPost(slugUrl: title)
        XCTAssertEqual(expectedSlugUrl, post.slugUrl)
    }
    
    // TODO test snippets
    // TODO test slug Url uniqueness logic
    // TODO test tag pivot logic
    
}

import Foundation

struct TestDataBuilder {
    static func anyUser() -> BlogUser {
        return BlogUser(name: "Tim C", username: "timc", password: "password")
    }
    
    static func anyPost(slugUrl: String = "some-exciting-title")  -> BlogPost {
        return BlogPost(title: "An Exciting Post!", contents: "<p>This is a blog post</p>", author: anyUser(), creationDate: Date(), slugUrl: slugUrl)
    }
}
