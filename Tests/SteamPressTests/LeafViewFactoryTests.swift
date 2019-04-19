//import XCTest
//import Vapor
////import URI
//import Fluent
//import HTTP
//import Foundation
//@testable import SteamPress
//
//class LeafViewFactoryTests: XCTestCase {
//
//    // MARK: - allTests
//
//    static var allTests = [
//        ("testLinuxTestSuiteIncludesAllTests", testLinuxTestSuiteIncludesAllTests),
//        ("testParametersAreSetCorrectlyOnAllTagsPage", testParametersAreSetCorrectlyOnAllTagsPage),
//        ("testTagsPageGetsPassedAllTagsWithBlogCount", testTagsPageGetsPassedAllTagsWithBlogCount),
//        ("testTagsPageGetsPassedTagsSortedByPageCount", testTagsPageGetsPassedTagsSortedByPageCount),
//        ("testTwitterHandleNotSetOnAllTagsPageIfNotGiven", testTwitterHandleNotSetOnAllTagsPageIfNotGiven),
//        ("testDisqusNameNotSetOnAllTagsPageIfNotGiven", testDisqusNameNotSetOnAllTagsPageIfNotGiven),
//        ("testGAIdentifierNotSetOnAllTagsPageIfNotGiven", testGAIdentifierNotSetOnAllTagsPageIfNotGiven),
//        ("testLoggedInUserSetOnAllTagsPageIfPassedIn", testLoggedInUserSetOnAllTagsPageIfPassedIn),
//        ("testNoTagsGivenIfEmptyArrayPassedToAllTagsPage", testNoTagsGivenIfEmptyArrayPassedToAllTagsPage),
//        ("testParametersAreSetCorrectlyOnAllAuthorsPage", testParametersAreSetCorrectlyOnAllAuthorsPage),
//        ("testAuthorsPageGetsPassedAllAuthorsWithBlogCount", testAuthorsPageGetsPassedAllAuthorsWithBlogCount),
//        ("testAuthorsPageGetsPassedAuthorsSortedByPageCount", testAuthorsPageGetsPassedAuthorsSortedByPageCount),
//        ("testTwitterHandleNotSetOnAllAuthorsPageIfNotProvided", testTwitterHandleNotSetOnAllAuthorsPageIfNotProvided),
//        ("testDisqusNameNotSetOnAllAuthorsPageIfNotProvided", testDisqusNameNotSetOnAllAuthorsPageIfNotProvided),
//        ("testGAIdentifierNotSetOnAllAuthorsPageIfNotProvided", testGAIdentifierNotSetOnAllAuthorsPageIfNotProvided),
//        ("testNoLoggedInUserPassedToAllAuthorsPageIfNoneProvided", testNoLoggedInUserPassedToAllAuthorsPageIfNoneProvided),
//        ("testNoAuthorsGivenToAuthorsPageIfNonePassedToAllAuthorsPage", testNoAuthorsGivenToAuthorsPageIfNonePassedToAllAuthorsPage),
//        ("testTagPageGetsTagWithCorrectParamsAndPostCount", testTagPageGetsTagWithCorrectParamsAndPostCount),
//        ("testNoLoggedInUserPassedToTagPageIfNoneProvided", testNoLoggedInUserPassedToTagPageIfNoneProvided),
//        ("testDisqusNameNotPassedToTagPageIfNotSet", testDisqusNameNotPassedToTagPageIfNotSet),
//        ("testTwitterHandleNotPassedToTagPageIfNotSet", testTwitterHandleNotPassedToTagPageIfNotSet),
//        ("testGAIdentifierNotPassedToTagPageIfNotSet", testGAIdentifierNotPassedToTagPageIfNotSet),
//        ("testBlogPageGetsImageUrlIfOneInPostMarkdown", testBlogPageGetsImageUrlIfOneInPostMarkdown),
//        ("testDescriptionOnBlogPostPageIsShortSnippetTextCleaned", testDescriptionOnBlogPostPageIsShortSnippetTextCleaned),
//        ("testBlogPostPageGetsCorrectParameters", testBlogPostPageGetsCorrectParameters),
//        ("testUserPassedToBlogPostPageIfUserPassedIn", testUserPassedToBlogPostPageIfUserPassedIn),
//        ("testDisqusNameNotPassedToBlogPostPageIfNotPassedIn", testDisqusNameNotPassedToBlogPostPageIfNotPassedIn),
//        ("testTwitterHandleNotPassedToBlogPostPageIfNotPassedIn", testTwitterHandleNotPassedToBlogPostPageIfNotPassedIn),
//        ("testGAIdentifierNotPassedToBlogPostPageIfNotPassedIn", testGAIdentifierNotPassedToBlogPostPageIfNotPassedIn),
//        ("testBlogIndexPageGivenCorrectParameters", testBlogIndexPageGivenCorrectParameters),
//        ("testNoPostsPassedIntoBlogIndexIfNoneAvailable", testNoPostsPassedIntoBlogIndexIfNoneAvailable),
//        ("testNoAuthorsPassedIntoBlogIndexIfNoneCreated", testNoAuthorsPassedIntoBlogIndexIfNoneCreated),
//        ("testNoTagsPassedIntoBlogIndexIfNoneCreted", testNoTagsPassedIntoBlogIndexIfNoneCreted),
//        ("testUserPassedToBlogIndexIfUserPassedIn", testUserPassedToBlogIndexIfUserPassedIn),
//        ("testDisqusNameNotPassedToBlogIndexIfNotPassedIn", testDisqusNameNotPassedToBlogIndexIfNotPassedIn),
//        ("testTwitterHandleNotPassedToBlogIndexIfNotPassedIn", testTwitterHandleNotPassedToBlogIndexIfNotPassedIn),
//        ("testGAIdentifierNotPassedToBlogIndexIfNotPassedIn", testGAIdentifierNotPassedToBlogIndexIfNotPassedIn),
//        ("testAuthorViewHasCorrectParametersSet", testAuthorViewHasCorrectParametersSet),
//        ("testAuthorViewHasNoPostsSetIfNoneCreated", testAuthorViewHasNoPostsSetIfNoneCreated),
//        ("testAuthorViewGetsLoggedInUserIfProvider", testAuthorViewGetsLoggedInUserIfProvider),
//        ("testAuthorViewDoesNotGetDisqusNameIfNotProvided", testAuthorViewDoesNotGetDisqusNameIfNotProvided),
//        ("testAuthorViewDoesNotGetTwitterHandleIfNotProvided", testAuthorViewDoesNotGetTwitterHandleIfNotProvided),
//        ("testAuthorViewDoesNotGetGAIdentifierIfNotProvided", testAuthorViewDoesNotGetGAIdentifierIfNotProvided),
//        ("testPasswordViewGivenCorrectParameters", testPasswordViewGivenCorrectParameters),
//        ("testPasswordViewHasCorrectParametersWhenError", testPasswordViewHasCorrectParametersWhenError),
//        ("testLoginViewGetsCorrectParameters", testLoginViewGetsCorrectParameters),
//        ("testLoginViewWhenErrored", testLoginViewWhenErrored),
//        ("testLoginPageUsernamePasswordErrorsMarkedWhenNotSuppliedAndErrored", testLoginPageUsernamePasswordErrorsMarkedWhenNotSuppliedAndErrored),
//        ("testBlogAdminViewGetsCorrectParameters", testBlogAdminViewGetsCorrectParameters),
//        ("testNoPostsPassedToAdminViewIfNone", testNoPostsPassedToAdminViewIfNone),
//        ("testAdminPageWithErrors", testAdminPageWithErrors),
//        ("testCreateUserViewGetsCorrectParameters", testCreateUserViewGetsCorrectParameters),
//        ("testCreateUserViewWhenErrors", testCreateUserViewWhenErrors),
//        ("testCreateUserViewWhenNoNameOrUsernameSupplied", testCreateUserViewWhenNoNameOrUsernameSupplied),
//        ("testCreateUserViewForEditing", testCreateUserViewForEditing),
//        ("testCreateUserViewThrowsWhenTryingToEditWithoutUserId", testCreateUserViewThrowsWhenTryingToEditWithoutUserId),
//        ("testCreateBlogPostViewGetsCorrectParameters", testCreateBlogPostViewGetsCorrectParameters),
//        ("testCreateBlogPostViewWhenEditing", testCreateBlogPostViewWhenEditing),
//        ("testEditBlogPostViewThrowsWithNoPostToEdit", testEditBlogPostViewThrowsWithNoPostToEdit),
//        ("testCreateBlogPostViewWithErrorsAndNoTitleOrContentsSupplied", testCreateBlogPostViewWithErrorsAndNoTitleOrContentsSupplied),
//        ("testDraftPassedThroughWhenEditingABlogPostThatHasNotBeenPublished", testDraftPassedThroughWhenEditingABlogPostThatHasNotBeenPublished),
//        ("testAuthorViewGetsPostCount", testAuthorViewGetsPostCount),
//        ("testAuthorViewGetsLongSnippetForPosts", testAuthorViewGetsLongSnippetForPosts),
//        ("testSiteURIForHTTPDoesNotContainPort", testSiteURIForHTTPDoesNotContainPort),
//        ("testSearchPageGetsCorrectParameters", testSearchPageGetsCorrectParameters),
//        ("testSearchPageGetsFlagIfNoSearchTermProvided", testSearchPageGetsFlagIfNoSearchTermProvided),
//        ("testSearchPageGetsCountIfNoPagesFound", testSearchPageGetsCountIfNoPagesFound),
//        ]
//
//    // MARK: - Properties
//    private var viewFactory: LeafViewFactory!
//    private var viewRenderer: CapturingViewRenderer!
//    private var database: Database!
//
//    private let tagsURI = URI(scheme: "https", hostname: "test.com", path: "tags/")
//    private let authorsURI = URI(scheme: "https", hostname: "test.com", path: "authors/")
//    private var authorRequest: Request!
//    private let tagURI = URI(scheme: "https", hostname: "test.com", path: "tags/tatooine/")
//    private var tagRequest: Request!
//    private let postURI = URI(scheme: "https", hostname: "test.com", path: "posts/test-post/")
//    private let indexURI = URI(scheme: "https", hostname: "test.com", path: "/")
//    private var indexRequest: Request!
//    private let authorURI = URI(scheme: "https", hostname: "test.com", path: "authors/luke/")
//    private let createPostURI = URI(scheme: "https", hostname: "test.com", path: "admin/createPost/")
//    private let editPostURI = URI(scheme: "https", hostname: "test.com", path: "admin/posts/1/edit/")
//    private let searchURI = URI(scheme: "https", hostname: "test.com", path: "search", query: "term=Test")
//
//    private let siteTwitterHandle = "brokenhandsio"
//    private let disqusName = "steampress"
//    private let googleAnalyticsIdentifier = "UA-12345678-1"
//
//    // MARK: - Overrides
//
//    override func setUp() {
//        viewRenderer = CapturingViewRenderer()
//        viewFactory = LeafViewFactory(viewRenderer: viewRenderer, disqusName: disqusName, siteTwitterHandle: siteTwitterHandle, googleAnalyticsIdentifier: googleAnalyticsIdentifier)
//        tagRequest = Request(method: .get, uri: tagURI)
//        authorRequest = Request(method: .get, uri: authorURI)
//        indexRequest = Request(method: .get, uri: indexURI)
//        database = try! Database(MemoryDriver())
//        try! Droplet.prepare(database: database)
//    }
//
//    override func tearDown() {
//        try! Droplet.teardown(database: database)
//    }
//
//    // MARK: - Tests
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
//    // MARK: - All Tags Page
//
//    func testParametersAreSetCorrectlyOnAllTagsPage() throws {
//        let tags = [BlogTag(name: "tag1"), BlogTag(name: "tag2")]
//        for tag in tags {
//            try tag.save()
//        }
//        _ = try viewFactory.allTagsView(uri: tagsURI, allTags: tags, user: nil)
//
//        XCTAssertEqual(viewRenderer.capturedContext?["tags"]?.array?.count, 2)
//        XCTAssertEqual((viewRenderer.capturedContext?["tags"]?.array?.first)?["name"], "tag1")
//        XCTAssertEqual((viewRenderer.capturedContext?["tags"]?.array?[1])?["name"], "tag2")
//        XCTAssertEqual(viewRenderer.capturedContext?["uri"]?.string, "https://test.com/tags/")
//        XCTAssertEqual(viewRenderer.capturedContext?["site_twitter_handle"]?.string, siteTwitterHandle)
//        XCTAssertEqual(viewRenderer.capturedContext?["disqus_name"]?.string, disqusName)
//        XCTAssertEqual(viewRenderer.capturedContext?["google_analytics_identifier"]?.string, googleAnalyticsIdentifier)
//        XCTAssertNil(viewRenderer.capturedContext?["user"])
//        XCTAssertEqual(viewRenderer.leafPath, "blog/tags")
//    }
//
//    func testTagsPageGetsPassedAllTagsWithBlogCount() throws {
//        let user = TestDataBuilder.anyUser()
//        try user.save()
//        let tag = BlogTag(name: "test tag")
//        try tag.save()
//        let post1 = TestDataBuilder.anyPost(author: user)
//        try post1.save()
//        try BlogTag.addTag(tag.name, to: post1)
//
//        _ = try viewFactory.allTagsView(uri: tagsURI, allTags: [tag], user: nil)
//        XCTAssertEqual((viewRenderer.capturedContext?["tags"]?.array?.first)?["post_count"], 1)
//    }
//
//    func testTagsPageGetsPassedTagsSortedByPageCount() throws {
//        let user = TestDataBuilder.anyUser()
//        try user.save()
//        let tag = BlogTag(name: "test tag")
//        let tag2 = BlogTag(name: "tatooine")
//        try tag.save()
//        try tag2.save()
//        let post1 = TestDataBuilder.anyPost(author: user)
//        try post1.save()
//        try BlogTag.addTag(tag.name, to: post1)
//        let post2 = TestDataBuilder.anyPost(author: user)
//        try post2.save()
//        try BlogTag.addTag(tag2.name, to: post2)
//        let post3 = TestDataBuilder.anyLongPost(author: user)
//        try post3.save()
//        try BlogTag.addTag(tag2.name, to: post3)
//
//        _ = try viewFactory.allTagsView(uri: tagsURI, allTags: [tag, tag2], user: nil)
//        XCTAssertEqual(viewRenderer.capturedContext?["tags"]?.array?.count, 2)
//        XCTAssertEqual((viewRenderer.capturedContext?["tags"]?.array?.first)?["name"], "tatooine")
//    }
//
//    func testTwitterHandleNotSetOnAllTagsPageIfNotGiven() throws {
//        viewFactory = LeafViewFactory(viewRenderer: viewRenderer, disqusName: nil, siteTwitterHandle: nil, googleAnalyticsIdentifier: nil)
//        _ = try viewFactory.allTagsView(uri: tagsURI, allTags: [], user: nil)
//        XCTAssertNil(viewRenderer.capturedContext?["site_twitter_handle"]?.string)
//    }
//
//    func testDisqusNameNotSetOnAllTagsPageIfNotGiven() throws {
//        viewFactory = LeafViewFactory(viewRenderer: viewRenderer, disqusName: nil, siteTwitterHandle: nil, googleAnalyticsIdentifier: nil)
//        _ = try viewFactory.allTagsView(uri: tagsURI, allTags: [], user: nil)
//        XCTAssertNil(viewRenderer.capturedContext?["disqus_name"]?.string)
//    }
//
//    func testGAIdentifierNotSetOnAllTagsPageIfNotGiven() throws {
//        viewFactory = LeafViewFactory(viewRenderer: viewRenderer, disqusName: nil, siteTwitterHandle: nil, googleAnalyticsIdentifier: nil)
//        _ = try viewFactory.allTagsView(uri: tagsURI, allTags: [], user: nil)
//        XCTAssertNil(viewRenderer.capturedContext?["google_analytics_identifier"]?.string)
//    }
//
//    func testLoggedInUserSetOnAllTagsPageIfPassedIn() throws {
//        let user = TestDataBuilder.anyUser()
//        _ = try viewFactory.allTagsView(uri: tagsURI, allTags: [], user: user)
//        XCTAssertEqual(viewRenderer.capturedContext?["user"]?["name"]?.string, "Luke")
//    }
//
//    func testNoTagsGivenIfEmptyArrayPassedToAllTagsPage() throws {
//        _ = try viewFactory.allTagsView(uri: tagsURI, allTags: [], user: nil)
//        XCTAssertNil(viewRenderer.capturedContext?["tags"])
//    }
//
//    // MARK: - All authors
//
//    func testParametersAreSetCorrectlyOnAllAuthorsPage() throws {
//        let user1 = TestDataBuilder.anyUser()
//        try user1.save()
//        let user2 = TestDataBuilder.anyUser(name: "Han", username: "han")
//        try user2.save()
//        let authors = [user1, user2]
//        _ = try viewFactory.allAuthorsView(uri: authorsURI, allAuthors: authors, user: user1)
//
//        XCTAssertEqual(viewRenderer.capturedContext?["authors"]?.array?.count, 2)
//        XCTAssertEqual((viewRenderer.capturedContext?["authors"]?.array?.first)?["name"], "Luke")
//        XCTAssertEqual((viewRenderer.capturedContext?["authors"]?.array?[1])?["name"], "Han")
//        XCTAssertEqual(viewRenderer.capturedContext?["uri"]?.string, "https://test.com/authors/")
//        XCTAssertEqual(viewRenderer.capturedContext?["site_twitter_handle"]?.string, siteTwitterHandle)
//        XCTAssertEqual(viewRenderer.capturedContext?["disqus_name"]?.string, disqusName)
//        XCTAssertEqual(viewRenderer.capturedContext?["google_analytics_identifier"]?.string, googleAnalyticsIdentifier)
//        XCTAssertEqual(viewRenderer.capturedContext?["user"]?["name"]?.string, "Luke")
//        XCTAssertEqual(viewRenderer.leafPath, "blog/authors")
//    }
//
//    func testAuthorsPageGetsPassedAllAuthorsWithBlogCount() throws {
//        let user1 = TestDataBuilder.anyUser()
//        try user1.save()
//        let post1 = TestDataBuilder.anyPost(author: user1)
//        try post1.save()
//        _ = try viewFactory.allAuthorsView(uri: authorsURI, allAuthors: [user1], user: nil)
//        XCTAssertEqual((viewRenderer.capturedContext?["authors"]?.array?.first)?["post_count"], 1)
//    }
//
//    func testAuthorsPageGetsPassedAuthorsSortedByPageCount() throws {
//        let user1 = TestDataBuilder.anyUser()
//        try user1.save()
//        let user2 = TestDataBuilder.anyUser(name: "Han", username: "han")
//        try user2.save()
//        let post1 = TestDataBuilder.anyPost(author: user1)
//        try post1.save()
//        let post2 = TestDataBuilder.anyPost(author: user2)
//        try post2.save()
//        let post3 = TestDataBuilder.anyPost(author: user2)
//        try post3.save()
//        _ = try viewFactory.allAuthorsView(uri: authorsURI, allAuthors: [user1, user2], user: nil)
//        XCTAssertEqual(viewRenderer.capturedContext?["authors"]?.array?.count, 2)
//        XCTAssertEqual((viewRenderer.capturedContext?["authors"]?.array?.first)?["name"], "Han")
//    }
//
//    func testTwitterHandleNotSetOnAllAuthorsPageIfNotProvided() throws {
//        viewFactory = LeafViewFactory(viewRenderer: viewRenderer, disqusName: nil, siteTwitterHandle: nil, googleAnalyticsIdentifier: nil)
//        _ = try viewFactory.allAuthorsView(uri: authorsURI, allAuthors: [], user: nil)
//        XCTAssertNil(viewRenderer.capturedContext?["site_twitter_handle"]?.string)
//    }
//
//    func testDisqusNameNotSetOnAllAuthorsPageIfNotProvided() throws {
//        viewFactory = LeafViewFactory(viewRenderer: viewRenderer, disqusName: nil, siteTwitterHandle: nil, googleAnalyticsIdentifier: nil)
//        _ = try viewFactory.allAuthorsView(uri: authorsURI, allAuthors: [], user: nil)
//        XCTAssertNil(viewRenderer.capturedContext?["disqus_name"]?.string)
//    }
//
//    func testGAIdentifierNotSetOnAllAuthorsPageIfNotProvided() throws {
//        viewFactory = LeafViewFactory(viewRenderer: viewRenderer, disqusName: nil, siteTwitterHandle: nil, googleAnalyticsIdentifier: nil)
//        _ = try viewFactory.allAuthorsView(uri: authorsURI, allAuthors: [], user: nil)
//        XCTAssertNil(viewRenderer.capturedContext?["google_analytics_identifier"]?.string)
//    }
//
//    func testNoLoggedInUserPassedToAllAuthorsPageIfNoneProvided() throws {
//        _ = try viewFactory.allAuthorsView(uri: authorsURI, allAuthors: [], user: nil)
//        XCTAssertNil(viewRenderer.capturedContext?["user"])
//    }
//
//    func testNoAuthorsGivenToAuthorsPageIfNonePassedToAllAuthorsPage() throws {
//        _ = try viewFactory.allAuthorsView(uri: authorsURI, allAuthors: [], user: nil)
//        XCTAssertNil(viewRenderer.capturedContext?["authors"])
//    }
//
//    // MARK: - Tag page
//
//    func testTagPageGetsTagWithCorrectParamsAndPostCount() throws {
//        let testTag = try setupTagPage()
//        _ = try viewFactory.tagView(uri: tagURI, tag: testTag, paginatedPosts: try testTag.sortedPosts().paginate(for: tagRequest), user: TestDataBuilder.anyUser(name: "Luke"))
//        XCTAssertEqual((viewRenderer.capturedContext?["tag"])?["post_count"], 1)
//        XCTAssertEqual((viewRenderer.capturedContext?["tag"])?["name"], "tatooine")
//        XCTAssertEqual(viewRenderer.capturedContext?["posts"]?["data"]?.array?.count, 1)
//        XCTAssertEqual((viewRenderer.capturedContext?["posts"]?["data"]?.array?.first)?["title"]?.string, TestDataBuilder.anyPost(author: TestDataBuilder.anyUser()).title)
//        XCTAssertEqual(viewRenderer.capturedContext?["uri"]?.string, "https://test.com/tags/tatooine/")
//        XCTAssertEqual(viewRenderer.capturedContext?["tag_page"]?.bool, true)
//        XCTAssertEqual(viewRenderer.capturedContext?["user"]?["name"]?.string, "Luke")
//        XCTAssertEqual(viewRenderer.capturedContext?["site_twitter_handle"]?.string, siteTwitterHandle)
//        XCTAssertEqual(viewRenderer.capturedContext?["disqus_name"]?.string, disqusName)
//        XCTAssertEqual(viewRenderer.capturedContext?["google_analytics_identifier"]?.string, googleAnalyticsIdentifier)
//        XCTAssertEqual(viewRenderer.leafPath, "blog/tag")
//    }
//
//    func testNoLoggedInUserPassedToTagPageIfNoneProvided() throws {
//        let testTag = try setupTagPage()
//        _ = try viewFactory.tagView(uri: tagURI, tag: testTag, paginatedPosts: try testTag.sortedPosts().paginate(for: tagRequest), user: nil)
//        XCTAssertNil(viewRenderer.capturedContext?["user"])
//    }
//
//    func testDisqusNameNotPassedToTagPageIfNotSet() throws {
//        viewFactory = LeafViewFactory(viewRenderer: viewRenderer, disqusName: nil, siteTwitterHandle: nil, googleAnalyticsIdentifier: nil)
//        let testTag = try setupTagPage()
//        _ = try viewFactory.tagView(uri: tagURI, tag: testTag, paginatedPosts: try testTag.sortedPosts().paginate(for: tagRequest), user: nil)
//        XCTAssertNil(viewRenderer.capturedContext?["disqus_name"]?.string)
//    }
//
//    func testTwitterHandleNotPassedToTagPageIfNotSet() throws {
//        viewFactory = LeafViewFactory(viewRenderer: viewRenderer, disqusName: nil, siteTwitterHandle: nil, googleAnalyticsIdentifier: nil)
//        let testTag = try setupTagPage()
//        _ = try viewFactory.tagView(uri: tagURI, tag: testTag, paginatedPosts: try testTag.sortedPosts().paginate(for: tagRequest), user: nil)
//        XCTAssertNil(viewRenderer.capturedContext?["site_twitter_handle"]?.string)
//    }
//
//    func testGAIdentifierNotPassedToTagPageIfNotSet() throws {
//        viewFactory = LeafViewFactory(viewRenderer: viewRenderer, disqusName: nil, siteTwitterHandle: nil, googleAnalyticsIdentifier: nil)
//        let testTag = try setupTagPage()
//        _ = try viewFactory.tagView(uri: tagURI, tag: testTag, paginatedPosts: try testTag.sortedPosts().paginate(for: tagRequest), user: nil)
//        XCTAssertNil(viewRenderer.capturedContext?["google_analytics_identifier"]?.string)
//    }
//
//    // MARK: - Blog Page
//
//    func testBlogPageGetsImageUrlIfOneInPostMarkdown() throws {
//       let (postWithImage, user) = try setupBlogPost()
//        _ = try viewFactory.blogPostView(uri: postURI, post: postWithImage, author: user, user: nil)
//
//        XCTAssertNotNil((viewRenderer.capturedContext?["post_image"])?.string)
//    }
//
//    func testDescriptionOnBlogPostPageIsShortSnippetTextCleaned() throws {
//        let (postWithImage, user) = try setupBlogPost()
//        _ = try viewFactory.blogPostView(uri: postURI, post: postWithImage, author: user, user: nil)
//
//        let expectedDescription = "Welcome to SteamPress! SteamPress started out as an idea - after all, I was porting sites and backends over to Swift and would like to have a blog as well. Being early days for Server-Side Swift, and embracing Vapor, there wasn't anything available to put a blog on my site, so I did what any self-respecting engineer would do - I made one! Besides, what better way to learn a framework than build a blog!"
//
//        XCTAssertEqual((viewRenderer.capturedContext?["post_description"])?.string?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines), expectedDescription)
//    }
//
//    func testBlogPostPageGetsCorrectParameters() throws {
//        let (postWithImage, user) = try setupBlogPost()
//        _ = try viewFactory.blogPostView(uri: postURI, post: postWithImage, author: user, user: nil)
//
//        XCTAssertEqual(viewRenderer.capturedContext?["post"]?["title"]?.string, postWithImage.title)
//        XCTAssertEqual(viewRenderer.capturedContext?["author"]?["name"]?.string, user.name)
//        XCTAssertTrue(((viewRenderer.capturedContext?["blog_post_page"])?.bool) ?? false)
//        XCTAssertNil(viewRenderer.capturedContext?["user"])
//        XCTAssertEqual(viewRenderer.capturedContext?["disqus_name"]?.string, disqusName)
//        XCTAssertEqual(viewRenderer.capturedContext?["site_twitter_handle"]?.string, siteTwitterHandle)
//        XCTAssertEqual(viewRenderer.capturedContext?["google_analytics_identifier"]?.string, googleAnalyticsIdentifier)
//        XCTAssertNotNil((viewRenderer.capturedContext?["post_image"])?.string)
//        XCTAssertNotNil((viewRenderer.capturedContext?["post_image_alt"])?.string)
//        XCTAssertEqual(viewRenderer.capturedContext?["post_uri"]?.string, "https://test.com/posts/test-post/")
//        XCTAssertEqual(viewRenderer.capturedContext?["site_uri"]?.string, "https://test.com/")
//        XCTAssertEqual(viewRenderer.capturedContext?["post_uri_encoded"]?.string, "https://test.com/posts/test-post/")
//        XCTAssertEqual(viewRenderer.leafPath, "blog/blogpost")
//    }
//
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
//
//    // MARK: - Blog Index
//
//    func testBlogIndexPageGivenCorrectParameters() throws {
//        let (posts, tags, authors) = try setupBlogIndex()
//        _ = try viewFactory.blogIndexView(uri: indexURI, paginatedPosts: posts, tags: tags, authors: authors, loggedInUser: nil)
//
//        XCTAssertEqual(viewRenderer.capturedContext?["uri"]?.string, indexURI.descriptionWithoutPort)
//        XCTAssertTrue((viewRenderer.capturedContext?["blog_index_page"]?.bool) ?? false)
//
//        XCTAssertEqual(viewRenderer.capturedContext?["posts"]?["data"]?.array?.count, posts.total)
//        XCTAssertEqual((viewRenderer.capturedContext?["posts"]?["data"]?.array?.first)?["title"]?.string, posts.data.first?.title)
//        XCTAssertEqual(viewRenderer.capturedContext?["tags"]?.array?.count, tags.count)
//        XCTAssertEqual((viewRenderer.capturedContext?["tags"]?.array?.first)?["name"]?.string, tags.first?.name)
//        XCTAssertEqual(viewRenderer.capturedContext?["authors"]?.array?.count, authors.count)
//        XCTAssertEqual((viewRenderer.capturedContext?["authors"]?.array?.first)?["name"]?.string, authors.first?.name)
//        XCTAssertEqual(viewRenderer.leafPath, "blog/blog")
//        XCTAssertEqual(viewRenderer.capturedContext?["disqus_name"]?.string, disqusName)
//        XCTAssertEqual(viewRenderer.capturedContext?["site_twitter_handle"]?.string, siteTwitterHandle)
//        XCTAssertEqual(viewRenderer.capturedContext?["google_analytics_identifier"]?.string, googleAnalyticsIdentifier)
//    }
//
//    func testNoPostsPassedIntoBlogIndexIfNoneAvailable() throws {
//        let (_, tags, authors) = try setupBlogIndex()
//        let emptyBlogPosts = try BlogPost.makeQuery().filter("title", "A non existent title").paginate(for: indexRequest)
//        _ = try viewFactory.blogIndexView(uri: indexURI, paginatedPosts: emptyBlogPosts, tags: tags, authors: authors, loggedInUser: nil)
//        XCTAssertNil(viewRenderer.capturedContext?["posts"])
//    }
//
//    func testNoAuthorsPassedIntoBlogIndexIfNoneCreated() throws {
//        let (posts, _, authors) = try setupBlogIndex()
//        _ = try viewFactory.blogIndexView(uri: indexURI, paginatedPosts: posts, tags: [], authors: authors, loggedInUser: nil)
//        XCTAssertNil(viewRenderer.capturedContext?["tags"])
//    }
//
//    func testNoTagsPassedIntoBlogIndexIfNoneCreted() throws {
//        let (posts, tags, _) = try setupBlogIndex()
//        _ = try viewFactory.blogIndexView(uri: indexURI, paginatedPosts: posts, tags: tags, authors: [], loggedInUser: nil)
//        XCTAssertNil(viewRenderer.capturedContext?["authors"])
//    }
//
//    func testUserPassedToBlogIndexIfUserPassedIn() throws {
//        let (posts, tags, authors) = try setupBlogIndex()
//        _ = try viewFactory.blogIndexView(uri: indexURI, paginatedPosts: posts, tags: tags, authors: authors, loggedInUser: authors[0])
//        XCTAssertEqual(viewRenderer.capturedContext?["user"]?["name"]?.string, authors.first?.name)
//    }
//
//    func testDisqusNameNotPassedToBlogIndexIfNotPassedIn() throws {
//        viewFactory = LeafViewFactory(viewRenderer: viewRenderer, disqusName: nil, siteTwitterHandle: nil, googleAnalyticsIdentifier: nil)
//        let (posts, tags, authors) = try setupBlogIndex()
//        _ = try viewFactory.blogIndexView(uri: indexURI, paginatedPosts: posts, tags: tags, authors: authors, loggedInUser: nil)
//        XCTAssertNil(viewRenderer.capturedContext?["disqus_name"]?.string)
//    }
//
//    func testTwitterHandleNotPassedToBlogIndexIfNotPassedIn() throws {
//        viewFactory = LeafViewFactory(viewRenderer: viewRenderer, disqusName: nil, siteTwitterHandle: nil, googleAnalyticsIdentifier: nil)
//        let (posts, tags, authors) = try setupBlogIndex()
//        _ = try viewFactory.blogIndexView(uri: indexURI, paginatedPosts: posts, tags: tags, authors: authors, loggedInUser: nil)
//        XCTAssertNil(viewRenderer.capturedContext?["site_twitter_handle"]?.string)
//    }
//
//    func testGAIdentifierNotPassedToBlogIndexIfNotPassedIn() throws {
//        viewFactory = LeafViewFactory(viewRenderer: viewRenderer, disqusName: nil, siteTwitterHandle: nil, googleAnalyticsIdentifier: nil)
//        let (posts, tags, authors) = try setupBlogIndex()
//        _ = try viewFactory.blogIndexView(uri: indexURI, paginatedPosts: posts, tags: tags, authors: authors, loggedInUser: nil)
//        XCTAssertNil(viewRenderer.capturedContext?["google_analytics_identifier"]?.string)
//    }
//
//    // MARK: - Author page
//
//    func testAuthorViewHasCorrectParametersSet() throws {
//        let (author, posts) = try setupAuthorPage()
//        let _ = try viewFactory.profileView(uri: authorURI, author: author, paginatedPosts: posts, loggedInUser: nil)
//
//        XCTAssertEqual(viewRenderer.capturedContext?["author"]?["name"]?.string, author.name)
//        XCTAssertEqual(viewRenderer.capturedContext?["posts"]?["data"]?.array?.count, posts.total)
//        XCTAssertEqual((viewRenderer.capturedContext?["posts"]?["data"]?.array?.first)?["title"]?.string, TestDataBuilder.anyPostWithImage(author: TestDataBuilder.anyUser()).title)
//        XCTAssertEqual(viewRenderer.capturedContext?["uri"]?.string, authorURI.descriptionWithoutPort)
//        XCTAssertTrue((viewRenderer.capturedContext?["profile_page"]?.bool) ?? false)
//        XCTAssertNil(viewRenderer.capturedContext?["my_profile"])
//        XCTAssertNil(viewRenderer.capturedContext?["user"])
//        XCTAssertEqual(viewRenderer.capturedContext?["disqus_name"]?.string, disqusName)
//        XCTAssertEqual(viewRenderer.capturedContext?["site_twitter_handle"]?.string, siteTwitterHandle)
//        XCTAssertEqual(viewRenderer.capturedContext?["google_analytics_identifier"]?.string, googleAnalyticsIdentifier)
//        XCTAssertEqual(viewRenderer.capturedContext?["author"]?["tagline"]?.string, author.tagline)
//        XCTAssertEqual(viewRenderer.capturedContext?["author"]?["twitter_handle"]?.string, author.twitterHandle)
//        XCTAssertEqual(viewRenderer.capturedContext?["author"]?["biography"]?.string, author.biography)
//        XCTAssertEqual(viewRenderer.capturedContext?["author"]?["profile_picture"]?.string, author.profilePicture?.description)
//        XCTAssertEqual(viewRenderer.leafPath, "blog/profile")
//    }
//
//    func testAuthorViewHasNoPostsSetIfNoneCreated() throws {
//        let (author, _) = try setupAuthorPage()
//        let emptyPosts = try BlogPost.makeQuery().filter("title", "Some non-existing query").paginate(for: authorRequest)
//        let _ = try viewFactory.profileView(uri: authorURI, author: author, paginatedPosts: emptyPosts, loggedInUser: nil)
//        XCTAssertNil(viewRenderer.capturedContext?["posts"])
//    }
//
//    func testAuthorViewGetsLoggedInUserIfProvider() throws {
//        let (author, posts) = try setupAuthorPage()
//        let _ = try viewFactory.profileView(uri: authorURI, author: author, paginatedPosts: posts, loggedInUser: author)
//        XCTAssertEqual(viewRenderer.capturedContext?["user"]?["name"]?.string, author.name)
//    }
//
//    func testAuthorViewDoesNotGetDisqusNameIfNotProvided() throws {
//        viewFactory = LeafViewFactory(viewRenderer: viewRenderer, disqusName: nil, siteTwitterHandle: nil, googleAnalyticsIdentifier: nil)
//        let (author, posts) = try setupAuthorPage()
//        let _ = try viewFactory.profileView(uri: authorURI, author: author, paginatedPosts: posts, loggedInUser: nil)
//        XCTAssertNil(viewRenderer.capturedContext?["disqus_name"]?.string)
//    }
//
//    func testAuthorViewDoesNotGetTwitterHandleIfNotProvided() throws {
//        viewFactory = LeafViewFactory(viewRenderer: viewRenderer, disqusName: nil, siteTwitterHandle: nil, googleAnalyticsIdentifier: nil)
//        let (author, posts) = try setupAuthorPage()
//        let _ = try viewFactory.profileView(uri: authorURI, author: author, paginatedPosts: posts, loggedInUser: nil)
//        XCTAssertNil(viewRenderer.capturedContext?["site_twitter_handle"]?.string)
//    }
//
//    func testAuthorViewDoesNotGetGAIdentifierIfNotProvided() throws {
//        viewFactory = LeafViewFactory(viewRenderer: viewRenderer, disqusName: nil, siteTwitterHandle: nil, googleAnalyticsIdentifier: nil)
//        let (author, posts) = try setupAuthorPage()
//        let _ = try viewFactory.profileView(uri: authorURI, author: author, paginatedPosts: posts, loggedInUser: nil)
//        XCTAssertNil(viewRenderer.capturedContext?["google_analytics_identifier"]?.string)
//    }
//
//    func testAuthorViewGetsPostCount() throws {
//        let (author, posts) = try setupAuthorPage()
//        _ = try viewFactory.profileView(uri: authorURI, author: author, paginatedPosts: posts, loggedInUser: nil)
//        XCTAssertEqual(viewRenderer.capturedContext?["author"]?["post_count"]?.int, 2)
//    }
//
//    func testAuthorViewGetsLongSnippetForPosts() throws {
//        let (author, posts) = try setupAuthorPage()
//        _ = try viewFactory.profileView(uri: authorURI, author: author, paginatedPosts: posts, loggedInUser: nil)
//        XCTAssertNotNil(viewRenderer.capturedContext?["posts"]?["data"]?.array?.first?["long_snippet"]?.string)
//    }
//
//
//    // MARK: - Admin pages
//
//    func testPasswordViewGivenCorrectParameters() throws {
//        let user = TestDataBuilder.anyUser()
//        let _ = try viewFactory.createResetPasswordView(errors: nil, passwordError: nil, confirmPasswordError: nil, user: user)
//        XCTAssertNil(viewRenderer.capturedContext?["errors"])
//        XCTAssertNil(viewRenderer.capturedContext?["password_error"])
//        XCTAssertNil(viewRenderer.capturedContext?["confirm_password_error"])
//        XCTAssertEqual(viewRenderer.capturedContext?["user"]?["name"]?.string, user.name)
//        XCTAssertEqual(viewRenderer.leafPath, "blog/admin/resetPassword")
//    }
//
//    func testPasswordViewHasCorrectParametersWhenError() throws {
//        let user = TestDataBuilder.anyUser()
//        let expectedError = "Passwords do not match"
//        let _ = try viewFactory.createResetPasswordView(errors: [expectedError], passwordError: true, confirmPasswordError: true, user: user)
//        XCTAssertEqual(viewRenderer.capturedContext?["errors"]?.array?.count, 1)
//        XCTAssertEqual((viewRenderer.capturedContext?["errors"]?.array?.first)?.string, expectedError)
//        XCTAssertTrue((viewRenderer.capturedContext?["password_error"]?.bool) ?? false)
//        XCTAssertTrue((viewRenderer.capturedContext?["confirm_password_error"]?.bool) ?? false)
//        XCTAssertEqual(viewRenderer.capturedContext?["user"]?["name"]?.string, user.name)
//    }
//
//    func testLoginViewGetsCorrectParameters() throws {
//        let _ = try viewFactory.createLoginView(loginWarning: false, errors: nil, username: nil, password: nil)
//        XCTAssertFalse((viewRenderer.capturedContext?["username_error"]?.bool) ?? true)
//        XCTAssertFalse((viewRenderer.capturedContext?["password_error"]?.bool) ?? true)
//        XCTAssertNil(viewRenderer.capturedContext?["username_supplied"])
//        XCTAssertNil(viewRenderer.capturedContext?["errors"])
//        XCTAssertNil(viewRenderer.capturedContext?["login_warning"])
//        XCTAssertEqual(viewRenderer.leafPath, "blog/admin/login")
//    }
//
//    func testLoginViewWhenErrored() throws {
//        let expectedError = "Username/password incorrect"
//        let _ = try viewFactory.createLoginView(loginWarning: true, errors: [expectedError], username: "tim", password: "password")
//        XCTAssertFalse((viewRenderer.capturedContext?["username_error"]?.bool) ?? true)
//        XCTAssertFalse((viewRenderer.capturedContext?["password_error"]?.bool) ?? true)
//        XCTAssertEqual(viewRenderer.capturedContext?["username_supplied"]?.string, "tim")
//        XCTAssertTrue((viewRenderer.capturedContext?["login_warning"]?.bool) ?? false)
//        XCTAssertEqual(viewRenderer.capturedContext?["errors"]?.array?.first?.string, expectedError)
//    }
//
//    func testLoginPageUsernamePasswordErrorsMarkedWhenNotSuppliedAndErrored() throws {
//        let expectedError = "Username/password incorrect"
//        let _ = try viewFactory.createLoginView(loginWarning: true, errors: [expectedError], username: nil, password: nil)
//        XCTAssertTrue((viewRenderer.capturedContext?["username_error"]?.bool) ?? false)
//        XCTAssertTrue((viewRenderer.capturedContext?["password_error"]?.bool) ?? false)
//    }
//
//    func testBlogAdminViewGetsCorrectParameters() throws {
//        // Add some stuff to the database
//        let (posts, _, users) = try setupBlogIndex()
//        let draftPost = TestDataBuilder.anyPost(author: users.first!, title: "[DRAFT] This will be awesome", published: false)
//        try draftPost.save()
//        let _ = try viewFactory.createBlogAdminView(user: TestDataBuilder.anyUser())
//        XCTAssertNil(viewRenderer.capturedContext?["errors"])
//        XCTAssertTrue((viewRenderer.capturedContext?["blog_admin_page"]?.bool) ?? false)
//        XCTAssertEqual(viewRenderer.capturedContext?["user"]?["name"]?.string, users.first?.name)
//        XCTAssertEqual(viewRenderer.capturedContext?["users"]?.array?.count, 2)
//        XCTAssertEqual(viewRenderer.capturedContext?["users"]?.array?.first?["name"]?.string, users.first?.name)
//        XCTAssertEqual(viewRenderer.capturedContext?["published_posts"]?.array?.count, 2)
//        XCTAssertEqual(viewRenderer.capturedContext?["published_posts"]?.array?.first?["title"]?.string, posts.data[1].title)
//        XCTAssertEqual(viewRenderer.capturedContext?["draft_posts"]?.array?.count, 1)
//        XCTAssertEqual(viewRenderer.capturedContext?["draft_posts"]?.array?.first?["title"]?.string, draftPost.title)
//        XCTAssertEqual(viewRenderer.leafPath, "blog/admin/index")
//    }
//
//    func testNoPostsPassedToAdminViewIfNone() throws {
//        let _ = try viewFactory.createBlogAdminView(user: TestDataBuilder.anyUser())
//        XCTAssertNil(viewRenderer.capturedContext?["posts"])
//    }
//
//    func testAdminPageWithErrors() throws {
//        let expectedError = "You cannot delete yourself!"
//        let _ = try viewFactory.createBlogAdminView(errors: [expectedError], user: TestDataBuilder.anyUser())
//        XCTAssertEqual(viewRenderer.capturedContext?["errors"]?.array?.first?.string, expectedError)
//    }
//
//    func testCreateUserViewGetsCorrectParameters() throws {
//        let user = TestDataBuilder.anyUser()
//        let _ = try viewFactory.createUserView(loggedInUser: user)
//        XCTAssertFalse((viewRenderer.capturedContext?["name_error"]?.bool) ?? true)
//        XCTAssertFalse((viewRenderer.capturedContext?["username_error"]?.bool) ?? true)
//        XCTAssertNil(viewRenderer.capturedContext?["errors"])
//        XCTAssertNil(viewRenderer.capturedContext?["name_supplied"])
//        XCTAssertNil(viewRenderer.capturedContext?["username_supplied"])
//        XCTAssertNil(viewRenderer.capturedContext?["password_error"])
//        XCTAssertNil(viewRenderer.capturedContext?["confirm_password_error"])
//        XCTAssertNil(viewRenderer.capturedContext?["reset_password_on_login_supplied"])
//        XCTAssertNil(viewRenderer.capturedContext?["editing"])
//        XCTAssertNil(viewRenderer.capturedContext?["user_id"])
//        XCTAssertNil(viewRenderer.capturedContext?["twitter_handle_supplied"])
//        XCTAssertNil(viewRenderer.capturedContext?["profile_picture_supplied"])
//        XCTAssertNil(viewRenderer.capturedContext?["biography_supplied"])
//        XCTAssertNil(viewRenderer.capturedContext?["tagline_supplied"])
//        XCTAssertEqual(viewRenderer.leafPath, "blog/admin/createUser")
//        XCTAssertEqual(viewRenderer.capturedContext?["user"]?["name"]?.string, user.name)
//    }
//
//    func testCreateUserViewWhenErrors() throws {
//        let user = TestDataBuilder.anyUser()
//        let expectedError = "Not valid password"
//        let _ = try viewFactory.createUserView(errors: [expectedError], name: "Luke", username: "luke", passwordError: true, confirmPasswordError: true, resetPasswordRequired: true, profilePicture: "https://static.brokenhands.io/steampress/images/authors/luke.png", twitterHandle: "luke", biography: "The last Jedi in the Galaxy", tagline: "A son without a father", loggedInUser: user)
//        XCTAssertFalse((viewRenderer.capturedContext?["name_error"]?.bool) ?? true)
//        XCTAssertFalse((viewRenderer.capturedContext?["username_error"]?.bool) ?? true)
//        XCTAssertEqual(viewRenderer.capturedContext?["errors"]?.array?.first?.string, expectedError)
//        XCTAssertEqual(viewRenderer.capturedContext?["name_supplied"]?.string, "Luke")
//        XCTAssertEqual(viewRenderer.capturedContext?["username_supplied"]?.string, "luke")
//        XCTAssertTrue((viewRenderer.capturedContext?["password_error"]?.bool) ?? false)
//        XCTAssertTrue((viewRenderer.capturedContext?["confirm_password_error"]?.bool) ?? false)
//        XCTAssertTrue((viewRenderer.capturedContext?["reset_password_on_login_supplied"]?.bool) ?? false)
//        XCTAssertEqual(viewRenderer.capturedContext?["profile_picture_supplied"]?.string, "https://static.brokenhands.io/steampress/images/authors/luke.png")
//        XCTAssertEqual(viewRenderer.capturedContext?["twitter_handle_supplied"]?.string, "luke")
//        XCTAssertEqual(viewRenderer.capturedContext?["tagline_supplied"]?.string, "A son without a father")
//        XCTAssertEqual(viewRenderer.capturedContext?["biography_supplied"]?.string, "The last Jedi in the Galaxy")
//        XCTAssertEqual(viewRenderer.capturedContext?["user"]?["name"]?.string, user.name)
//    }
//
//    func testCreateUserViewWhenNoNameOrUsernameSupplied() throws {
//        let user = TestDataBuilder.anyUser()
//        let expectedError = "No name supplied"
//        let _ = try viewFactory.createUserView(errors: [expectedError], name: nil, username: nil, passwordError: true, confirmPasswordError: true, resetPasswordRequired: true, loggedInUser: user)
//        XCTAssertTrue((viewRenderer.capturedContext?["name_error"]?.bool) ?? false)
//        XCTAssertTrue((viewRenderer.capturedContext?["username_error"]?.bool) ?? false)
//        XCTAssertEqual(viewRenderer.capturedContext?["user"]?["name"]?.string, user.name)
//    }
//
//    func testCreateUserViewForEditing() throws {
//        let user = TestDataBuilder.anyUser()
//        let _ = try viewFactory.createUserView(editing: true, errors: nil, name: "Luke", username: "luke", userId: Identifier(StructuredData.number(1), in: nil), profilePicture: "https://static.brokenhands.io/steampress/images/authors/luke.png", twitterHandle: "luke", biography: "The last Jedi in the Galaxy", tagline: "A son without a father", loggedInUser: user)
//        XCTAssertEqual(viewRenderer.capturedContext?["name_supplied"]?.string, "Luke")
//        XCTAssertEqual(viewRenderer.capturedContext?["username_supplied"]?.string, "luke")
//        XCTAssertTrue((viewRenderer.capturedContext?["editing"]?.bool) ?? false)
//        XCTAssertEqual(viewRenderer.capturedContext?["user_id"]?.int, 1)
//        XCTAssertEqual(viewRenderer.capturedContext?["profile_picture_supplied"]?.string, "https://static.brokenhands.io/steampress/images/authors/luke.png")
//        XCTAssertEqual(viewRenderer.capturedContext?["twitter_handle_supplied"]?.string, "luke")
//        XCTAssertEqual(viewRenderer.capturedContext?["tagline_supplied"]?.string, "A son without a father")
//        XCTAssertEqual(viewRenderer.capturedContext?["biography_supplied"]?.string, "The last Jedi in the Galaxy")
//        XCTAssertEqual(viewRenderer.leafPath, "blog/admin/createUser")
//        XCTAssertEqual(viewRenderer.capturedContext?["user"]?["name"]?.string, user.name)
//    }
//
//    func testCreateUserViewThrowsWhenTryingToEditWithoutUserId() throws {
//        var errored = false
//        do {
//            let _ = try viewFactory.createUserView(editing: true, errors: nil, name: "Luke", username: "luke", userId: nil, loggedInUser: TestDataBuilder.anyUser())
//        } catch {
//            errored = true
//        }
//
//        XCTAssertTrue(errored)
//    }
//
//    func testCreateBlogPostViewGetsCorrectParameters() throws {
//        let user = TestDataBuilder.anyUser()
//        let _ = try viewFactory.createBlogPostView(uri: createPostURI, user: user)
//        XCTAssertEqual(viewRenderer.capturedContext?["post_path_prefix"]?.string, "https://test.com/posts/")
//        XCTAssertFalse((viewRenderer.capturedContext?["title_error"]?.bool) ?? true)
//        XCTAssertFalse((viewRenderer.capturedContext?["contents_error"]?.bool) ?? true)
//        XCTAssertNil(viewRenderer.capturedContext?["errors"])
//        XCTAssertNil(viewRenderer.capturedContext?["title_supplied"])
//        XCTAssertNil(viewRenderer.capturedContext?["contents_supplied"])
//        XCTAssertNil(viewRenderer.capturedContext?["slug_url_supplied"])
//        XCTAssertNil(viewRenderer.capturedContext?["tags_supplied"])
//        XCTAssertEqual(viewRenderer.leafPath, "blog/admin/createPost")
//        XCTAssertTrue((viewRenderer.capturedContext?["create_blog_post_page"]?.bool) ?? false)
//        XCTAssertTrue((viewRenderer.capturedContext?["draft"]?.bool) ?? false)
//        XCTAssertNil(viewRenderer.capturedContext?["editing"])
//        XCTAssertEqual(viewRenderer.capturedContext?["user"]?["name"]?.string, user.name)
//    }
//
//    func testCreateBlogPostViewWhenEditing() throws {
//        let author = TestDataBuilder.anyUser()
//        try author.save()
//        let postToEdit = TestDataBuilder.anyPost(author: author)
//        try postToEdit.save()
//        let _ = try viewFactory.createBlogPostView(uri: editPostURI, title: postToEdit.title, contents: postToEdit.contents, slugUrl: postToEdit.slugUrl, tags: [Node(node: "test")], isEditing: true, postToEdit: postToEdit, user: author)
//        XCTAssertEqual(viewRenderer.capturedContext?["post_path_prefix"]?.string, "https://test.com/posts/")
//        XCTAssertFalse((viewRenderer.capturedContext?["title_error"]?.bool) ?? true)
//        XCTAssertFalse((viewRenderer.capturedContext?["contents_error"]?.bool) ?? true)
//        XCTAssertNil(viewRenderer.capturedContext?["errors"])
//        XCTAssertEqual(viewRenderer.capturedContext?["title_supplied"]?.string, postToEdit.title)
//        XCTAssertEqual(viewRenderer.capturedContext?["contents_supplied"]?.string, postToEdit.contents)
//        XCTAssertEqual(viewRenderer.capturedContext?["slug_url_supplied"]?.string, postToEdit.slugUrl)
//        XCTAssertEqual(viewRenderer.capturedContext?["tags_supplied"]?.array?.count, 1)
//        XCTAssertEqual(viewRenderer.capturedContext?["tags_supplied"]?.array?.first?.string, "test")
//        XCTAssertTrue((viewRenderer.capturedContext?["editing"]?.bool) ?? false)
//        XCTAssertEqual(viewRenderer.capturedContext?["post"]?["title"]?.string, postToEdit.title)
//        XCTAssertNil(viewRenderer.capturedContext?["create_blog_post_page"])
//        XCTAssertEqual(viewRenderer.capturedContext?["post"]?["published"]?.bool, true)
//        XCTAssertEqual(viewRenderer.capturedContext?["user"]?["name"]?.string, author.name)
//    }
//
//    func testEditBlogPostViewThrowsWithNoPostToEdit() throws {
//        var errored = false
//        do {
//            let _ = try viewFactory.createBlogPostView(uri: createPostURI, isEditing: true, postToEdit: nil, user: TestDataBuilder.anyUser())
//        } catch {
//            errored = true
//        }
//
//        XCTAssertTrue(errored)
//    }
//
//    func testCreateBlogPostViewWithErrorsAndNoTitleOrContentsSupplied() throws {
//        let expectedError = "Please enter a title"
//        let user = TestDataBuilder.anyUser()
//        let _ = try viewFactory.createBlogPostView(uri: createPostURI, errors: [expectedError], title: nil, contents: nil, slugUrl: nil, tags: nil, isEditing: false, user: user)
//        XCTAssertTrue((viewRenderer.capturedContext?["title_error"]?.bool) ?? false)
//        XCTAssertTrue((viewRenderer.capturedContext?["contents_error"]?.bool) ?? false)
//        XCTAssertEqual(viewRenderer.capturedContext?["errors"]?.array?.count, 1)
//        XCTAssertEqual(viewRenderer.capturedContext?["errors"]?.array?.first?.string, expectedError)
//        XCTAssertEqual(viewRenderer.capturedContext?["user"]?["name"]?.string, user.name)
//    }
//
//    func testDraftPassedThroughWhenEditingABlogPostThatHasNotBeenPublished() throws {
//        let author = TestDataBuilder.anyUser()
//        try author.save()
//        let postToEdit = TestDataBuilder.anyPost(author: author, published: false)
//        try postToEdit.save()
//        let _ = try viewFactory.createBlogPostView(uri: editPostURI, title: postToEdit.title, contents: postToEdit.contents, slugUrl: postToEdit.slugUrl, tags: [Node(node: "test")], isEditing: true, postToEdit: postToEdit, user: TestDataBuilder.anyUser())
//        XCTAssertEqual(viewRenderer.capturedContext?["post"]?["published"]?.bool, false)
//    }
//
//    func testSiteURIForHTTPDoesNotContainPort() throws {
//        let (postWithImage, user) = try setupBlogPost()
//        let httpURI = URI(scheme: "http", hostname: "test.com", path: "posts/test-post/")
//        _ = try viewFactory.blogPostView(uri: httpURI, post: postWithImage, author: user, user: nil)
//
//        XCTAssertEqual(viewRenderer.capturedContext?["site_uri"]?.string, "http://test.com/")
//    }
//
//    func testSearchPageGetsCorrectParameters() throws {
//        let (posts, _, users) = try setupBlogIndex()
//        _ = try viewFactory.searchView(uri: searchURI, searchTerm: "Test", foundPosts: posts, emptySearch: false, user: users[0])
//
//        XCTAssertEqual(viewRenderer.capturedContext?["uri"]?.string, searchURI.descriptionWithoutPort)
//
//        XCTAssertEqual(viewRenderer.capturedContext?["posts"]?["data"]?.array?.count, posts.total)
//        XCTAssertEqual((viewRenderer.capturedContext?["posts"]?["data"]?.array?.first)?["title"]?.string, posts.data.first?.title)
//        XCTAssertEqual(viewRenderer.capturedContext?["user"]?["name"]?.string, users.first?.name)
//        XCTAssertEqual(viewRenderer.leafPath, "blog/search")
//        XCTAssertNil(viewRenderer.capturedContext?["emptySearch"]?.bool)
//        XCTAssertEqual(viewRenderer.capturedContext?["searchTerm"]?.string, "Test")
//        XCTAssertEqual(viewRenderer.capturedContext?["searchCount"]?.int, 2)
//        XCTAssertEqual(viewRenderer.capturedContext?["disqus_name"]?.string, disqusName)
//        XCTAssertEqual(viewRenderer.capturedContext?["site_twitter_handle"]?.string, siteTwitterHandle)
//        XCTAssertEqual(viewRenderer.capturedContext?["google_analytics_identifier"]?.string, googleAnalyticsIdentifier)
//    }
//
//    func testSearchPageGetsFlagIfNoSearchTermProvided() throws {
//        _ = try viewFactory.searchView(uri: searchURI, searchTerm: nil, foundPosts: nil, emptySearch: true, user: nil)
//
//        XCTAssertTrue(viewRenderer.capturedContext?["emptySearch"]?.bool ?? false)
//        XCTAssertNil(viewRenderer.capturedContext?["posts"])
//    }
//
//    func testSearchPageGetsCountIfNoPagesFound() throws {
//        _ = try viewFactory.searchView(uri: searchURI, searchTerm: "Test", foundPosts: BlogPost.makeQuery().paginate(for: indexRequest), emptySearch: false, user: nil)
//
//        XCTAssertEqual(viewRenderer.capturedContext?["searchCount"]?.int, 0)
//    }

