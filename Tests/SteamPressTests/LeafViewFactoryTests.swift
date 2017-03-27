import XCTest
import Vapor
import URI
import Fluent
import HTTP
import Foundation
@testable import SteamPress

class LeafViewFactoryTests: XCTestCase {
    
    // MARK: - allTests
    
    static var allTests = [
        ("testParametersAreSetCorrectlyOnAllTagsPage", testParametersAreSetCorrectlyOnAllTagsPage),
        ("testTagsPageGetsPassedAllTagsWithBlogCount", testTagsPageGetsPassedAllTagsWithBlogCount),
        ("testTagsPageGetsPassedTagsSortedByPageCount", testTagsPageGetsPassedTagsSortedByPageCount),
        ("testTwitterHandleSetOnAllTagsPageIfGiven", testTwitterHandleSetOnAllTagsPageIfGiven),
        ("testLoggedInUserSetOnAllTagsPageIfPassedIn", testLoggedInUserSetOnAllTagsPageIfPassedIn),
        ("testNoTagsGivenIfEmptyArrayPassedToAllTagsPage", testNoTagsGivenIfEmptyArrayPassedToAllTagsPage),
        ("testParametersAreSetCorrectlyOnAllAuthorsPage", testParametersAreSetCorrectlyOnAllAuthorsPage),
        ("testAuthorsPageGetsPassedAllAuthorsWithBlogCount", testAuthorsPageGetsPassedAllAuthorsWithBlogCount),
        ("testAuthorsPageGetsPassedAuthorsSortedByPageCount", testAuthorsPageGetsPassedAuthorsSortedByPageCount),
        ("testTwitterHandleSetOnAllAuthorsPageIfProvided", testTwitterHandleSetOnAllAuthorsPageIfProvided),
        ("testNoLoggedInUserPassedToAllAuthorsPageIfNoneProvided", testNoLoggedInUserPassedToAllAuthorsPageIfNoneProvided),
        ("testNoAuthorsGivenToAuthorsPageIfNonePassedToAllAuthorsPage", testNoAuthorsGivenToAuthorsPageIfNonePassedToAllAuthorsPage),
        ("testTagPageGetsTagWithCorrectParamsAndPostCount", testTagPageGetsTagWithCorrectParamsAndPostCount),
        ("testNoLoggedInUserPassedToTagPageIfNoneProvided", testNoLoggedInUserPassedToTagPageIfNoneProvided),
        ("testDisqusNamePassedToTagPageIfSet", testDisqusNamePassedToTagPageIfSet),
        ("testTwitterHandlePassedToTagPageIfSet", testTwitterHandlePassedToTagPageIfSet),
        ("testBlogPageGetsImageUrlIfOneInPostMarkdown", testBlogPageGetsImageUrlIfOneInPostMarkdown),
        ("testDescriptionOnBlogPostPageIsShortSnippetTextCleaned", testDescriptionOnBlogPostPageIsShortSnippetTextCleaned),
        ("testBlogPostPageGetsCorrectParameters", testBlogPostPageGetsCorrectParameters),
        ("testUserPassedToBlogPostPageIfUserPassedIn", testUserPassedToBlogPostPageIfUserPassedIn),
        ("testDisqusNamePassedToBlogPostPageIfPassedIn", testDisqusNamePassedToBlogPostPageIfPassedIn),
        ("testTwitterHandlePassedToBlogPostPageIfPassedIn", testTwitterHandlePassedToBlogPostPageIfPassedIn),
        ("testBlogIndexPageGivenCorrectParameters", testBlogIndexPageGivenCorrectParameters),
        ("testNoPostsPassedIntoBlogIndexIfNoneAvailable", testNoPostsPassedIntoBlogIndexIfNoneAvailable),
        ("testNoAuthorsPassedIntoBlogIndexIfNoneCreated", testNoAuthorsPassedIntoBlogIndexIfNoneCreated),
        ("testNoTagsPassedIntoBlogIndexIfNoneCreted", testNoTagsPassedIntoBlogIndexIfNoneCreted),
        ("testUserPassedToBlogIndexIfUserPassedIn", testUserPassedToBlogIndexIfUserPassedIn),
        ("testDisqusNamePassedToBlogIndexIfPassedIn", testDisqusNamePassedToBlogIndexIfPassedIn),
        ("testTwitterHandlePassedToBlogIndexIfPassedIn", testTwitterHandlePassedToBlogIndexIfPassedIn),
        ("testAuthorViewHasCorrectParametersSet", testAuthorViewHasCorrectParametersSet),
        ("testAuthorViewMyProfileSetIfViewingMyProfile", testAuthorViewMyProfileSetIfViewingMyProfile),
        ("testAuthorViewHasNoPostsSetIfNoneCreated", testAuthorViewHasNoPostsSetIfNoneCreated),
        ("testAuthorViewGetsLoggedInUserIfProvider", testAuthorViewGetsLoggedInUserIfProvider),
        ("testAuthorViewGetsDisqusNameIfProvided", testAuthorViewGetsDisqusNameIfProvided),
        ("testAuthorViewGetsTwitterHandleIfProvided", testAuthorViewGetsTwitterHandleIfProvided),
        ("testPasswordViewGivenCorrectParameters", testPasswordViewGivenCorrectParameters),
        ("testPasswordViewHasCorrectParametersWhenError", testPasswordViewHasCorrectParametersWhenError),
        ("testLoginViewGetsCorrectParameters", testLoginViewGetsCorrectParameters),
        ("testLoginViewWhenErrored", testLoginViewWhenErrored),
        ("testLoginPageUsernamePasswordErrorsMarkedWhenNotSuppliedAndErrored", testLoginPageUsernamePasswordErrorsMarkedWhenNotSuppliedAndErrored),
        ("testBlogAdminViewGetsCorrectParameters", testBlogAdminViewGetsCorrectParameters),
        ("testNoPostsPassedToAdminViewIfNone", testNoPostsPassedToAdminViewIfNone),
        ("testAdminPageWithErrors", testAdminPageWithErrors),
        ("testCreateUserViewGetsCorrectParameters", testCreateUserViewGetsCorrectParameters),
        ("testCreateUserViewWhenErrors", testCreateUserViewWhenErrors),
        ("testCreateUserViewWhenNoNameOrUsernameSupplied", testCreateUserViewWhenNoNameOrUsernameSupplied),
        ("testCreateUserViewForEditing", testCreateUserViewForEditing),
        ("testCreateUserViewThrowsWhenTryingToEditWithoutUserId", testCreateUserViewThrowsWhenTryingToEditWithoutUserId),
        ("testCreateBlogPostViewGetsCorrectParameters", testCreateBlogPostViewGetsCorrectParameters),
        ("testCreateBlogPostViewWhenEditing", testCreateBlogPostViewWhenEditing),
        ("testEditBlogPostViewThrowsWithNoPostToEdit", testEditBlogPostViewThrowsWithNoPostToEdit),
        ("testCreateBlogPostViewWithErrorsAndNoTitleOrContentsSupplied", testCreateBlogPostViewWithErrorsAndNoTitleOrContentsSupplied),
        ("testDraftPassedThroughWhenEditingABlogPostThatHasNotBeenPublished", testDraftPassedThroughWhenEditingABlogPostThatHasNotBeenPublished)
        ]
    
