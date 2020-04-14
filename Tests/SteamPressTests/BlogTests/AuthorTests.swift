import XCTest
import Vapor
import SteamPress

class AuthorTests: XCTestCase {

    // MARK: - Properties
    private var app: Application!
    private var testWorld: TestWorld!
    private let allAuthorsRequestPath = "/authors"
    private let authorsRequestPath = "/authors/leia"
    private var user: BlogUser!
    private var postData: TestData!
    private var presenter: CapturingBlogPresenter {
        return testWorld.context.blogPresenter
    }
    private var postsPerPage = 7

    // MARK: - Overrides
    
    override func setUpWithError() throws {
        testWorld = try TestWorld.create(postsPerPage: postsPerPage, websiteURL: "/")
        user = testWorld.createUser(username: "leia")
        postData = try testWorld.createPost(author: user)
    }
    
    override func tearDownWithError() throws {
        try testWorld.shutdown()
    }

    // MARK: - Tests

    func testAllAuthorsPageGetAllAuthors() throws {
        let newAuthor = testWorld.createUser(username: "han")
        _ = try testWorld.createPost(author: newAuthor)
        _ = try testWorld.createPost(author: newAuthor)
        _ = try testWorld.getResponse(to: allAuthorsRequestPath)

        XCTAssertEqual(presenter.allAuthors?.count, 2)
        XCTAssertEqual(presenter.allAuthorsPostCount?[newAuthor.userID!], 2)
        XCTAssertEqual(presenter.allAuthorsPostCount?[user.userID!], 1)
        XCTAssertEqual(presenter.allAuthors?.last?.name, user.name)
    }

    func testAuthorPageGetsOnlyPublishedPostsInDescendingOrder() throws {
        let secondPostData = try testWorld.createPost(title: "A later post", author: user)
        _ = try testWorld.createPost(author: user, published: false)

        _ = try testWorld.getResponse(to: authorsRequestPath)

        XCTAssertEqual(presenter.authorPosts?.count, 2)
        XCTAssertEqual(presenter.authorPosts?.first?.title, secondPostData.post.title)
    }

    func testDisabledBlogAuthorsPath() throws {
        try testWorld.shutdown()
        testWorld = try TestWorld.create(enableAuthorPages: false)
        _ = testWorld.createUser(username: "leia")

        let authorResponse = try testWorld.getResponse(to: authorsRequestPath)
        let allAuthorsResponse = try testWorld.getResponse(to: allAuthorsRequestPath)

        XCTAssertEqual(authorResponse.status, .notFound)
        XCTAssertEqual(allAuthorsResponse.status, .notFound)
    }

    func testAuthorView() throws {
        _ = try testWorld.getResponse(to: authorsRequestPath)

        XCTAssertEqual(presenter.author?.username, user.username)
        XCTAssertEqual(presenter.authorPosts?.count, 1)
        XCTAssertEqual(presenter.authorPosts?.first?.title, postData.post.title)
        XCTAssertEqual(presenter.authorPosts?.first?.contents, postData.post.contents)
    }
    
    func testAuthorPageGetsCorrectPageInformation() throws {
        _ = try testWorld.getResponse(to: authorsRequestPath)
        XCTAssertNil(presenter.authorPageInformation?.disqusName)
        XCTAssertNil(presenter.authorPageInformation?.googleAnalyticsIdentifier)
        XCTAssertNil(presenter.authorPageInformation?.siteTwitterHandle)
        XCTAssertNil(presenter.authorPageInformation?.loggedInUser)
        XCTAssertEqual(presenter.authorPageInformation?.currentPageURL.absoluteString, authorsRequestPath)
        XCTAssertEqual(presenter.authorPageInformation?.websiteURL.absoluteString, "/")
    }
    
    func testAuthorPageInformationGetsLoggedInUser() throws {
        let user = testWorld.createUser()
        _ = try testWorld.getResponse(to: authorsRequestPath, loggedInUser: user)
        XCTAssertEqual(presenter.authorPageInformation?.loggedInUser?.username, user.username)
    }
    
    func testSettingEnvVarsWithPageInformation() throws {
        let googleAnalytics = "ABDJIODJWOIJIWO"
        let twitterHandle = "3483209fheihgifffe"
        let disqusName = "34829u48932fgvfbrtewerg"
        setenv("BLOG_GOOGLE_ANALYTICS_IDENTIFIER", googleAnalytics, 1)
        setenv("BLOG_SITE_TWITTER_HANDLE", twitterHandle, 1)
        setenv("BLOG_DISQUS_NAME", disqusName, 1)
        _ = try testWorld.getResponse(to: authorsRequestPath)
        XCTAssertEqual(presenter.authorPageInformation?.disqusName, disqusName)
        XCTAssertEqual(presenter.authorPageInformation?.googleAnalyticsIdentifier, googleAnalytics)
        XCTAssertEqual(presenter.authorPageInformation?.siteTwitterHandle, twitterHandle)
    }
    