//func testTagPageGetsUri() throws {
//    _ = try testWorld.getResponse(to: tagRequestPath)
//    XCTAssertEqual(presenter.tagURL?.description, tagRequestPath)
//}
//
//func testTagPageGetsHTTPSUriFromReverseProxy() throws {
    //            try setupDrop()
    //
    //            let httpsReverseProxyRequest = Request(method: .get, uri: "http://geeks.brokenhands.io\(tagPath)")
    //            httpsReverseProxyRequest.headers["X-Forwarded-Proto"] = "https"
    //
    //            _ = try drop.respond(to: httpsReverseProxyRequest)
    //
    //            XCTAssertEqual("https://geeks.brokenhands.io/tags/tatooine/", viewFactory.tagURI?.descriptionWithoutPort)
//    #warning("Implement")
//}
//
//func testAllTagsPageGetsUri() throws {
//    _ = try testWorld.getResponse(to: allTagsRequestPath)
//    XCTAssertEqual(presenter.allTagsURL?.description, allTagsRequestPath)
//}
//
//func testAllTagsPageGetsHTTPSUriFromReverseProxy() throws {
    //            try setupDrop()
    //
    //            let httpsReverseProxyRequest = Request(method: .get, uri: "http://geeks.brokenhands.io\(allTagsPath)")
    //            httpsReverseProxyRequest.headers["X-Forwarded-Proto"] = "https"
    //
    //            _ = try drop.respond(to: httpsReverseProxyRequest)
    //
    //            XCTAssertEqual("https://geeks.brokenhands.io/tags/", viewFactory.allTagsURI?.descriptionWithoutPort)