    // MARK: - Properties
    private var viewFactory: LeafViewFactory!
    private var viewRenderer: CapturingViewRenderer!
    private let database = Database(MemoryDriver())
    
    private let tagsURI = URI(scheme: "https", host: "test.com", path: "tags/")
    private let authorsURI = URI(scheme: "https", host: "test.com", path: "authors/")
    private let tagURI = URI(scheme: "https", host: "test.com", path: "tags/tatooine/")
    private var tagRequest: Request!
    private let postURI = URI(scheme: "https", host: "test.com", path: "posts/test-post/")
    private let indexURI = URI(scheme: "https", host: "test.com", path: "/")
    private var indexRequest: Request!
    private let authorURI = URI(scheme: "https", host: "test.com", path: "authors/luke/")
    private let createPostURI = URI(scheme: "https", host: "test.com", path: "admin/createPost/")
    private let editPostURI = URI(scheme: "https", host: "test.com", path: "admin/posts/1/edit/")
    
    // MARK: - Overrides
    
    override func setUp() {
        viewRenderer = CapturingViewRenderer()
        viewFactory = LeafViewFactory(viewRenderer: viewRenderer)
        tagRequest = try! Request(method: .get, uri: tagURI)
        indexRequest = try! Request(method: .get, uri: indexURI)
        let printConsole = PrintConsole()
        let prepare = Prepare(console: printConsole, preparations: [BlogUser.self, BlogPost.self, BlogTag.self, Pivot<BlogPost, BlogTag>.self], database: database)
        do {
            try prepare.run(arguments: [])
        }
        catch {
            XCTFail("failed to prepapre DB")
        }
    }
    
    // MARK: - Tests
    
    func testParametersAreSetCorrectlyOnAllTagsPage() throws {
        let tags = [BlogTag(name: "tag1"), BlogTag(name: "tag2")]
        for var tag in tags {
            try tag.save()
        }
        _ = try viewFactory.allTagsView(uri: tagsURI, allTags: tags, user: nil, siteTwitterHandle: nil)
        
        XCTAssertEqual(viewRenderer.capturedContext?["tags"]?.array?.count, 2)
        XCTAssertEqual((viewRenderer.capturedContext?["tags"]?.array?.first as? Node)?["name"], "tag1")
        XCTAssertEqual((viewRenderer.capturedContext?["tags"]?.array?[1] as? Node)?["name"], "tag2")
        XCTAssertEqual(viewRenderer.capturedContext?["uri"]?.string, "https://test.com:443/tags/")
        XCTAssertNil(viewRenderer.capturedContext?["site_twitter_handle"]?.string)
        XCTAssertNil(viewRenderer.capturedContext?["user"])
        XCTAssertEqual(viewRenderer.leafPath, "blog/tags")
    }
    
    func testTagsPageGetsPassedAllTagsWithBlogCount() throws {
        var tag = BlogTag(name: "test tag")
        try tag.save()
        var post1 = TestDataBuilder.anyPost()
        try post1.save()
        try BlogTag.addTag(tag.name, to: post1)
        
        _ = try viewFactory.allTagsView(uri: tagsURI, allTags: [tag], user: nil, siteTwitterHandle: nil)
        XCTAssertEqual((viewRenderer.capturedContext?["tags"]?.array?.first as? Node)?["post_count"], 1)
    }
    
    func testTagsPageGetsPassedTagsSortedByPageCount() throws {
        var tag = BlogTag(name: "test tag")
        var tag2 = BlogTag(name: "tatooine")
        try tag.save()
        try tag2.save()
        var post1 = TestDataBuilder.anyPost()
        try post1.save()
        try BlogTag.addTag(tag.name, to: post1)
        var post2 = TestDataBuilder.anyPost()
        try post2.save()
        try BlogTag.addTag(tag2.name, to: post2)
        var post3 = TestDataBuilder.anyLongPost()
        try post3.save()
        try BlogTag.addTag(tag2.name, to: post3)
        
        _ = try viewFactory.allTagsView(uri: tagsURI, allTags: [tag, tag2], user: nil, siteTwitterHandle: nil)
        XCTAssertEqual(viewRenderer.capturedContext?["tags"]?.array?.count, 2)
        XCTAssertEqual((viewRenderer.capturedContext?["tags"]?.array?.first as? Node)?["name"], "tatooine")
    }
    
    func testTwitterHandleSetOnAllTagsPageIfGiven() throws {
        _ = try viewFactory.allTagsView(uri: tagsURI, allTags: [], user: nil, siteTwitterHandle: "brokenhandsio")
        XCTAssertEqual(viewRenderer.capturedContext?["site_twitter_handle"]?.string, "brokenhandsio")
    }
    
    func testLoggedInUserSetOnAllTagsPageIfPassedIn() throws {
        let user = TestDataBuilder.anyUser()
        _ = try viewFactory.allTagsView(uri: tagsURI, allTags: [], user: user, siteTwitterHandle: nil)
        XCTAssertEqual(viewRenderer.capturedContext?["user"]?["name"]?.string, "Luke")
    }
    