    func testCorrectPageInformationForAllAuthors() throws {
        _ = try testWorld.getResponse(to: allAuthorsRequestPath)
        XCTAssertNil(presenter.allAuthorsPageInformation?.disqusName)
        XCTAssertNil(presenter.allAuthorsPageInformation?.googleAnalyticsIdentifier)
        XCTAssertNil(presenter.allAuthorsPageInformation?.siteTwitterHandle)
        XCTAssertNil(presenter.allAuthorsPageInformation?.loggedInUser)
        XCTAssertEqual(presenter.allAuthorsPageInformation?.currentPageURL.absoluteString, allAuthorsRequestPath)
        XCTAssertEqual(presenter.allAuthorsPageInformation?.websiteURL.absoluteString, "/")
    }
    
    func testPageInformationGetsLoggedInUserForAllAuthors() throws {
        let user = testWorld.createUser()
        _ = try testWorld.getResponse(to: allAuthorsRequestPath, loggedInUser: user)
        XCTAssertEqual(presenter.allAuthorsPageInformation?.loggedInUser?.username, user.username)
    }
    
    func testSettingEnvVarsWithPageInformationForAllAuthors() throws {
        let googleAnalytics = "ABDJIODJWOIJIWO"
        let twitterHandle = "3483209fheihgifffe"
        let disqusName = "34829u48932fgvfbrtewerg"
        setenv("BLOG_GOOGLE_ANALYTICS_IDENTIFIER", googleAnalytics, 1)
        setenv("BLOG_SITE_TWITTER_HANDLE", twitterHandle, 1)
        setenv("BLOG_DISQUS_NAME", disqusName, 1)
        _ = try testWorld.getResponse(to: allAuthorsRequestPath)
        XCTAssertEqual(presenter.allAuthorsPageInformation?.disqusName, disqusName)
        XCTAssertEqual(presenter.allAuthorsPageInformation?.googleAnalyticsIdentifier, googleAnalytics)
        XCTAssertEqual(presenter.allAuthorsPageInformation?.siteTwitterHandle, twitterHandle)
    }
    

    // MARK: - Pagination Tests
    func testAuthorViewOnlyGetsTheSpecifiedNumberOfPosts() throws {
        try testWorld.createPosts(count: 15, author: user)
        _ = try testWorld.getResponse(to: authorsRequestPath)
        XCTAssertEqual(presenter.authorPosts?.count, postsPerPage)
        XCTAssertEqual(presenter.authorPaginationTagInfo?.currentPage, 1)
        XCTAssertEqual(presenter.authorPaginationTagInfo?.totalPages, 3)
        XCTAssertNil(presenter.authorPaginationTagInfo?.currentQuery)
    }

    func testAuthorViewGetsCorrectPostsForPage() throws {
        try testWorld.createPosts(count: 15, author: user)
        _ = try testWorld.getResponse(to: "/authors/leia?page=3")
        XCTAssertEqual(presenter.authorPosts?.count, 2)
        XCTAssertEqual(presenter.authorPaginationTagInfo?.currentQuery, "page=3")
    }

    func testAuthorViewGetsAuthorsTotalPostsEvenIfPaginated() throws {
        let totalPosts = 15
        try testWorld.createPosts(count: totalPosts, author: user)
        _ = try testWorld.getResponse(to: authorsRequestPath)
        // One post created in setup
        XCTAssertEqual(presenter.authorPostCount, totalPosts + 1)
    }
    
    func testTagsForPostsSetCorrectly() throws {
        let post2 = try testWorld.createPost(title: "Test Search", author: user)
        let post3 = try testWorld.createPost(title: "Test Tags", author: user)
        let tag1Name = "Testing"
        let tag2Name = "Search"
        let tag1 = try testWorld.createTag(tag1Name, on: post2.post)
        _ = try testWorld.createTag(tag2Name, on: postData.post)
        try testWorld.context.repository.internalAdd(tag1, to: postData.post)
        
        _ = try testWorld.getResponse(to: "/authors/leia")
        let tagsForPosts = try XCTUnwrap(presenter.authorPageTagsForPost)
        XCTAssertNil(tagsForPosts[post3.post.blogID!])
        XCTAssertEqual(tagsForPosts[post2.post.blogID!]?.count, 1)
        XCTAssertEqual(tagsForPosts[post2.post.blogID!]?.first?.name, tag1Name)
        XCTAssertEqual(tagsForPosts[postData.post.blogID!]?.count, 2)
        XCTAssertEqual(tagsForPosts[postData.post.blogID!]?.first?.name, tag1Name)
        XCTAssertEqual(tagsForPosts[postData.post.blogID!]?.last?.name, tag2Name)
    }
    
}
