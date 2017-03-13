import XCTest

@testable import SteamPress
import Fluent
import Vapor

class BlogPostTests: XCTestCase {

    static var allTests = [
        ("testThatSlugUrlCalculatedCorrectlyForTitleWithSpaces", testThatSlugUrlCalculatedCorrectlyForTitleWithSpaces),
        ("testThatSlugUrlCalculatedCorrectlyForTitleWithPunctuation", testThatSlugUrlCalculatedCorrectlyForTitleWithPunctuation),
        ("testThatSlugUrlNotChangedWhenSetWithValidSlugUrl", testThatSlugUrlNotChangedWhenSetWithValidSlugUrl),
        ("testThatSlugUrlStripsWhitespace", testThatSlugUrlStripsWhitespace),
        ("testNumbersRemainInUrl", testNumbersRemainInUrl),
        ("testSlugUrlLowerCases", testSlugUrlLowerCases),
        ("testEverythingWithLotsOfCharacters", testEverythingWithLotsOfCharacters),
        ("testSlugUrlGivenUniqueNameIfDuplicate", testSlugUrlGivenUniqueNameIfDuplicate),
        ("testShortSnippet", testShortSnippet),
        ("testLongSnippet", testLongSnippet),
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
    
    func testSlugUrlGivenUniqueNameIfDuplicate() {
        setupDatabase(preparations: [BlogPost.self])
        
        let title = "A duplicated title"
        let expectedSlugUrl = "a-duplicated-title-2"
        do {
            var post1 = TestDataBuilder.anyPost(slugUrl: title)
            try post1.save()
            let post2 = TestDataBuilder.anyPost(slugUrl: title)
            XCTAssertEqual(expectedSlugUrl, post2.slugUrl)
        }
        catch {
            XCTFail("Test threw unexpected exception")
        }
    }
    
    func testShortSnippet() {
        let post = TestDataBuilder.anyLongPost()
        let shortSnippet = post.shortSnippet()
        XCTAssertLessThan(shortSnippet.count, 500)
    }
    
    func testLongSnippet() {
        let post = TestDataBuilder.anyLongPost()
        let shortSnippet = post.longSnippet()
        XCTAssertLessThan(shortSnippet.count, 1500)
    }
    
    func testCreatedAndEditedDateInISOFormForAllContext() throws {
        setupDatabase(preparations: [BlogPost.self, BlogTag.self, BlogUser.self, Pivot<BlogPost, BlogTag>.self])
        let created = Date(timeIntervalSince1970: 1.0)
        var author = TestDataBuilder.anyUser()
        try author.save()
        var post = TestDataBuilder.anyPost(author: author, creationDate: created)
        post.lastEdited = Date(timeIntervalSince1970: 10.0)
        try post.save()
        let node = try post.makeNode(context: BlogPostContext.all)
        XCTAssertEqual(node["created_date_iso8601"], "1970-01-01T01:00:01+0100")
        XCTAssertEqual(node["last_edited_date_iso8601"], "1970-01-01T01:00:10+0100")
    }

    // TODO test tag pivot logic
    // TODO test context make node stuff
    
    func setupDatabase(preparations: [Preparation.Type]) {
        let database = Database(MemoryDriver())
        BlogPost.database = database
        let printConsole = PrintConsole()
        let prepare = Prepare(console: printConsole, preparations: preparations, database: database)
        do {
            try prepare.run(arguments: [])
        }
        catch {
            XCTFail("failed to prepapre DB")
        }
    }

}

import Foundation

struct TestDataBuilder {
    