//    #warning("Implement")
//}
//func testAllAuthorsPageGetsUri() throws {
//    _ = try testWorld.getResponse(to: allAuthorsRequestPath)
//    XCTAssertEqual(presenter.allAuthorsURL?.description, allAuthorsRequestPath)
//}
//
//func testAllAuthorsPageGetsHTTPSUriFromReverseProxy() throws {
//    //        try setupDrop()
//    //
//    //        let httpsReverseProxyRequest = Request(method: .get, uri: "http://geeks.brokenhands.io\(allAuthorsPath)")
//    //        httpsReverseProxyRequest.headers["X-Forwarded-Proto"] = "https"
//    //
//    //        _ = try drop.respond(to: httpsReverseProxyRequest)
//    //
//    //        XCTAssertEqual("https://geeks.brokenhands.io/authors/", viewFactory.allAuthorsURI?.descriptionWithoutPort)
//    XCTFail("Implement")
//}
//func testProfilePageGetsUri() throws {
//    _ = try testWorld.getResponse(to: authorsRequestPath)
//
//    XCTAssertEqual(presenter.authorURL?.description, authorsRequestPath)
//}
//
//func testProfilePageGetsHTTPSUriFromReverseProxy() throws {
//    //        try setupDrop()
//    //
//    //        let httpsReverseProxyRequest = Request(method: .get, uri: "http://geeks.brokenhands.io\(authorPath)")
//    //        httpsReverseProxyRequest.headers["X-Forwarded-Proto"] = "https"
//    //
//    //        _ = try drop.respond(to: httpsReverseProxyRequest)
//    //
//    //        XCTAssertEqual("https://geeks.brokenhands.io/authors/luke/", viewFactory.authorURI?.descriptionWithoutPort)
//    #warning("Implement")
//}
//func testIndexPageGetsUri() throws {
//        try setupDrop()
//
//        _ = try drop.respond(to: blogIndexRequest)
//
//        XCTAssertEqual(blogIndexPath, viewFactory.blogIndexURI?.description)
//    }
//
//    func testIndexPageGetsHTTPSUriFromReverseProxy() throws {
//        try setupDrop()
//
//        let httpsReverseProxyRequest = Request(method: .get, uri: "http://geeks.brokenhands.io\(blogIndexPath)")
//        httpsReverseProxyRequest.headers["X-Forwarded-Proto"] = "https"
//
//        _ = try drop.respond(to: httpsReverseProxyRequest)
//
//        XCTAssertEqual("https://geeks.brokenhands.io/", viewFactory.blogIndexURI?.descriptionWithoutPort)
//    }
//
//    func testBlogPageGetsUri() throws {
//        try setupDrop()
//
//        _ = try drop.respond(to: blogPostRequest)
//
//        XCTAssertEqual(blogPostPath, viewFactory.blogPostURI?.description)
//    }
//
//    func testHTTPSPassedThroughToBlogPageURI() throws {
//        try setupDrop()
//
//        let httpsRequest = Request(method: .get, uri: "https://localhost\(blogPostPath)")
//        _ = try drop.respond(to: httpsRequest)
//
//        XCTAssertEqual("https://localhost/posts/test-path/", viewFactory.blogPostURI?.descriptionWithoutPort)
//    }
//
//    func testHTTPSURIPassedThroughAsBlogPageURIIfAccessingViaReverseProxyOverHTTPS() throws {
//        try setupDrop()
//
//        let httpsReverseProxyRequest = Request(method: .get, uri: "http://geeks.brokenhands.io\(blogPostPath)")
//        httpsReverseProxyRequest.headers["X-Forwarded-Proto"] = "https"
//
//        _ = try drop.respond(to: httpsReverseProxyRequest)
//
//        XCTAssertEqual("https://geeks.brokenhands.io/posts/test-path/", viewFactory.blogPostURI?.descriptionWithoutPort)
//    }
//
//    func testBlogPostPageGetHTPSURIFromReverseProxyLowerCase() throws {
//        try setupDrop()
//
//        let httpsReverseProxyRequest = Request(method: .get, uri: "http://geeks.brokenhands.io\(blogPostPath)")
//        httpsReverseProxyRequest.headers["x-forwarded-proto"] = "https"
//
//        _ = try drop.respond(to: httpsReverseProxyRequest)
//
//        XCTAssertEqual("https://geeks.brokenhands.io/posts/test-path/", viewFactory.blogPostURI?.descriptionWithoutPort)
//    }
//    func testAdminPageGetsLoggedInUser() throws {
//        let request = try createLoggedInRequest(method: .get, path: "", for: user)
//        _ = try drop.respond(to: request)
//
//        XCTAssertEqual(user.name, capturingViewFactory.adminUser?.name)
//    }
//
//    func testCreatePostPageGetsLoggedInUser() throws {
//        let request = try createLoggedInRequest(method: .get, path: "createPost", for: user)
//        _ = try drop.respond(to: request)
//
//        XCTAssertEqual(user.name, capturingViewFactory.createBlogPostUser?.name)
//    }
//
//    func testEditPostPageGetsLoggedInUser() throws {
//        let user = TestDataBuilder.anyUser()
//        try user.save()
//        let post = TestDataBuilder.anyPost(author: user)
//        try post.save()
//        let request = try createLoggedInRequest(method: .get, path: "posts/\(post.id!.string!)/edit", for: user)
//        _ = try drop.respond(to: request)
//
//        XCTAssertEqual(user.name, capturingViewFactory.createBlogPostUser?.name)
//    }
//
//    func testCreateUserPageGetsLoggedInUser() throws {
//        let request = try createLoggedInRequest(method: .get, path: "createUser", for: user)
//        _ = try drop.respond(to: request)
//
//        XCTAssertEqual(user.name, capturingViewFactory.createUserLoggedInUser?.name)
//    }
//
//    func testEditUserPageGetsLoggedInUser() throws {
//        let user = TestDataBuilder.anyUser()
//        try user.save()
//        let request = try createLoggedInRequest(method: .get, path: "users/\(user.id!.string!)/edit", for: user)
//        _ = try drop.respond(to: request)
//
//        XCTAssertEqual(user.name, capturingViewFactory.createUserLoggedInUser?.name)
//    }
//
//    func testResetPasswordPageGetsLoggedInUser() throws {
//        let request = try createLoggedInRequest(method: .get, path: "resetPassword", for: user)
//        _ = try drop.respond(to: request)
//
//        XCTAssertEqual(user.name, capturingViewFactory.resetPasswordUser?.name)
//    }
//
//    func testCreatePostPageGetsURI() throws {
//        let request = try createLoggedInRequest(method: .get, path: "createPost")
//        _ = try drop.respond(to: request)
//
//        XCTAssertEqual(capturingViewFactory.createPostURI?.descriptionWithoutPort, "/blog/admin/createPost/")
//    }
//
//    func testCreatePostPageGetsHTTPSURIIfFromReverseProxy() throws {
//        let request = Request(method: .get, uri: "http://geeks.brokenhands.io/blog/admin/createPost/")
//        let user = TestDataBuilder.anyUser()
//        try user.save()
//        request.storage["auth-authenticated"] = user
//        request.headers["X-Forwarded-Proto"] = "https"
//
//        _ = try drop.respond(to: request)
//
//        XCTAssertEqual(capturingViewFactory.createPostURI?.descriptionWithoutPort, "https://geeks.brokenhands.io/blog/admin/createPost/")
//    }
//
//    // MARK: - Helpers
//
//    private func setupBlogIndex() throws -> (Page<BlogPost>, [BlogTag], [BlogUser]) {
//        let user1 = TestDataBuilder.anyUser()
//        try user1.save()
//        let user2 = TestDataBuilder.anyUser(name: "Han", username: "han")
//        try user2.save()
//        let post1 = TestDataBuilder.anyPost(author: user1)
//        try post1.save()
//        let post2 = TestDataBuilder.anyPostWithImage(author: user2)
//        try post2.save()
//        let tag = BlogTag(name: "tatooine")
//        try tag.save()
//        try BlogTag.addTag(tag.name, to: post1)
//        return try (BlogPost.makeQuery().paginate(for: indexRequest), [tag], [user1, user2])
//    }
//
//    private func setupBlogPost() throws -> (BlogPost, BlogUser) {
//        let user = TestDataBuilder.anyUser()
//        try user.save()
//        let postWithImage = TestDataBuilder.anyPostWithImage(author: user)
//        try postWithImage.save()
//        return (postWithImage, user)
//    }
//
//    private func setupTagPage() throws -> BlogTag {
//        let tag = BlogTag(name: "tatooine")
//        try tag.save()
//        let user = TestDataBuilder.anyUser()
//        try user.save()
//        let post1 = TestDataBuilder.anyPost(author: user)
//        try post1.save()
//        try BlogTag.addTag(tag.name, to: post1)
//        return tag
//    }
//
//    private func setupAuthorPage() throws -> (BlogUser, Page<BlogPost>) {
//        let user = TestDataBuilder.anyUser()
//        try user.save()
//        let postWithImage = TestDataBuilder.anyPostWithImage(author: user)
//        try postWithImage.save()
//        let post2 = TestDataBuilder.anyPost(author: user)
//        try post2.save()
//        let paginator = try BlogPost.makeQuery().paginate(for: authorRequest)
//        return (user, paginator)
//    }
//
//}
//
//class CapturingViewRenderer: ViewRenderer {
//
//    var shouldCache = false
//
//    private(set) var capturedContext: Node? = nil
//    private(set) var leafPath: String? = nil
//    func make(_ path: String, _ context: Node) throws -> View {
//        self.capturedContext = context
//        self.leafPath = path
//        return View(data: "Test".makeBytes())
//    }
//}