    func testNoTagsGivenIfEmptyArrayPassedToAllTagsPage() throws {
        _ = try viewFactory.allTagsView(uri: tagsURI, allTags: [], user: nil, siteTwitterHandle: nil)
        XCTAssertNil(viewRenderer.capturedContext?["tags"])
    }
    
    func testParametersAreSetCorrectlyOnAllAuthorsPage() throws {
        var user1 = TestDataBuilder.anyUser()
        try user1.save()
        var user2 = TestDataBuilder.anyUser(name: "Han", username: "han")
        try user2.save()
        let authors = [user1, user2]
        _ = try viewFactory.allAuthorsView(uri: authorsURI, allAuthors: authors, user: user1, siteTwitterHandle: nil)
        
        XCTAssertEqual(viewRenderer.capturedContext?["authors"]?.array?.count, 2)
        XCTAssertEqual((viewRenderer.capturedContext?["authors"]?.array?.first as? Node)?["name"], "Luke")
        XCTAssertEqual((viewRenderer.capturedContext?["authors"]?.array?[1] as? Node)?["name"], "Han")
        XCTAssertEqual(viewRenderer.capturedContext?["uri"]?.string, "https://test.com:443/authors/")
        XCTAssertNil(viewRenderer.capturedContext?["site_twitter_handle"]?.string)
        XCTAssertEqual(viewRenderer.capturedContext?["user"]?["name"]?.string, "Luke")
        XCTAssertEqual(viewRenderer.leafPath, "blog/authors")
    }
    
    func testAuthorsPageGetsPassedAllAuthorsWithBlogCount() throws {
        var user1 = TestDataBuilder.anyUser()
        try user1.save()
        var post1 = TestDataBuilder.anyPost(author: user1)
        try post1.save()
        _ = try viewFactory.allAuthorsView(uri: authorsURI, allAuthors: [user1], user: nil, siteTwitterHandle: nil)
        XCTAssertEqual((viewRenderer.capturedContext?["authors"]?.array?.first as? Node)?["post_count"], 1)
    }
    
    func testAuthorsPageGetsPassedAuthorsSortedByPageCount() throws {
        var user1 = TestDataBuilder.anyUser()
        try user1.save()
        var user2 = TestDataBuilder.anyUser(name: "Han", username: "han")
        try user2.save()
        var post1 = TestDataBuilder.anyPost(author: user1)
        try post1.save()
        var post2 = TestDataBuilder.anyPost(author: user2)
        try post2.save()
        var post3 = TestDataBuilder.anyPost(author: user2)
        try post3.save()
        _ = try viewFactory.allAuthorsView(uri: authorsURI, allAuthors: [user1, user2], user: nil, siteTwitterHandle: nil)
        XCTAssertEqual(viewRenderer.capturedContext?["authors"]?.array?.count, 2)
        XCTAssertEqual((viewRenderer.capturedContext?["authors"]?.array?.first as? Node)?["name"], "Han")
    }
    
    func testTwitterHandleSetOnAllAuthorsPageIfProvided() throws {
        _ = try viewFactory.allAuthorsView(uri: authorsURI, allAuthors: [], user: nil, siteTwitterHandle: "brokenhandsio")
        XCTAssertEqual(viewRenderer.capturedContext?["site_twitter_handle"]?.string, "brokenhandsio")
    }
    
    func testNoLoggedInUserPassedToAllAuthorsPageIfNoneProvided() throws {
        _ = try viewFactory.allAuthorsView(uri: authorsURI, allAuthors: [], user: nil, siteTwitterHandle: nil)
        XCTAssertNil(viewRenderer.capturedContext?["user"])
    }
    
    func testNoAuthorsGivenToAuthorsPageIfNonePassedToAllAuthorsPage() throws {
        _ = try viewFactory.allAuthorsView(uri: authorsURI, allAuthors: [], user: nil, siteTwitterHandle: nil)
        XCTAssertNil(viewRenderer.capturedContext?["authors"])
    }
    
    func testTagPageGetsTagWithCorrectParamsAndPostCount() throws {
        let testTag = try setupTagPage()
        _ = try viewFactory.tagView(uri: tagURI, tag: testTag, paginatedPosts: try testTag.blogPosts().paginator(5, request: tagRequest), user: TestDataBuilder.anyUser(name: "Luke"), disqusName: nil, siteTwitterHandle: nil)
        XCTAssertEqual((viewRenderer.capturedContext?["tag"])?["post_count"], 1)
        XCTAssertEqual((viewRenderer.capturedContext?["tag"])?["name"], "tatooine")
        XCTAssertEqual(viewRenderer.capturedContext?["posts"]?["data"]?.array?.count, 1)
        XCTAssertEqual((viewRenderer.capturedContext?["posts"]?["data"]?.array?.first as? Node)?["title"]?.string, TestDataBuilder.anyPost().title)
        XCTAssertEqual(viewRenderer.capturedContext?["uri"]?.string, "https://test.com:443/tags/tatooine/")
        XCTAssertEqual(viewRenderer.capturedContext?["tag_page"]?.bool, true)
        XCTAssertEqual(viewRenderer.capturedContext?["user"]?["name"]?.string, "Luke")
        XCTAssertNil(viewRenderer.capturedContext?["disqus_name"])
        XCTAssertNil(viewRenderer.capturedContext?["site_twitter_handle"])
        XCTAssertEqual(viewRenderer.leafPath, "blog/tag")
    }
    
    func testNoLoggedInUserPassedToTagPageIfNoneProvided() throws {
        let testTag = try setupTagPage()
        _ = try viewFactory.tagView(uri: tagURI, tag: testTag, paginatedPosts: try testTag.blogPosts().paginator(5, request: tagRequest), user: nil, disqusName: nil, siteTwitterHandle: nil)
        XCTAssertNil(viewRenderer.capturedContext?["user"])
    }
    
