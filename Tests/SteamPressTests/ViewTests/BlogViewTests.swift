@testable import SteamPress
import XCTest
import Vapor

class BlogViewTests: XCTestCase {

    // MARK: - Properties
    var basicContainer: BasicContainer!
    var presenter: ViewBlogPresenter!
    var author: BlogUser!
    var post: BlogPost!
    var viewRenderer: CapturingViewRenderer!
    var pageInformation: BlogGlobalPageInformation!
    var websiteURL: URL!
    var currentPageURL: URL!

    // MARK: - Overrides

    override func setUp() {
        presenter = ViewBlogPresenter()
        basicContainer = BasicContainer(config: Config.default(), environment: Environment.testing, services: .init(), on: EmbeddedEventLoop())
        basicContainer.services.register(ViewRenderer.self) { _ in
            return self.viewRenderer
        }
        viewRenderer = CapturingViewRenderer(worker: basicContainer)
        author = TestDataBuilder.anyUser()
        author.userID = 1
        post = try! TestDataBuilder.anyPost(author: author, contents: TestDataBuilder.longContents)
        websiteURL = URL(string: "https://www.brokenhands.io")!
        currentPageURL = websiteURL.appendingPathComponent("blog").appendingPathComponent("posts").appendingPathComponent("test-post")
        pageInformation = BlogGlobalPageInformation(disqusName: "disqusName", siteTwitterHandler: "twitterHandleSomething", googleAnalyticsIdentifier: "GAString....", loggedInUser: author, websiteURL: websiteURL, currentPageURL: currentPageURL)
    }

    // MARK: - Tests

    func testDescriptionOnBlogPostPageIsShortSnippetTextCleaned() throws {
        _ = presenter.postView(on: basicContainer, post: post, author: author, pageInformation: pageInformation)

        let context = try XCTUnwrap(viewRenderer.capturedContext as? BlogPostPageContext)
        let expectedDescription = "Welcome to SteamPress!\nSteamPress started out as an idea - after all, I was porting sites and backends over to Swift and would like to have a blog as well. Being early days for Server-Side Swift, and embracing Vapor, there wasn't anything available to put a blog on my site, so I did what any self-respecting engineer would do - I made one! Besides, what better way to learn a framework than build a blog!"
        XCTAssertEqual(context.shortSnippet.trimmingCharacters(in: .whitespacesAndNewlines), expectedDescription)
    }

    func testBlogPostPageGetsCorrectParameters() throws {
        _ = presenter.postView(on: basicContainer, post: post, author: author, pageInformation: pageInformation)

        let context = try XCTUnwrap(viewRenderer.capturedContext as? BlogPostPageContext)

        XCTAssertEqual(context.title, post.title)
        XCTAssertEqual(context.post.blogID, post.blogID)
        XCTAssertEqual(context.post.title, post.title)
        XCTAssertEqual(context.post.contents, post.contents)
        XCTAssertEqual(context.author.name, author.name)
        XCTAssertTrue(context.blogPostPage)
        XCTAssertEqual(context.pageInformation.disqusName, pageInformation.disqusName)
        XCTAssertEqual(context.pageInformation.siteTwitterHandler, pageInformation.siteTwitterHandler)
        XCTAssertEqual(context.pageInformation.googleAnalyticsIdentifier, pageInformation.googleAnalyticsIdentifier)
        XCTAssertEqual(context.pageInformation.loggedInUser?.username, pageInformation.loggedInUser?.username)
        XCTAssertEqual(context.postImage, "https://user-images.githubusercontent.com/9938337/29742058-ed41dcc0-8a6f-11e7-9cfc-680501cdfb97.png")
        XCTAssertEqual(context.postImageAlt, "SteamPress Logo")
        XCTAssertEqual(context.pageInformation.currentPageURL.absoluteString, "https://www.brokenhands.io/blog/posts/test-post")
        XCTAssertEqual(context.pageInformation.websiteURL.absoluteString, "https://www.brokenhands.io")
        XCTAssertEqual(viewRenderer.templatePath, "blog/post")
    }

    func testDisqusNameNotPassedToBlogPostPageIfNotPassedIn() throws {
        let pageInformationWithoutDisqus = BlogGlobalPageInformation(disqusName: nil, siteTwitterHandler: "twitter", googleAnalyticsIdentifier: "google", loggedInUser: author, websiteURL: websiteURL, currentPageURL: currentPageURL)
        _ = presenter.postView(on: basicContainer, post: post, author: author, pageInformation: pageInformationWithoutDisqus)

        let context = try XCTUnwrap(viewRenderer.capturedContext as? BlogPostPageContext)
        XCTAssertNil(context.pageInformation.disqusName)
    }

    func testTwitterHandleNotPassedToBlogPostPageIfNotPassedIn() throws {
        let pageInformationWithoutTwitterHandle = BlogGlobalPageInformation(disqusName: "disqus", siteTwitterHandler: nil, googleAnalyticsIdentifier: "google", loggedInUser: author, websiteURL: websiteURL, currentPageURL: currentPageURL)
        _ = presenter.postView(on: basicContainer, post: post, author: author, pageInformation: pageInformationWithoutTwitterHandle)

        let context = try XCTUnwrap(viewRenderer.capturedContext as? BlogPostPageContext)
        XCTAssertNil(context.pageInformation.siteTwitterHandler)
    }

    func testGAIdentifierNotPassedToBlogPostPageIfNotPassedIn() throws {
        let pageInformationWithoutGAIdentifier = BlogGlobalPageInformation(disqusName: "disqus", siteTwitterHandler: "twitter", googleAnalyticsIdentifier: nil, loggedInUser: author, websiteURL: websiteURL, currentPageURL: currentPageURL)
        _ = presenter.postView(on: basicContainer, post: post, author: author, pageInformation: pageInformationWithoutGAIdentifier)

        let context = try XCTUnwrap(viewRenderer.capturedContext as? BlogPostPageContext)
        XCTAssertNil(context.pageInformation.googleAnalyticsIdentifier)
    }

}