    static let longContents = "Welcome to SteamPress! SteamPress started out as an idea - after all, I was porting sites and backends over to Swift and would like to have a blog as well. Being early days for Server-Side Swift, and embracing Vapor, there wasn't anything available to put a blog on my site, so I did what any self-respecting engineer would do - I made one! Besides, what better way to learn a framework than build a blog!\n\nI plan to put some more posts up going into how I actually wrote SteamPress, going into some Vapor basics like Authentication and other popular #help topics on [Slack](qutheory.slack.com) (I probably need to rewrite a lot of it properly first!) either on here or on https://geeks.brokenhands.io, which will be the engineering site for Broken Hands, which is what a lot of future projects I have planned will be under. This however requires DynamoDB integration with Vapor (which the Swift SDK work has been started [here](https://github.com/brokenhandsio/AWSwift)) as that is what I use for most of my DB usage (it's cheap, I don't have to manage any DB servers etc and I can tear down/scale web servers and the DB will scale in parallel without me having to do anything). But I digress...\n\n# Usage\n\nI designed SteamPress to be as easy to integrate as possible. Full details can be found in the [repo](https://github.com/brokenhandsio/SteamPress/blob/master/README.md) but as an overview:\n\nYou need to add it as a dependency in your `Package.swift`:\n\n```swift\ndependencies: [\n...,\n.Package(url: \"https://github.com/brokenhandsio/SteamPress\", majorVersion: 0, minor: 1)\n]\n```\n\nNext import it at the top of your `main.swift` (or wherever you link it in):\n\n```swift\nimport SteamPress\n```\n\nFinally initialise it:\n\n```swift\nlet steamPress = SteamPress(drop: drop)\n```\n\nThat’s it! You can then blog away to your hearts content. Note that the first time you access the login page it will create a `admin` user for you, and print the credentials out (you need to restart the Heroku app at this point to flush the logs for some reason if you are trying to run on Heroku)\n\nYou also need to link up all the expected templates, so see the [`README`](https://github.com/brokenhandsio/SteamPress/blob/master/README.md) for that, or look at the [Example Site](https://github.com/brokenhandsio/SteamPressExample) - this code that powers this site!\n\n# Features\n\nOne of the reasons for writing this post is to show off some of the features of SteamPress! As you can see, we have blog posts (obviously!), multiple users for the blog and you can tag blog posts with different labels to help categorise posts. Currently (especially in the example site), the list of users, labels etc isn’t particularly functional but it will be expanded over time. We also have pagination for large number of posts.\n\nThere are also some hidden features that prove useful. You can write posts in markdown and then use [LeafMarkdown](https://github.com/brokenhandsio/LeafMarkdown) to easily format your posts. Combine it with some syntax highlighting (I use [http://prismjs.com](http://prismjs.com) on this site and you can easily write code and have it highlighted for you, as soon above. Great for technical blogs especially!\n\n# Roadmap\n\nCurrently I have released SteamPress under version 0 as I expect there to be some significant, most probably breaking, changes coming up to add better functionality. Among these include comments (probably just using [Disqus](https://disqus.com)) and making the site a bit easier and nicer to use with some Javascript to do things like form validation and making the labels UI a bit better. Also it would be nice to improve the experience of writing posts (some sort of preview function?), as well as things like AMP and generally tidying the code up! Also, the site desperately needs some UI love!\n\nOther things include:\n\n* Proper testing!\n* Remember Me functionality for logging in\n* Slug URL for posts - helps SEO and makes life a bit easier!\n* Image uploading\n* Blog drafts\n* Sitemap/RSS feed - again for SEO\n* Searching through the blog\n\nIf you have any ideas, find any bugs or any questions, just create an issue in Github for either the [main engine](https://github.com/brokenhandsio/SteamPress/issues) or the [example site](https://github.com/brokenhandsio/SteamPressExample/issues).\n\nHappy blogging!\n\nTim\n"
    
    static func anyUser() -> BlogUser {
        return BlogUser(name: "Tim C", username: "timc", password: "password")
    }

    static func anyPost(slugUrl: String = "some-exciting-title", author: BlogUser = TestDataBuilder.anyUser(), creationDate: Date = Date())  -> BlogPost {
        return BlogPost(title: "An Exciting Post!", contents: "<p>This is a blog post</p>", author: author, creationDate: creationDate, slugUrl: slugUrl)
    }
    
    static func anyLongPost() -> BlogPost {
        let title = "Introduction To Steampress"
        return BlogPost(title: title, contents: longContents, author: anyUser(), creationDate: Date(), slugUrl: title)
    }
}

import Console

struct PrintConsole: ConsoleProtocol {
    
    func output(_ string: String, style: ConsoleStyle, newLine: Bool) {
        Swift.print(string)
    }

    var size: (width: Int, height: Int) = (0, 0)

    func execute(program: String, arguments: [String], input: Int32?, output: Int32?, error: Int32?) throws {}

    func clear(_ clear: ConsoleClear) {}

    func input() -> String {
        return ""
    }

    
}