    func testDisqusNamePassedToTagPageIfSet() throws {
        let testTag = try setupTagPage()
        _ = try viewFactory.tagView(uri: tagURI, tag: testTag, paginatedPosts: try testTag.blogPosts().paginator(5, request: tagRequest), user: nil, disqusName: "brokenhands", siteTwitterHandle: nil)
        XCTAssertEqual(viewRenderer.capturedContext?["disqus_name"]?.string, "brokenhands")
    }
    
    func testTwitterHandlePassedToTagPageIfSet() throws {
        let testTag = try setupTagPage()
        _ = try viewFactory.tagView(uri: tagURI, tag: testTag, paginatedPosts: try testTag.blogPosts().paginator(5, request: tagRequest), user: nil, disqusName: nil, siteTwitterHandle: "brokenhandsio")
        XCTAssertEqual(viewRenderer.capturedContext?["site_twitter_handle"]?.string, "brokenhandsio")
    }
    
    func testBlogPageGetsImageUrlIfOneInPostMarkdown() throws {
       let (postWithImage, user) = try setupBlogPost()
        _ = try viewFactory.blogPostView(uri: postURI, post: postWithImage, author: user, user: nil, disqusName: nil, siteTwitterHandle: nil)
        
        XCTAssertNotNil((viewRenderer.capturedContext?["post_image"])?.string)
    }
    
