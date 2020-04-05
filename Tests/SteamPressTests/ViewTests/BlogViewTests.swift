@testable import SteamPress
import XCTest
import Vapor

class BlogViewTests: XCTestCase {
    
    // MARK: - Properties
    var eventLoopGroup: MultiThreadedEventLoopGroup!
    var presenter: ViewBlogPresenter!
    var author: BlogUser!
    var post: BlogPost!
    var viewRenderer: CapturingViewRenderer!
    var pageInformation: BlogGlobalPageInformation!
    var websiteURL: URL!
    var currentPageURL: URL!

    // MARK: - Overrides
    
    override func setUp() {
        eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        viewRenderer = CapturingViewRenderer(eventLoop: eventLoopGroup.next())
        presenter = ViewBlogPresenter(viewRenderer: viewRenderer, longDateFormatter: LongPostDateFormatter(), numericDateFormatter: NumericPostDateFormatter(), eventLoopGroup: eventLoopGroup)
        author = TestDataBuilder.anyUser(id: 1)
        let createdDate = Date(timeIntervalSince1970: 1584714638)
        let lastEditedDate = Date(timeIntervalSince1970: 1584981458)
        post = try! TestDataBuilder.anyPost(author: author, contents: TestDataBuilder.longContents, creationDate: createdDate, lastEditedDate: lastEditedDate)
        websiteURL = URL(string: "https://www.brokenhands.io")!
        currentPageURL = websiteURL.appendingPathComponent("blog").appendingPathComponent("posts").appendingPathComponent("test-post")
        pageInformation = BlogGlobalPageInformation(disqusName: "disqusName", siteTwitterHandle: "twitterHandleSomething", googleAnalyticsIdentifier: "GAString....", loggedInUser: author, websiteURL: websiteURL, currentPageURL: currentPageURL, currentPageEncodedURL: currentPageURL.absoluteString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
    }
    
    override func tearDownWithError() throws {
        try eventLoopGroup.syncShutdownGracefully()
    }
    
    // MARK: - Tests
    
    func testDescriptionOnBlogPostPageIsShortSnippetTextCleaned() throws {
        _ = presenter.postView(post: post, author: author, tags: [], pageInformation: pageInformation)
        
        let context = try XCTUnwrap(viewRenderer.capturedContext as? BlogPostPageContext)
        let expectedDescription = "Welcome to SteamPress!\nSteamPress started out as an idea - after all, I was porting sites and backends over to Swift and would like to have a blog as well. Being early days for Server-Side Swift, and embracing Vapor, there wasn't anything available to put a blog on my site, so I did what any self-respecting engineer would do - I made one! Besides, what better way to learn a framework than build a blog!"
        XCTAssertEqual(context.shortSnippet.trimmingCharacters(in: .whitespacesAndNewlines), expectedDescription)
    }
    
    func testBlogPostPageGetsCorrectParameters() throws {
        let tag = BlogTag(id: 1, name: "Engineering")
        _ = presenter.postView(post: post, author: author, tags: [tag], pageInformation: pageInformation)
        
        let context = try XCTUnwrap(viewRenderer.capturedContext as? BlogPostPageContext)
        
        XCTAssertEqual(context.title, post.title)
        XCTAssertEqual(context.post.blogID, post.blogID)
        XCTAssertEqual(context.post.title, post.title)
        XCTAssertEqual(context.post.contents, post.contents)
        XCTAssertEqual(context.author.name, author.name)
        XCTAssertTrue(context.blogPostPage)
        XCTAssertEqual(context.pageInformation.disqusName, pageInformation.disqusName)
        XCTAssertEqual(context.pageInformation.siteTwitterHandle, pageInformation.siteTwitterHandle)
        XCTAssertEqual(context.pageInformation.googleAnalyticsIdentifier, pageInformation.googleAnalyticsIdentifier)
        XCTAssertEqual(context.pageInformation.loggedInUser?.username, pageInformation.loggedInUser?.username)
        XCTAssertEqual(context.postImage, "https://user-images.githubusercontent.com/9938337/29742058-ed41dcc0-8a6f-11e7-9cfc-680501cdfb97.png")
        XCTAssertEqual(context.postImageAlt, "SteamPress Logo")
        XCTAssertEqual(context.pageInformation.currentPageURL.absoluteString, "https://www.brokenhands.io/blog/posts/test-post")
        XCTAssertEqual(context.pageInformation.websiteURL.absoluteString, "https://www.brokenhands.io")
        XCTAssertEqual(context.post.tags.first?.name, tag.name)
        XCTAssertEqual(context.post.authorName, author.name)
        XCTAssertEqual(context.post.authorUsername, author.username)
        
        let expectedDescription = "Welcome to SteamPress! SteamPress started out as an idea - after all, I was porting sites and backends over to Swift and would like to have a blog as well. Being early days for Server-Side Swift, and embracing Vapor, there wasn't anything available to put a blog on my site, so I did what any self-respecting engineer would do - I made one! Besides, what better way to learn a framework than build a blog!"
        XCTAssertEqual(context.post.description.trimmingCharacters(in: .whitespacesAndNewlines), expectedDescription)
        XCTAssertEqual(context.post.postImage, "https://user-images.githubusercontent.com/9938337/29742058-ed41dcc0-8a6f-11e7-9cfc-680501cdfb97.png")
        XCTAssertEqual(context.post.postImageAlt, "SteamPress Logo")
        let expectedSnippet = "Welcome to SteamPress!\nSteamPress started out as an idea - after all, I was porting sites and backends over to Swift and would like to have a blog as well. Being early days for Server-Side Swift, and embracing Vapor, there wasn\'t anything available to put a blog on my site, so I did what any self-respecting engineer would do - I made one! Besides, what better way to learn a framework than build a blog!\nI plan to put some more posts up going into how I actually wrote SteamPress, going into some Vapor basics like Authentication and other popular #help topics on [Slack](qutheory.slack.com) (I probably need to rewrite a lot of it properly first!) either on here or on https://geeks.brokenhands.io, which will be the engineering site for Broken Hands, which is what a lot of future projects I have planned will be under. \n![SteamPress Logo](https://user-images.githubusercontent.com/9938337/29742058-ed41dcc0-8a6f-11e7-9cfc-680501cdfb97.png)\n"
        XCTAssertEqual(context.post.longSnippet, expectedSnippet)
        XCTAssertEqual(context.post.createdDateLong, "Friday, Mar 20, 2020")
        XCTAssertEqual(context.post.createdDateNumeric, "2020-03-20T14:30:38.000Z")
        XCTAssertEqual(context.post.lastEditedDateLong, "Monday, Mar 23, 2020")
        XCTAssertEqual(context.post.lastEditedDateNumeric, "2020-03-23T16:37:38.000Z")
        
        XCTAssertEqual(viewRenderer.templatePath, "blog/post")
    }
    
    func testDisqusNameNotPassedToBlogPostPageIfNotPassedIn() throws {
        let pageInformationWithoutDisqus = BlogGlobalPageInformation(disqusName: nil, siteTwitterHandle: "twitter", googleAnalyticsIdentifier: "google", loggedInUser: author, websiteURL: websiteURL, currentPageURL: currentPageURL, currentPageEncodedURL: currentPageURL.absoluteString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
        _ = presenter.postView(post: post, author: author, tags: [], pageInformation: pageInformationWithoutDisqus)
        
        let context = try XCTUnwrap(viewRenderer.capturedContext as? BlogPostPageContext)
        XCTAssertNil(context.pageInformation.disqusName)
    }
    
    func testTwitterHandleNotPassedToBlogPostPageIfNotPassedIn() throws {
        let pageInformationWithoutTwitterHandle = BlogGlobalPageInformation(disqusName: "disqus", siteTwitterHandle: nil, googleAnalyticsIdentifier: "google", loggedInUser: author, websiteURL: websiteURL, currentPageURL: currentPageURL, currentPageEncodedURL: currentPageURL.absoluteString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
        _ = presenter.postView(post: post, author: author, tags: [], pageInformation: pageInformationWithoutTwitterHandle)
        
        let context = try XCTUnwrap(viewRenderer.capturedContext as? BlogPostPageContext)
        XCTAssertNil(context.pageInformation.siteTwitterHandle)
    }
    
    func testGAIdentifierNotPassedToBlogPostPageIfNotPassedIn() throws {
        let pageInformationWithoutGAIdentifier = BlogGlobalPageInformation(disqusName: "disqus", siteTwitterHandle: "twitter", googleAnalyticsIdentifier: nil, loggedInUser: author, websiteURL: websiteURL, currentPageURL: currentPageURL, currentPageEncodedURL: currentPageURL.absoluteString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
        _ = presenter.postView(post: post, author: author, tags: [], pageInformation: pageInformationWithoutGAIdentifier)
        
        let context = try XCTUnwrap(viewRenderer.capturedContext as? BlogPostPageContext)
        XCTAssertNil(context.pageInformation.googleAnalyticsIdentifier)
    }
    
    func testGettingTagViewWithURLEncodedName() throws {
        let tagName = "Some Tag"
        let urlEncodedName = try XCTUnwrap(tagName.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed))
        let tag = BlogTag(id: 1, name: tagName)
        
        _ = presenter.postView(post: post, author: author, tags: [tag], pageInformation: pageInformation)
        
        let context = try XCTUnwrap(viewRenderer.capturedContext as? BlogPostPageContext)
        XCTAssertEqual(context.post.tags.first?.urlEncodedName, urlEncodedName)
        XCTAssertEqual(context.post.tags.first?.name, tagName)
    }
    
}
