import XCTest

@testable import SteamPress

class BlogPostTests: XCTestCase {
    
    static var allTests = [
        "testThatSlugUrlCalculatedCorrectlyForTitleWithSpaces": testThatSlugUrlCalculatedCorrectlyForTitleWithSpaces,
    ]
    
    func testThatSlugUrlCalculatedCorrectlyForTitleWithSpaces() {
        
        let title = "This is a title"
        let expectedSlugUrl = "this-is-a-title"
        
        let post = BlogPost(title: "My title", contents: "<p>This is a blog post</p>", author: BlogUser(name: "A user", username: "Username", password: "password"), creationDate: Date(), slugUrl: title)
        
        XCTAssertEqual(expectedSlugUrl, post.slugUrl)
        
    }
    
}