    func testDescriptionOnBlogPostPageIsShortSnippetTextCleaned() throws {
        let (postWithImage, user) = try setupBlogPost()
        _ = try viewFactory.blogPostView(uri: postURI, post: postWithImage, author: user, user: nil, disqusName: nil, siteTwitterHandle: nil)
        
        let expectedDescription = "Welcome to SteamPress! SteamPress started out as an idea - after all, I was porting sites and backends over to Swift and would like to have a blog as well. Being early days for Server-Side Swift, and embracing Vapor, there wasn't anything available to put a blog on my site, so I did what any self-respecting engineer would do - I made one! Besides, what better way to learn a framework than build a blog!"
        
        XCTAssertEqual((viewRenderer.capturedContext?["post_description"])?.string?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines), expectedDescription)
    }
    
    func testBlogPostPageGetsCorrectParameters() throws {
        let (postWithImage, user) = try setupBlogPost()
        _ = try viewFactory.blogPostView(uri: postURI, post: postWithImage, author: user, user: nil, disqusName: nil, siteTwitterHandle: nil)
        
        XCTAssertEqual(viewRenderer.capturedContext?["post"]?["title"]?.string, postWithImage.title)
        XCTAssertEqual(viewRenderer.capturedContext?["author"]?["name"]?.string, user.name)
        XCTAssertTrue(((viewRenderer.capturedContext?["blog_post_page"])?.bool) ?? false)
        XCTAssertNil(viewRenderer.capturedContext?["user"])
        XCTAssertNil(viewRenderer.capturedContext?["disqus_name"])
        XCTAssertNil(viewRenderer.capturedContext?["site_twitter_handle"])
        XCTAssertNotNil((viewRenderer.capturedContext?["post_image"])?.string)
        XCTAssertEqual(viewRenderer.capturedContext?["post_uri"]?.string, postURI.description)
        XCTAssertEqual(viewRenderer.capturedContext?["site_uri"]?.string, "https://test.com:443")
        XCTAssertEqual(viewRenderer.capturedContext?["post_uri_encoded"]?.string, postURI.description)
        XCTAssertEqual(viewRenderer.leafPath, "blog/blogpost")
    }
    
    func testUserPassedToBlogPostPageIfUserPassedIn() throws {
        let (postWithImage, user) = try setupBlogPost()
        _ = try viewFactory.blogPostView(uri: postURI, post: postWithImage, author: user, user: user, disqusName: nil, siteTwitterHandle: nil)
        XCTAssertEqual(viewRenderer.capturedContext?["user"]?["name"]?.string, user.name)
    }
    
    func testDisqusNamePassedToBlogPostPageIfPassedIn() throws {
        let (postWithImage, user) = try setupBlogPost()
        _ = try viewFactory.blogPostView(uri: postURI, post: postWithImage, author: user, user: nil, disqusName: "brokenhands", siteTwitterHandle: nil)
        XCTAssertEqual(viewRenderer.capturedContext?["disqus_name"]?.string, "brokenhands")
    }
    
    func testTwitterHandlePassedToBlogPostPageIfPassedIn() throws {
        let (postWithImage, user) = try setupBlogPost()
        _ = try viewFactory.blogPostView(uri: postURI, post: postWithImage, author: user, user: nil, disqusName: nil, siteTwitterHandle: "brokenhandsio")
        XCTAssertEqual(viewRenderer.capturedContext?["site_twitter_handle"]?.string, "brokenhandsio")
    }
    
    func testBlogIndexPageGivenCorrectParameters() throws {
        let (posts, tags, authors) = try setupBlogIndex()
        _ = try viewFactory.blogIndexView(uri: indexURI, paginatedPosts: posts.paginator(5, request: indexRequest), tags: tags, authors: authors, loggedInUser: nil, disqusName: nil, siteTwitterHandle: nil)

        XCTAssertEqual(viewRenderer.capturedContext?["uri"]?.string, indexURI.description)
        XCTAssertTrue((viewRenderer.capturedContext?["blog_index_page"]?.bool) ?? false)
        
        XCTAssertEqual(viewRenderer.capturedContext?["posts"]?["data"]?.array?.count, posts.count)
        XCTAssertEqual((viewRenderer.capturedContext?["posts"]?["data"]?.array?.first as? Node)?["title"]?.string, posts.first?.title)
        XCTAssertEqual(viewRenderer.capturedContext?["tags"]?.array?.count, tags.count)
        XCTAssertEqual((viewRenderer.capturedContext?["tags"]?.array?.first as? Node)?["name"]?.string, tags.first?.name)
        XCTAssertEqual(viewRenderer.capturedContext?["authors"]?.array?.count, authors.count)
        XCTAssertEqual((viewRenderer.capturedContext?["authors"]?.array?.first as? Node)?["name"]?.string, authors.first?.name)
        XCTAssertEqual(viewRenderer.leafPath, "blog/blog")
    }
    
    func testNoPostsPassedIntoBlogIndexIfNoneAvailable() throws {
        let (_, tags, authors) = try setupBlogIndex()
        let emptyBlogPosts: [BlogPost] = []
        _ = try viewFactory.blogIndexView(uri: indexURI, paginatedPosts: emptyBlogPosts.paginator(5, request: indexRequest), tags: tags, authors: authors, loggedInUser: nil, disqusName: nil, siteTwitterHandle: nil)
        XCTAssertNil(viewRenderer.capturedContext?["posts"])
    }
    
    func testNoAuthorsPassedIntoBlogIndexIfNoneCreated() throws {
        let (posts, _, authors) = try setupBlogIndex()
        _ = try viewFactory.blogIndexView(uri: indexURI, paginatedPosts: posts.paginator(5, request: indexRequest), tags: [], authors: authors, loggedInUser: nil, disqusName: nil, siteTwitterHandle: nil)
        XCTAssertNil(viewRenderer.capturedContext?["tags"])
    }
    
    func testNoTagsPassedIntoBlogIndexIfNoneCreted() throws {
        let (posts, tags, _) = try setupBlogIndex()
        _ = try viewFactory.blogIndexView(uri: indexURI, paginatedPosts: posts.paginator(5, request: indexRequest), tags: tags, authors: [], loggedInUser: nil, disqusName: nil, siteTwitterHandle: nil)
        XCTAssertNil(viewRenderer.capturedContext?["authors"])
    }
    
    func testUserPassedToBlogIndexIfUserPassedIn() throws {
        let (posts, tags, authors) = try setupBlogIndex()
        _ = try viewFactory.blogIndexView(uri: indexURI, paginatedPosts: posts.paginator(5, request: indexRequest), tags: tags, authors: authors, loggedInUser: authors[0], disqusName: nil, siteTwitterHandle: nil)
        XCTAssertEqual(viewRenderer.capturedContext?["user"]?["name"]?.string, authors.first?.name)
    }
    
    func testDisqusNamePassedToBlogIndexIfPassedIn() throws {
        let (posts, tags, authors) = try setupBlogIndex()
        _ = try viewFactory.blogIndexView(uri: indexURI, paginatedPosts: posts.paginator(5, request: indexRequest), tags: tags, authors: authors, loggedInUser: nil, disqusName: "brokenhands", siteTwitterHandle: nil)
        XCTAssertEqual(viewRenderer.capturedContext?["disqus_name"]?.string, "brokenhands")
    }
    
    func testTwitterHandlePassedToBlogIndexIfPassedIn() throws {
        let (posts, tags, authors) = try setupBlogIndex()
        _ = try viewFactory.blogIndexView(uri: indexURI, paginatedPosts: posts.paginator(5, request: indexRequest), tags: tags, authors: authors, loggedInUser: nil, disqusName: nil, siteTwitterHandle: "brokenhandsio")
        XCTAssertEqual(viewRenderer.capturedContext?["site_twitter_handle"]?.string, "brokenhandsio")
    }
    
    func testAuthorViewHasCorrectParametersSet() throws {
        let (author, posts) = try setupAuthorPage()
        let _ = try viewFactory.createProfileView(uri: authorURI, author: author, isMyProfile: false, posts: posts, loggedInUser: nil, disqusName: nil, siteTwitterHandle: nil)
        
        XCTAssertEqual(viewRenderer.capturedContext?["author"]?["name"]?.string, author.name)
        XCTAssertEqual(viewRenderer.capturedContext?["posts"]?.array?.count, posts.count)
        XCTAssertEqual((viewRenderer.capturedContext?["posts"]?.array?.first as? Node)?["title"]?.string, posts.first?.title)
        XCTAssertEqual(viewRenderer.capturedContext?["uri"]?.string, authorURI.description)
        XCTAssertTrue((viewRenderer.capturedContext?["profile_page"]?.bool) ?? false)
        XCTAssertNil(viewRenderer.capturedContext?["my_profile"])
        XCTAssertNil(viewRenderer.capturedContext?["user"])
        XCTAssertNil(viewRenderer.capturedContext?["disqus_name"])
        XCTAssertNil(viewRenderer.capturedContext?["site_twitter_handle"])
        XCTAssertEqual(viewRenderer.capturedContext?["author"]?["tagline"]?.string, author.tagline)
        XCTAssertEqual(viewRenderer.capturedContext?["author"]?["twitter_handle"]?.string, author.twitterHandle)
        XCTAssertEqual(viewRenderer.capturedContext?["author"]?["biography"]?.string, author.biography)
        XCTAssertEqual(viewRenderer.capturedContext?["author"]?["profile_picture"]?.string, author.profilePicture?.description)
        XCTAssertEqual(viewRenderer.leafPath, "blog/profile")
    }
    
    func testAuthorViewMyProfileSetIfViewingMyProfile() throws {
        let (author, posts) = try setupAuthorPage()
        let _ = try viewFactory.createProfileView(uri: authorURI, author: author, isMyProfile: true, posts: posts, loggedInUser: nil, disqusName: nil, siteTwitterHandle: nil)
        XCTAssertTrue((viewRenderer.capturedContext?["my_profile"]?.bool) ?? false)
        XCTAssertNil(viewRenderer.capturedContext?["profile_page"])
    }
    
    func testAuthorViewHasNoPostsSetIfNoneCreated() throws {
        let (author, _) = try setupAuthorPage()
        let _ = try viewFactory.createProfileView(uri: authorURI, author: author, isMyProfile: true, posts: [], loggedInUser: nil, disqusName: nil, siteTwitterHandle: nil)
        XCTAssertNil(viewRenderer.capturedContext?["posts"])
    }
    
    func testAuthorViewGetsLoggedInUserIfProvider() throws {
        let (author, posts) = try setupAuthorPage()
        let _ = try viewFactory.createProfileView(uri: authorURI, author: author, isMyProfile: true, posts: posts, loggedInUser: author, disqusName: nil, siteTwitterHandle: nil)
        XCTAssertEqual(viewRenderer.capturedContext?["user"]?["name"]?.string, author.name)
    }
    
    func testAuthorViewGetsDisqusNameIfProvided() throws {
        let (author, posts) = try setupAuthorPage()
        let _ = try viewFactory.createProfileView(uri: authorURI, author: author, isMyProfile: true, posts: posts, loggedInUser: nil, disqusName: "brokenhands", siteTwitterHandle: nil)
        XCTAssertEqual(viewRenderer.capturedContext?["disqus_name"]?.string, "brokenhands")
    }
    
    func testAuthorViewGetsTwitterHandleIfProvided() throws {
        let (author, posts) = try setupAuthorPage()
        let _ = try viewFactory.createProfileView(uri: authorURI, author: author, isMyProfile: true, posts: posts, loggedInUser: nil, disqusName: nil, siteTwitterHandle: "brokenhandsio")
        XCTAssertEqual(viewRenderer.capturedContext?["site_twitter_handle"]?.string, "brokenhandsio")
    }
    
    func testPasswordViewGivenCorrectParameters() throws {
        let _ = try viewFactory.createResetPasswordView(errors: nil, passwordError: nil, confirmPasswordError: nil)
        XCTAssertNil(viewRenderer.capturedContext?["errors"])
        XCTAssertNil(viewRenderer.capturedContext?["password_error"])
        XCTAssertNil(viewRenderer.capturedContext?["confirm_password_error"])
        XCTAssertEqual(viewRenderer.leafPath, "blog/admin/resetPassword")
    }
    
    func testPasswordViewHasCorrectParametersWhenError() throws {
        let expectedError = "Passwords do not match"
        let _ = try viewFactory.createResetPasswordView(errors: [expectedError], passwordError: true, confirmPasswordError: true)
        XCTAssertEqual(viewRenderer.capturedContext?["errors"]?.array?.count, 1)
        XCTAssertEqual((viewRenderer.capturedContext?["errors"]?.array?.first as? Node)?.string, expectedError)
        XCTAssertTrue((viewRenderer.capturedContext?["password_error"]?.bool) ?? false)
        XCTAssertTrue((viewRenderer.capturedContext?["confirm_password_error"]?.bool) ?? false)
    }
    
    func testLoginViewGetsCorrectParameters() throws {
        let _ = try viewFactory.createLoginView(loginWarning: false, errors: nil, username: nil, password: nil)
        XCTAssertFalse((viewRenderer.capturedContext?["username_error"]?.bool) ?? true)
        XCTAssertFalse((viewRenderer.capturedContext?["password_error"]?.bool) ?? true)
        XCTAssertNil(viewRenderer.capturedContext?["username_supplied"])
        XCTAssertNil(viewRenderer.capturedContext?["errors"])
        XCTAssertNil(viewRenderer.capturedContext?["login_warning"])
        XCTAssertEqual(viewRenderer.leafPath, "blog/admin/login")
    }
    
    func testLoginViewWhenErrored() throws {
        let expectedError = "Username/password incorrect"
        let _ = try viewFactory.createLoginView(loginWarning: true, errors: [expectedError], username: "tim", password: "password")
        XCTAssertFalse((viewRenderer.capturedContext?["username_error"]?.bool) ?? true)
        XCTAssertFalse((viewRenderer.capturedContext?["password_error"]?.bool) ?? true)
        XCTAssertEqual(viewRenderer.capturedContext?["username_supplied"]?.string, "tim")
        XCTAssertTrue((viewRenderer.capturedContext?["login_warning"]?.bool) ?? false)
        XCTAssertEqual(viewRenderer.capturedContext?["errors"]?.nodeArray?.first?.string, expectedError)
    }
    
    func testLoginPageUsernamePasswordErrorsMarkedWhenNotSuppliedAndErrored() throws {
        let expectedError = "Username/password incorrect"
        let _ = try viewFactory.createLoginView(loginWarning: true, errors: [expectedError], username: nil, password: nil)
        XCTAssertTrue((viewRenderer.capturedContext?["username_error"]?.bool) ?? false)
        XCTAssertTrue((viewRenderer.capturedContext?["password_error"]?.bool) ?? false)
    }
    
    func testBlogAdminViewGetsCorrectParameters() throws {
        // Add some stuff to the database
        let (posts, _, users) = try setupBlogIndex()
        var draftPost = TestDataBuilder.anyPost(title: "[DRAFT] This will be awesome", author: users.first!, published: false)
        try draftPost.save()
        let _ = try viewFactory.createBlogAdminView()
        XCTAssertNil(viewRenderer.capturedContext?["errors"])
        XCTAssertTrue((viewRenderer.capturedContext?["blog_admin_page"]?.bool) ?? false)
        XCTAssertEqual(viewRenderer.capturedContext?["users"]?.nodeArray?.count, 2)
        XCTAssertEqual(viewRenderer.capturedContext?["users"]?.nodeArray?.first?["name"]?.string, users.first?.name)
        XCTAssertEqual(viewRenderer.capturedContext?["published_posts"]?.nodeArray?.count, 2)
        XCTAssertEqual(viewRenderer.capturedContext?["published_posts"]?.nodeArray?.first?["title"]?.string, posts[1].title)
        XCTAssertEqual(viewRenderer.capturedContext?["draft_posts"]?.nodeArray?.count, 1)
        XCTAssertEqual(viewRenderer.capturedContext?["draft_posts"]?.nodeArray?.first?["title"]?.string, draftPost.title)
        XCTAssertEqual(viewRenderer.leafPath, "blog/admin/index")
    }
    
    func testNoPostsPassedToAdminViewIfNone() throws {
        let _ = try viewFactory.createBlogAdminView()
        XCTAssertNil(viewRenderer.capturedContext?["posts"])
    }
    
    func testAdminPageWithErrors() throws {
        let expectedError = "You cannot delete yourself!"
        let _ = try viewFactory.createBlogAdminView(errors: [expectedError])
        XCTAssertEqual(viewRenderer.capturedContext?["errors"]?.nodeArray?.first?.string, expectedError)
    }
    
    func testCreateUserViewGetsCorrectParameters() throws {
        let _ = try viewFactory.createUserView()
        XCTAssertFalse((viewRenderer.capturedContext?["name_error"]?.bool) ?? true)
        XCTAssertFalse((viewRenderer.capturedContext?["username_error"]?.bool) ?? true)
        XCTAssertNil(viewRenderer.capturedContext?["errors"])
        XCTAssertNil(viewRenderer.capturedContext?["name_supplied"])
        XCTAssertNil(viewRenderer.capturedContext?["username_supplied"])
        XCTAssertNil(viewRenderer.capturedContext?["password_error"])
        XCTAssertNil(viewRenderer.capturedContext?["confirm_password_error"])
        XCTAssertNil(viewRenderer.capturedContext?["reset_password_on_login_supplied"])
        XCTAssertNil(viewRenderer.capturedContext?["editing"])
        XCTAssertNil(viewRenderer.capturedContext?["user_id"])
        XCTAssertNil(viewRenderer.capturedContext?["twitter_handle_supplied"])
        XCTAssertNil(viewRenderer.capturedContext?["profile_picture_supplied"])
        XCTAssertNil(viewRenderer.capturedContext?["biography_supplied"])
        XCTAssertNil(viewRenderer.capturedContext?["tagline_supplied"])
        XCTAssertEqual(viewRenderer.leafPath, "blog/admin/createUser")
    }
    
    func testCreateUserViewWhenErrors() throws {
        let expectedError = "Not valid password"
        let _ = try viewFactory.createUserView(errors: [expectedError], name: "Luke", username: "luke", passwordError: true, confirmPasswordError: true, resetPasswordRequired: true, profilePicture: URL(string: "https://static.brokenhands.io/steampress/images/authors/luke.png"), twitterHandle: "luke", biography: "The last Jedi in the Galaxy", tagline: "A son without a father")
        XCTAssertFalse((viewRenderer.capturedContext?["name_error"]?.bool) ?? true)
        XCTAssertFalse((viewRenderer.capturedContext?["username_error"]?.bool) ?? true)
        XCTAssertEqual(viewRenderer.capturedContext?["errors"]?.nodeArray?.first?.string, expectedError)
        XCTAssertEqual(viewRenderer.capturedContext?["name_supplied"]?.string, "Luke")
        XCTAssertEqual(viewRenderer.capturedContext?["username_supplied"]?.string, "luke")
        XCTAssertTrue((viewRenderer.capturedContext?["password_error"]?.bool) ?? false)
        XCTAssertTrue((viewRenderer.capturedContext?["confirm_password_error"]?.bool) ?? false)
        XCTAssertTrue((viewRenderer.capturedContext?["reset_password_on_login_supplied"]?.bool) ?? false)
        XCTAssertEqual(viewRenderer.capturedContext?["profile_picture_supplied"]?.string, "https://static.brokenhands.io/steampress/images/authors/luke.png")
        XCTAssertEqual(viewRenderer.capturedContext?["twitter_handle_supplied"]?.string, "luke")
        XCTAssertEqual(viewRenderer.capturedContext?["tagline_supplied"]?.string, "A son without a father")
        XCTAssertEqual(viewRenderer.capturedContext?["biography_supplied"]?.string, "The last Jedi in the Galaxy")
    }
    
    func testCreateUserViewWhenNoNameOrUsernameSupplied() throws {
        let expectedError = "No name supplied"
        let _ = try viewFactory.createUserView(errors: [expectedError], name: nil, username: nil, passwordError: true, confirmPasswordError: true, resetPasswordRequired: true)
        XCTAssertTrue((viewRenderer.capturedContext?["name_error"]?.bool) ?? false)
        XCTAssertTrue((viewRenderer.capturedContext?["username_error"]?.bool) ?? false)
    }
    
    func testCreateUserViewForEditing() throws {
        let _ = try viewFactory.createUserView(editing: true, errors: nil, name: "Luke", username: "luke", userId: 1.makeNode(), profilePicture: URL(string: "https://static.brokenhands.io/steampress/images/authors/luke.png"), twitterHandle: "luke", biography: "The last Jedi in the Galaxy", tagline: "A son without a father")
        XCTAssertEqual(viewRenderer.capturedContext?["name_supplied"]?.string, "Luke")
        XCTAssertEqual(viewRenderer.capturedContext?["username_supplied"]?.string, "luke")
        XCTAssertTrue((viewRenderer.capturedContext?["editing"]?.bool) ?? false)
        XCTAssertEqual(viewRenderer.capturedContext?["user_id"], try 1.makeNode())
        XCTAssertEqual(viewRenderer.capturedContext?["profile_picture_supplied"]?.string, "https://static.brokenhands.io/steampress/images/authors/luke.png")
        XCTAssertEqual(viewRenderer.capturedContext?["twitter_handle_supplied"]?.string, "luke")
        XCTAssertEqual(viewRenderer.capturedContext?["tagline_supplied"]?.string, "A son without a father")
        XCTAssertEqual(viewRenderer.capturedContext?["biography_supplied"]?.string, "The last Jedi in the Galaxy")
        XCTAssertEqual(viewRenderer.leafPath, "blog/admin/createUser")
    }
    
    func testCreateUserViewThrowsWhenTryingToEditWithoutUserId() throws {
        var errored = false
        do {
            let _ = try viewFactory.createUserView(editing: true, errors: nil, name: "Luke", username: "luke", userId: nil)
        } catch {
            errored = true
        }
        
        XCTAssertTrue(errored)
    }
    
    func testCreateBlogPostViewGetsCorrectParameters() throws {
        let _ = try viewFactory.createBlogPostView(uri: createPostURI)
        XCTAssertEqual(viewRenderer.capturedContext?["post_path_prefix"]?.string, "https://test.com:443/posts/")
        XCTAssertFalse((viewRenderer.capturedContext?["title_error"]?.bool) ?? true)
        XCTAssertFalse((viewRenderer.capturedContext?["contents_error"]?.bool) ?? true)
        XCTAssertNil(viewRenderer.capturedContext?["errors"])
        XCTAssertNil(viewRenderer.capturedContext?["title_supplied"])
        XCTAssertNil(viewRenderer.capturedContext?["contents_supplied"])
        XCTAssertNil(viewRenderer.capturedContext?["slug_url_supplied"])
        XCTAssertNil(viewRenderer.capturedContext?["tags_supplied"])
        XCTAssertEqual(viewRenderer.leafPath, "blog/admin/createPost")
        XCTAssertTrue((viewRenderer.capturedContext?["create_blog_post_page"]?.bool) ?? false)
        XCTAssertTrue((viewRenderer.capturedContext?["draft"]?.bool) ?? false)
        XCTAssertNil(viewRenderer.capturedContext?["editing"])
    }
    
    func testCreateBlogPostViewWhenEditing() throws {
        let postToEdit = TestDataBuilder.anyPost()
        let _ = try viewFactory.createBlogPostView(uri: editPostURI, title: postToEdit.title, contents: postToEdit.contents, slugUrl: postToEdit.slugUrl, tags: ["test".makeNode()], isEditing: true, postToEdit: postToEdit)
        XCTAssertEqual(viewRenderer.capturedContext?["post_path_prefix"]?.string, "https://test.com:443/posts/")
        XCTAssertFalse((viewRenderer.capturedContext?["title_error"]?.bool) ?? true)
        XCTAssertFalse((viewRenderer.capturedContext?["contents_error"]?.bool) ?? true)
        XCTAssertNil(viewRenderer.capturedContext?["errors"])
        XCTAssertEqual(viewRenderer.capturedContext?["title_supplied"]?.string, postToEdit.title)
        XCTAssertEqual(viewRenderer.capturedContext?["contents_supplied"]?.string, postToEdit.contents)
        XCTAssertEqual(viewRenderer.capturedContext?["slug_url_supplied"]?.string, postToEdit.slugUrl)
        XCTAssertEqual(viewRenderer.capturedContext?["tags_supplied"]?.array?.count, 1)
        XCTAssertEqual(viewRenderer.capturedContext?["tags_supplied"]?.nodeArray?.first?.string, "test")
        XCTAssertTrue((viewRenderer.capturedContext?["editing"]?.bool) ?? false)
        XCTAssertEqual(viewRenderer.capturedContext?["post"]?["title"]?.string, postToEdit.title)
        XCTAssertNil(viewRenderer.capturedContext?["create_blog_post_page"])
        XCTAssertEqual(viewRenderer.capturedContext?["post"]?["published"]?.bool, true)
    }
    
    func testEditBlogPostViewThrowsWithNoPostToEdit() throws {
        var errored = false
        do {
            let _ = try viewFactory.createBlogPostView(uri: createPostURI, isEditing: true, postToEdit: nil)
        } catch {
            errored = true
        }
        
        XCTAssertTrue(errored)
    }
    
    func testCreateBlogPostViewWithErrorsAndNoTitleOrContentsSupplied() throws {
        let expectedError = "Please enter a title"
        let _ = try viewFactory.createBlogPostView(uri: createPostURI, errors: [expectedError], title: nil, contents: nil, slugUrl: nil, tags: nil, isEditing: false)
        XCTAssertTrue((viewRenderer.capturedContext?["title_error"]?.bool) ?? false)
        XCTAssertTrue((viewRenderer.capturedContext?["contents_error"]?.bool) ?? false)
        XCTAssertEqual(viewRenderer.capturedContext?["errors"]?.nodeArray?.count, 1)
        XCTAssertEqual(viewRenderer.capturedContext?["errors"]?.nodeArray?.first?.string, expectedError)
    }
    
    func testDraftPassedThroughWhenEditingABlogPostThatHasNotBeenPublished() throws {
        let postToEdit = TestDataBuilder.anyPost(published: false)
        let _ = try viewFactory.createBlogPostView(uri: editPostURI, title: postToEdit.title, contents: postToEdit.contents, slugUrl: postToEdit.slugUrl, tags: ["test".makeNode()], isEditing: true, postToEdit: postToEdit)
        XCTAssertEqual(viewRenderer.capturedContext?["post"]?["published"]?.bool, false)
    }

    
    // MARK: - Helpers
    
    private func setupBlogIndex() throws -> ([BlogPost], [BlogTag], [BlogUser]) {
        var user1 = TestDataBuilder.anyUser()
        try user1.save()
        var user2 = TestDataBuilder.anyUser(name: "Han")
        try user2.save()
        var post1 = TestDataBuilder.anyPost(author: user1)
        try post1.save()
        var post2 = TestDataBuilder.anyPostWithImage(author: user2)
        try post2.save()
        var tag = BlogTag(name: "tatooine")
        try tag.save()
        try BlogTag.addTag(tag.name, to: post1)
        return ([post1, post2], [tag], [user1, user2])
    }
    
    private func setupBlogPost() throws -> (BlogPost, BlogUser) {
        var user = TestDataBuilder.anyUser()
        try user.save()
        var postWithImage = TestDataBuilder.anyPostWithImage(author: user)
        try postWithImage.save()
        return (postWithImage, user)
    }
    
    private func setupTagPage() throws -> BlogTag {
        var tag = BlogTag(name: "tatooine")
        try tag.save()
        var user = TestDataBuilder.anyUser()
        try user.save()
        var post1 = TestDataBuilder.anyPost(author: user)
        try post1.save()
        try BlogTag.addTag(tag.name, to: post1)
        return tag
    }
    
    private func setupAuthorPage() throws -> (BlogUser, [BlogPost]) {
        var user = TestDataBuilder.anyUser()
        try user.save()
        var postWithImage = TestDataBuilder.anyPostWithImage(author: user)
        try postWithImage.save()
        var post2 = TestDataBuilder.anyPost(author: user)
        try post2.save()
        return (user, [postWithImage, post2])
    }
    
}

class CapturingViewRenderer: ViewRenderer {
    required init(viewsDir: String = "tests") {}
    
    private(set) var capturedContext: Node? = nil
    private(set) var leafPath: String? = nil
    func make(_ path: String, _ context: Node) throws -> View {
        self.capturedContext = context
        self.leafPath = path
        return View(data: try "Test".makeBytes())
    }
}
