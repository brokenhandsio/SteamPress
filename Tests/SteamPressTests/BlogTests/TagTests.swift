import XCTest
import Vapor
import SteamPress

class TagTests: XCTestCase {

    // MARK: - Properties
    var app: Application!
    var testWorld: TestWorld!
    let allTagsRequestPath = "/tags"
    let tagRequestPath = "/tags/Tatooine"
    let tagName = "Tatooine"
    var postData: TestData!
    var tag: BlogTag!
    var presenter: CapturingBlogPresenter {
        return testWorld.context.blogPresenter
    }
    let postsPerPage = 7

    // MARK: - Overrides

    override func setUp() {
        testWorld = try! TestWorld.create(postsPerPage: postsPerPage)
        postData = try! testWorld.createPost()
        tag = try! testWorld.createTag(tagName, on: postData.post)
    }

    // MARK: - Tests

    func testAllTagsPageGetsAllTags() throws {
        let secondPost = try! testWorld.createPost()
        let thirdPost = try! testWorld.createPost()
        let secondTag = try testWorld.createTag("AnotherTag", on: secondPost.post)
        try testWorld.context.repository.add(secondTag, to: thirdPost.post)
        _ = try testWorld.getResponse(to: allTagsRequestPath)

        XCTAssertEqual(presenter.allTagsPageTags?.count, 2)
        XCTAssertEqual(presenter.allTagsPageTags?.first?.name, tag.name)
        XCTAssertEqual(presenter.allTagsPagePostCount?[tag.tagID!], 1)
        XCTAssertEqual(presenter.allTagsPagePostCount?[secondTag.tagID!], 2)
    }

    func testTagPageGetsOnlyPublishedPostsInDescendingOrder() throws {
        let secondPostData = try testWorld.createPost(title: "A later post", author: postData.author)
        let draftPost = try testWorld.createPost(published: false)
        testWorld.context.repository.addTag(tag, to: secondPostData.post)
        testWorld.context.repository.addTag(tag, to: draftPost.post)

        _ = try testWorld.getResponse(to: tagRequestPath)

        XCTAssertEqual(presenter.tagPosts?.count, 2)
        XCTAssertEqual(presenter.tagPosts?.first?.title, secondPostData.post.title)
    }

    func testDisabledBlogTagsPath() throws {
        print("Setting up test world")
        testWorld = try TestWorld.create(enableTagPages: false)
        print("Will now create tag")
        _ = try testWorld.createTag(tagName)
        let tagResponse = try testWorld.getResponse(to: tagRequestPath)
        let allTagsResponse = try testWorld.getResponse(to: allTagsRequestPath)

        XCTAssertEqual(.notFound, tagResponse.http.status)
        XCTAssertEqual(.notFound, allTagsResponse.http.status)
    }

    func testTagView() throws {
        _ = try testWorld.getResponse(to: tagRequestPath)

        XCTAssertEqual(presenter.tagPosts?.count, 1)
        XCTAssertEqual(presenter.tagPosts?.first?.title, postData.post.title)
        XCTAssertEqual(presenter.tag?.name, tag.name)
    }

    func testTagNameContainsUrlEncodedName() throws {
        let tag = try BlogTag(name: "Luke's Tatooine")
        XCTAssertEqual(tag.name, "Luke's%20Tatooine")
    }

    func testGettingTagViewWithURLEncodedName() throws {
        let tagName = "Some Tag"
        _ = try testWorld.createTag(tagName)

        let urlEncodedName = try XCTUnwrap(tagName.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed))
        let response = try testWorld.getResponse(to: "/tags/\(urlEncodedName)")

