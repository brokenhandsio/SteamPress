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
        post = try! TestDataBuilder.anyPost(author: author)
        pageInformation = BlogGlobalPageInformation(disqusName: "disqusName", siteTwitterHandler: "twitterHandleSomething", googleAnalyticsIdentifier: "GAString....", loggedInUser: author)
    }
    
    // MARK: - Tests
    
    func testBlogPageGetsImageUrlIfOneInPostMarkdown() throws {
        
        
//       let (postWithImage, user) = try setupBlogPost()
//        _ = try viewFactory.blogPostView(uri: postURI, post: postWithImage, author: user, user: nil)
//
//        XCTAssertNotNil((viewRenderer.capturedContext?["post_image"])?.string)
    }

//    func testDescriptionOnBlogPostPageIsShortSnippetTextCleaned() throws {
//        let (postWithImage, user) = try setupBlogPost()
//        _ = try viewFactory.blogPostView(uri: postURI, post: postWithImage, author: user, user: nil)
//
//        let expectedDescription = "Welcome to SteamPress! SteamPress started out as an idea - after all, I was porting sites and backends over to Swift and would like to have a blog as well. Being early days for Server-Side Swift, and embracing Vapor, there wasn't anything available to put a blog on my site, so I did what any self-respecting engineer would do - I made one! Besides, what better way to learn a framework than build a blog!"
//
//        XCTAssertEqual((viewRenderer.capturedContext?["post_description"])?.string?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines), expectedDescription)
//    }

    func testBlogPostPageGetsCorrectParameters() throws {
        _ = presenter.postView(on: basicContainer, post: post, author: author, pageInformation: pageInformation)
        
        let context = try XCTUnwrap(viewRenderer.capturedContext as? BlogPostPageContext)

        XCTAssertEqual(context.title, post.title)
        XCTAssertEqual(context.post.title, post.title)
        XCTAssertEqual(context.post.title, post.title)
        XCTAssertEqual(context.author.name, author.name)
        XCTAssertTrue(context.blogPostPage)
        XCTAssertEqual(context.pageInformation.disqusName, pageInformation.disqusName)
        XCTAssertEqual(context.pageInformation.siteTwitterHandler, pageInformation.siteTwitterHandler)
        XCTAssertEqual(context.pageInformation.googleAnalyticsIdentifier, pageInformation.googleAnalyticsIdentifier)
        XCTAssertEqual(context.pageInformation.loggedInUser?.username, pageInformation.loggedInUser?.username)
//        XCTAssertNotNil((viewRenderer.capturedContext?["post_image"])?.string)
//        XCTAssertNotNil((viewRenderer.capturedContext?["post_image_alt"])?.string)
//        XCTAssertEqual(viewRenderer.capturedContext?["post_uri"]?.string, "https://test.com/posts/test-post/")
//        XCTAssertEqual(viewRenderer.capturedContext?["site_uri"]?.string, "https://test.com/")
//        XCTAssertEqual(viewRenderer.capturedContext?["post_uri_encoded"]?.string, "https://test.com/posts/test-post/")
        XCTAssertEqual(viewRenderer.templatePath, "blog/post")
    }

//    func testUserPassedToBlogPostPageIfUserPassedIn() throws {
//        let (postWithImage, user) = try setupBlogPost()
//        _ = try viewFactory.blogPostView(uri: postURI, post: postWithImage, author: user, user: user)
//        XCTAssertEqual(viewRenderer.capturedContext?["user"]?["name"]?.string, user.name)
//    }
//
//    func testDisqusNameNotPassedToBlogPostPageIfNotPassedIn() throws {
//        viewFactory = LeafViewFactory(viewRenderer: viewRenderer, disqusName: nil, siteTwitterHandle: nil, googleAnalyticsIdentifier: nil)
//        let (postWithImage, user) = try setupBlogPost()
//        _ = try viewFactory.blogPostView(uri: postURI, post: postWithImage, author: user, user: nil)
//        XCTAssertNil(viewRenderer.capturedContext?["disqus_name"]?.string)
//    }
//
//    func testTwitterHandleNotPassedToBlogPostPageIfNotPassedIn() throws {
//        viewFactory = LeafViewFactory(viewRenderer: viewRenderer, disqusName: nil, siteTwitterHandle: nil, googleAnalyticsIdentifier: nil)
//        let (postWithImage, user) = try setupBlogPost()
//        _ = try viewFactory.blogPostView(uri: postURI, post: postWithImage, author: user, user: nil)
//        XCTAssertNil(viewRenderer.capturedContext?["site_twitter_handle"]?.string)
//    }
//
//    func testGAIdentifierNotPassedToBlogPostPageIfNotPassedIn() throws {
//        viewFactory = LeafViewFactory(viewRenderer: viewRenderer, disqusName: nil, siteTwitterHandle: nil, googleAnalyticsIdentifier: nil)
//        let (postWithImage, user) = try setupBlogPost()
//        _ = try viewFactory.blogPostView(uri: postURI, post: postWithImage, author: user, user: nil)
//        XCTAssertNil(viewRenderer.capturedContext?["google_analytics_identifier"]?.string)
//    }
    
}