        XCTAssertEqual(response.http.status, .ok)
        XCTAssertEqual(presenter.tag?.name.removingPercentEncoding, tagName)
    }
    
    func testTagPageGetsCorrectPageInformation() throws {
        _ = try testWorld.getResponse(to: tagRequestPath)
        XCTAssertNil(presenter.tagPageInformation?.disqusName)
        XCTAssertNil(presenter.tagPageInformation?.googleAnalyticsIdentifier)
        XCTAssertNil(presenter.tagPageInformation?.siteTwitterHandler)
        XCTAssertNil(presenter.tagPageInformation?.loggedInUser)
        XCTAssertEqual(presenter.tagPageInformation?.currentPageURL.absoluteString, tagRequestPath)
        XCTAssertEqual(presenter.tagPageInformation?.websiteURL.absoluteString, "")
    }
    
    func testTagPageInformationGetsLoggedInUser() throws {
        let user = testWorld.createUser()
        _ = try testWorld.getResponse(to: tagRequestPath, loggedInUser: user)
        XCTAssertEqual(presenter.tagPageInformation?.loggedInUser?.username, user.username)
    }
    
    func testSettingEnvVarsWithPageInformation() throws {
        let googleAnalytics = "ABDJIODJWOIJIWO"
        let twitterHandle = "3483209fheihgifffe"
        let disqusName = "34829u48932fgvfbrtewerg"
        setenv("BLOG_GOOGLE_ANALYTICS_IDENTIFIER", googleAnalytics, 1)
        setenv("BLOG_SITE_TWITTER_HANDLER", twitterHandle, 1)
        setenv("BLOG_DISQUS_NAME", disqusName, 1)
        _ = try testWorld.getResponse(to: tagRequestPath)
        XCTAssertEqual(presenter.tagPageInformation?.disqusName, disqusName)
        XCTAssertEqual(presenter.tagPageInformation?.googleAnalyticsIdentifier, googleAnalytics)
        XCTAssertEqual(presenter.tagPageInformation?.siteTwitterHandler, twitterHandle)
    }
    
    func testCorrectPageInformationForAllTags() throws {
        _ = try testWorld.getResponse(to: allTagsRequestPath)
        XCTAssertNil(presenter.allTagsPageInformation?.disqusName)
        XCTAssertNil(presenter.allTagsPageInformation?.googleAnalyticsIdentifier)
        XCTAssertNil(presenter.allTagsPageInformation?.siteTwitterHandler)
        XCTAssertNil(presenter.allTagsPageInformation?.loggedInUser)
        XCTAssertEqual(presenter.allTagsPageInformation?.currentPageURL.absoluteString, allTagsRequestPath)
        XCTAssertEqual(presenter.allTagsPageInformation?.websiteURL.absoluteString, "")
    }
    
    func testPageInformationGetsLoggedInUserForAllTags() throws {
        let user = testWorld.createUser()
        _ = try testWorld.getResponse(to: allTagsRequestPath, loggedInUser: user)
        XCTAssertEqual(presenter.allTagsPageInformation?.loggedInUser?.username, user.username)
    }
    
    func testSettingEnvVarsWithPageInformationForAllTags() throws {
        let googleAnalytics = "ABDJIODJWOIJIWO"
        let twitterHandle = "3483209fheihgifffe"
        let disqusName = "34829u48932fgvfbrtewerg"
        setenv("BLOG_GOOGLE_ANALYTICS_IDENTIFIER", googleAnalytics, 1)
        setenv("BLOG_SITE_TWITTER_HANDLER", twitterHandle, 1)
        setenv("BLOG_DISQUS_NAME", disqusName, 1)
        _ = try testWorld.getResponse(to: allTagsRequestPath)
        XCTAssertEqual(presenter.allTagsPageInformation?.disqusName, disqusName)
        XCTAssertEqual(presenter.allTagsPageInformation?.googleAnalyticsIdentifier, googleAnalytics)
        XCTAssertEqual(presenter.allTagsPageInformation?.siteTwitterHandler, twitterHandle)
    }

    // MARK: - Pagination Tests
    func testTagViewOnlyGetsTheSpecifiedNumberOfPosts() throws {
        try testWorld.createPosts(count: 15, author: postData.author, tag: tag)
        _ = try testWorld.getResponse(to: tagRequestPath)
        XCTAssertEqual(presenter.tagPosts?.count, postsPerPage)
    }

    func testTagViewGetsCorrectPostsForPage() throws {
        try testWorld.createPosts(count: 15, author: postData.author, tag: tag)
        _ = try testWorld.getResponse(to: "\(tagRequestPath)?page=3")
        XCTAssertEqual(presenter.tagPosts?.count, 2)
    }
}
