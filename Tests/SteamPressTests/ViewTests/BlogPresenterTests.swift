@testable import SteamPress
import XCTest
import Vapor

class BlogPresenterTests: XCTestCase {

    // MARK: - Properties
    var basicContainer: BasicContainer!
    var presenter: ViewBlogPresenter!
    var viewRenderer: CapturingViewRenderer!
    var testTag: BlogTag!

    private let allTagsURL = URL(string: "https://brokenhands.io/tags")!
    private let allAuthorsURL = URL(string: "https://brokenhands.io/authors")!
    private let tagURL = URL(string: "https://brokenhands.io/tags/tattoine")!
    private let blogIndexURL = URL(string: "https://brokenhands.io/blog")!
    private let authorURL = URL(string: "https://brokenhands.io/authors/luke")!
    private let loginURL = URL(string: "https://brokenhands.io/admin/login")!
    private let websiteURL = URL(string: "https://brokenhands.io")!
    private let searchURL = URL(string: "https://brokenhands.io/search?term=vapor")!

    private static let siteTwitterHandle = "brokenhandsio"
    private static let disqusName = "steampress"
    private static let googleAnalyticsIdentifier = "UA-12345678-1"

    // MARK: - Overrides

    override func setUp() {
        presenter = ViewBlogPresenter()
        basicContainer = BasicContainer(config: Config.default(), environment: Environment.testing, services: .init(), on: EmbeddedEventLoop())
        basicContainer.services.register(ViewRenderer.self) { _ in
            return self.viewRenderer
        }
        basicContainer.services.register(LongPostDateFormatter.self)
        basicContainer.services.register(NumericPostDateFormatter.self)
        viewRenderer = CapturingViewRenderer(worker: basicContainer)
        testTag = try! BlogTag(name: "Tattoine")
    }
    
    override func tearDown() {
        try! basicContainer.syncShutdownGracefully()
    }

    // MARK: - Tests

    // MARK: - All Tags Page

    func testParametersAreSetCorrectlyOnAllTagsPage() throws {
        let tags = try [BlogTag(id: 0, name: "tag1"), BlogTag(id: 1, name: "tag2")]

        let pageInformation = buildPageInformation(currentPageURL: allTagsURL)
        _ = presenter.allTagsView(on: basicContainer, tags: tags, tagPostCounts: [:], pageInformation: pageInformation)

        let context = try XCTUnwrap(viewRenderer.capturedContext as? AllTagsPageContext)

        XCTAssertEqual(context.tags.count, 2)
        XCTAssertEqual(context.tags.first?.name, "tag1")
        XCTAssertEqual(context.tags[1].name, "tag2")
        XCTAssertEqual(context.title, "All Tags")
        XCTAssertEqual(context.pageInformation.currentPageURL.absoluteString, "https://brokenhands.io/tags")
        XCTAssertEqual(context.pageInformation.siteTwitterHandle, BlogPresenterTests.siteTwitterHandle)
        XCTAssertEqual(context.pageInformation.disqusName, BlogPresenterTests.disqusName)
        XCTAssertEqual(context.pageInformation.googleAnalyticsIdentifier, BlogPresenterTests.googleAnalyticsIdentifier)
        XCTAssertNil(context.pageInformation.loggedInUser)
        XCTAssertEqual(viewRenderer.templatePath, "blog/tags")
    }

    func testTagsPageGetsPassedTagsSortedByPostCount() throws {
        let tag1 = try BlogTag(id: 0, name: "Engineering")
        let tag2 = try BlogTag(id: 1, name: "Tech")
        let tags = [tag1, tag2]
        let tagPostCount = [0: 5, 1: 20]
        let pageInformation = buildPageInformation(currentPageURL: allTagsURL)
        _ = presenter.allTagsView(on: basicContainer, tags: tags, tagPostCounts: tagPostCount, pageInformation: pageInformation)

        let context = try XCTUnwrap(viewRenderer.capturedContext as? AllTagsPageContext)
        XCTAssertEqual(context.tags.first?.postCount, 20)
        XCTAssertEqual(context.tags.first?.tagID, 1)
        XCTAssertEqual(context.tags[1].tagID, 0)
        XCTAssertEqual(context.tags[1].postCount, 5)
    }

    func testTagsPageHandlesNoPostsForTagsCorrectly() throws {
        let tag1 = try BlogTag(id: 0, name: "Engineering")
        let tag2 = try BlogTag(id: 1, name: "Tech")
        let tags = [tag1, tag2]
        let tagPostCount = [0: 0, 1: 20]
        let pageInformation = buildPageInformation(currentPageURL: allTagsURL)
        _ = presenter.allTagsView(on: basicContainer, tags: tags, tagPostCounts: tagPostCount, pageInformation: pageInformation)

        let context = try XCTUnwrap(viewRenderer.capturedContext as? AllTagsPageContext)
        XCTAssertEqual(context.tags[1].tagID, 0)
        XCTAssertEqual(context.tags[1].postCount, 0)
    }

    func testTwitterHandleNotSetOnAllTagsPageIfNotGiven() throws {
        let tags = try [BlogTag(id: 0, name: "tag1"), BlogTag(id: 1, name: "tag2")]
        let pageInformation = buildPageInformation(currentPageURL: allTagsURL, siteTwitterHandle: nil)
        _ = presenter.allTagsView(on: basicContainer, tags: tags, tagPostCounts: [:], pageInformation: pageInformation)

        let context = try XCTUnwrap(viewRenderer.capturedContext as? AllTagsPageContext)
        XCTAssertNil(context.pageInformation.siteTwitterHandle)
    }

    func testDisqusNameNotSetOnAllTagsPageIfNotGiven() throws {
        let tags = try [BlogTag(id: 0, name: "tag1"), BlogTag(id: 1, name: "tag2")]
        let pageInformation = buildPageInformation(currentPageURL: allTagsURL, disqusName: nil)
        _ = presenter.allTagsView(on: basicContainer, tags: tags, tagPostCounts: [:], pageInformation: pageInformation)

        let context = try XCTUnwrap(viewRenderer.capturedContext as? AllTagsPageContext)
        XCTAssertNil(context.pageInformation.disqusName)
    }

    func testGAIdentifierNotSetOnAllTagsPageIfNotGiven() throws {
        let tags = try [BlogTag(id: 0, name: "tag1"), BlogTag(id: 1, name: "tag2")]
        let pageInformation = buildPageInformation(currentPageURL: allTagsURL, googleAnalyticsIdentifier: nil)
        _ = presenter.allTagsView(on: basicContainer, tags: tags, tagPostCounts: [:], pageInformation: pageInformation)

        let context = try XCTUnwrap(viewRenderer.capturedContext as? AllTagsPageContext)
        XCTAssertNil(context.pageInformation.googleAnalyticsIdentifier)
    }

    func testLoggedInUserSetOnAllTagsPageIfPassedIn() throws {
        let tags = try [BlogTag(id: 0, name: "tag1"), BlogTag(id: 1, name: "tag2")]
        let user = TestDataBuilder.anyUser()
        let pageInformation = buildPageInformation(currentPageURL: allTagsURL, user: user)
        _ = presenter.allTagsView(on: basicContainer, tags: tags, tagPostCounts: [:], pageInformation: pageInformation)

        let context = try XCTUnwrap(viewRenderer.capturedContext as? AllTagsPageContext)
        XCTAssertEqual(context.pageInformation.loggedInUser?.name, user.name)
        XCTAssertEqual(context.pageInformation.loggedInUser?.username, user.username)
    }

    // MARK: - All authors

    func testParametersAreSetCorrectlyOnAllAuthorsPage() throws {
        let user1 = TestDataBuilder.anyUser(id: 0)
        let user2 = TestDataBuilder.anyUser(id: 1, name: "Han", username: "han")
        let authors = [user1, user2]
        let pageInformation = buildPageInformation(currentPageURL: allAuthorsURL)
        _ = presenter.allAuthorsView(on: basicContainer, authors: authors, authorPostCounts: [:], pageInformation: pageInformation)

        let context = try XCTUnwrap(viewRenderer.capturedContext as? AllAuthorsPageContext)
        XCTAssertEqual(context.authors.count, 2)
        XCTAssertEqual(context.authors.first?.name, "Luke")
        XCTAssertEqual(context.authors[1].name, "Han")
        XCTAssertEqual(context.pageInformation.currentPageURL.absoluteString, "https://brokenhands.io/authors")
        XCTAssertEqual(context.pageInformation.siteTwitterHandle, BlogPresenterTests.siteTwitterHandle)
        XCTAssertEqual(context.pageInformation.disqusName, BlogPresenterTests.disqusName)
        XCTAssertEqual(context.pageInformation.googleAnalyticsIdentifier, BlogPresenterTests.googleAnalyticsIdentifier)
        XCTAssertNil(context.pageInformation.loggedInUser)
        XCTAssertEqual(viewRenderer.templatePath, "blog/authors")
    }

    func testAuthorsPageGetsPassedAuthorsSortedByPostCount() throws {
        let user1 = TestDataBuilder.anyUser(id: 0)
        let user2 = TestDataBuilder.anyUser(id: 1, name: "Han", username: "han")
        let authors = [user1, user2]
        let authorPostCount = [0: 1, 1: 20]
        let pageInformation = buildPageInformation(currentPageURL: allAuthorsURL)
        _ = presenter.allAuthorsView(on: basicContainer, authors: authors, authorPostCounts: authorPostCount, pageInformation: pageInformation)

        let context = try XCTUnwrap(viewRenderer.capturedContext as? AllAuthorsPageContext)
        XCTAssertEqual(context.authors.first?.postCount, 20)
        XCTAssertEqual(context.authors.first?.userID, 1)
        XCTAssertEqual(context.authors[1].userID, 0)
        XCTAssertEqual(context.authors[1].postCount, 1)
    }

    func testAuthorsPageHandlesNoPostsForAuthorCorrectly() throws {
        let user1 = TestDataBuilder.anyUser(id: 0)
        let user2 = TestDataBuilder.anyUser(id: 1, name: "Han", username: "han")
        let authors = [user1, user2]
        let authorPostCount = [0: 0, 1: 20]
        let pageInformation = buildPageInformation(currentPageURL: allAuthorsURL)
        _ = presenter.allAuthorsView(on: basicContainer, authors: authors, authorPostCounts: authorPostCount, pageInformation: pageInformation)

        let context = try XCTUnwrap(viewRenderer.capturedContext as? AllAuthorsPageContext)
        XCTAssertEqual(context.authors[1].userID, 0)
        XCTAssertEqual(context.authors[1].postCount, 0)
    }

    func testTwitterHandleNotSetOnAllAuthorsPageIfNotProvided() throws {
        let pageInformation = buildPageInformation(currentPageURL: allAuthorsURL, siteTwitterHandle: nil)
        _ = presenter.allAuthorsView(on: basicContainer, authors: [], authorPostCounts: [:], pageInformation: pageInformation)

        let context = try XCTUnwrap(viewRenderer.capturedContext as? AllAuthorsPageContext)
        XCTAssertNil(context.pageInformation.siteTwitterHandle)
    }

    func testDisqusNameNotSetOnAllAuthorsPageIfNotProvided() throws {
        let pageInformation = buildPageInformation(currentPageURL: allAuthorsURL, disqusName: nil)
        _ = presenter.allAuthorsView(on: basicContainer, authors: [], authorPostCounts: [:], pageInformation: pageInformation)

        let context = try XCTUnwrap(viewRenderer.capturedContext as? AllAuthorsPageContext)
        XCTAssertNil(context.pageInformation.disqusName)
    }

    func testGAIdentifierNotSetOnAllAuthorsPageIfNotProvided() throws {
        let pageInformation = buildPageInformation(currentPageURL: allAuthorsURL, googleAnalyticsIdentifier: nil)
        _ = presenter.allAuthorsView(on: basicContainer, authors: [], authorPostCounts: [:], pageInformation: pageInformation)

        let context = try XCTUnwrap(viewRenderer.capturedContext as? AllAuthorsPageContext)
        XCTAssertNil(context.pageInformation.googleAnalyticsIdentifier)
    }

    func testLoggedInUserPassedToAllAuthorsPageIfProvided() throws {
        let user = TestDataBuilder.anyUser()
        let pageInformation = buildPageInformation(currentPageURL: allAuthorsURL, user: user)
        _ = presenter.allAuthorsView(on: basicContainer, authors: [], authorPostCounts: [:], pageInformation: pageInformation)

        let context = try XCTUnwrap(viewRenderer.capturedContext as? AllAuthorsPageContext)
        XCTAssertEqual(context.pageInformation.loggedInUser?.name, user.name)
        XCTAssertEqual(context.pageInformation.loggedInUser?.username, user.username)
    }

    // MARK: - Tag page

    func testTagPageGetsTagWithCorrectParamsAndPostCount() throws {
        let user = TestDataBuilder.anyUser(id: 3)
        let post1 = try TestDataBuilder.anyPost(author: user)
        let post2 = try TestDataBuilder.anyPost(author: user)
        let posts = [post1, post2]
        let pageInformation = buildPageInformation(currentPageURL: tagURL, user: user)
        let currentPage = 2
        let totalPages = 10
        let currentQuery = "?page=2"

        _ = presenter.tagView(on: basicContainer, tag: testTag, posts: posts, pageInformation: pageInformation, paginationTagInfo: buildPaginationInformation(currentPage: currentPage, totalPages: totalPages, currentQuery: currentQuery))

        let context = try XCTUnwrap(viewRenderer.capturedContext as? TagPageContext)
        XCTAssertEqual(context.tag.name, testTag.name)
        XCTAssertEqual(context.posts.count, 2)
        XCTAssertEqual(context.posts.first?.title, post1.title)
        XCTAssertEqual(context.posts.first?.blogID, post1.blogID)
        XCTAssertEqual(context.posts.last?.title, post2.title)
        XCTAssertEqual(context.posts.last?.blogID, post2.blogID)
        XCTAssertTrue(context.tagPage)
        XCTAssertEqual(context.pageInformation.loggedInUser?.name, user.name)
        XCTAssertEqual(context.pageInformation.loggedInUser?.username, user.username)
        XCTAssertEqual(context.pageInformation.googleAnalyticsIdentifier, BlogPresenterTests.googleAnalyticsIdentifier)
        XCTAssertEqual(context.pageInformation.siteTwitterHandle, BlogPresenterTests.siteTwitterHandle)
        XCTAssertEqual(context.pageInformation.disqusName, BlogPresenterTests.disqusName)
        XCTAssertEqual(context.pageInformation.websiteURL.absoluteString, "https://brokenhands.io")
        XCTAssertEqual(context.pageInformation.currentPageURL.absoluteString, "https://brokenhands.io/tags/tattoine")
        XCTAssertEqual(viewRenderer.templatePath, "blog/tag")
        XCTAssertEqual(context.paginationInformation.currentPage, currentPage)
        XCTAssertEqual(context.paginationInformation.totalPages, totalPages)
        XCTAssertEqual(context.paginationInformation.currentQuery, currentQuery)
    }

    func testNoLoggedInUserPassedToTagPageIfNoneProvided() throws {
        let pageInformation = buildPageInformation(currentPageURL: tagURL)
        _ = presenter.tagView(on: basicContainer, tag: testTag, posts: [], pageInformation: pageInformation, paginationTagInfo: buildPaginationInformation())

        let context = try XCTUnwrap(viewRenderer.capturedContext as? TagPageContext)
        XCTAssertNil(context.pageInformation.loggedInUser)
    }

    func testDisqusNameNotPassedToTagPageIfNotSet() throws {
        let pageInformation = buildPageInformation(currentPageURL: tagURL, disqusName: nil)
        _ = presenter.tagView(on: basicContainer, tag: testTag, posts: [], pageInformation: pageInformation, paginationTagInfo: buildPaginationInformation())

        let context = try XCTUnwrap(viewRenderer.capturedContext as? TagPageContext)
        XCTAssertNil(context.pageInformation.disqusName)
    }

    func testTwitterHandleNotPassedToTagPageIfNotSet() throws {
        let pageInformation = buildPageInformation(currentPageURL: tagURL, siteTwitterHandle: nil)
        _ = presenter.tagView(on: basicContainer, tag: testTag, posts: [], pageInformation: pageInformation, paginationTagInfo: buildPaginationInformation())

        let context = try XCTUnwrap(viewRenderer.capturedContext as? TagPageContext)
        XCTAssertNil(context.pageInformation.siteTwitterHandle)
    }

    func testGAIdentifierNotPassedToTagPageIfNotSet() throws {
        let pageInformation = buildPageInformation(currentPageURL: tagURL, googleAnalyticsIdentifier: nil)
        _ = presenter.tagView(on: basicContainer, tag: testTag, posts: [], pageInformation: pageInformation, paginationTagInfo: buildPaginationInformation())

        let context = try XCTUnwrap(viewRenderer.capturedContext as? TagPageContext)
        XCTAssertNil(context.pageInformation.googleAnalyticsIdentifier)
    }

    // MARK: - Blog Index

    func testBlogIndexPageGivenCorrectParameters() throws {
        let author1 = TestDataBuilder.anyUser(id: 0)
        let author2 = TestDataBuilder.anyUser(id: 1, username: "darth")
        let post = try TestDataBuilder.anyPost(author: author1)
        let post2 = try TestDataBuilder.anyPost(author: author2, title: "Another Title")
        let tag1 = try BlogTag(name: "Engineering")
        let tag2 = try BlogTag(name: "Fun")
        let tags = [tag1, tag2]
        let currentPage = 2
        let totalPages = 10
        let currentQuery = "?page=2"

        let pageInformation = buildPageInformation(currentPageURL: blogIndexURL)
        _ = presenter.indexView(on: basicContainer, posts: [post, post2], tags: tags, authors: [author1, author2], pageInformation: pageInformation, paginationTagInfo: buildPaginationInformation(currentPage: currentPage, totalPages: totalPages, currentQuery: currentQuery))

        let context = try XCTUnwrap(viewRenderer.capturedContext as? BlogIndexPageContext)
        XCTAssertEqual(context.title, "Blog")
        XCTAssertEqual(context.posts.count, 2)
        XCTAssertEqual(context.posts.first?.title, post.title)
        XCTAssertEqual(context.posts.last?.title, post2.title)
        XCTAssertEqual(context.tags.count, 2)
        XCTAssertEqual(context.tags.first?.name, tag1.name)
        XCTAssertEqual(context.tags.last?.name, tag2.name)
        XCTAssertEqual(context.authors.count, 2)
        XCTAssertEqual(context.authors.first?.username, author1.username)
        XCTAssertEqual(context.authors.last?.username, author2.username)
        XCTAssertTrue(context.blogIndexPage)
        XCTAssertEqual(viewRenderer.templatePath, "blog/blog")
        XCTAssertEqual(context.pageInformation.currentPageURL.absoluteString, "https://brokenhands.io/blog")
        XCTAssertEqual(context.pageInformation.websiteURL.absoluteString, "https://brokenhands.io")
        XCTAssertEqual(context.pageInformation.googleAnalyticsIdentifier, BlogPresenterTests.googleAnalyticsIdentifier)
        XCTAssertEqual(context.pageInformation.siteTwitterHandle, BlogPresenterTests.siteTwitterHandle)
        XCTAssertEqual(context.pageInformation.disqusName, BlogPresenterTests.disqusName)
        XCTAssertNil(context.pageInformation.loggedInUser)
        XCTAssertEqual(context.paginationInformation.currentPage, currentPage)
        XCTAssertEqual(context.paginationInformation.totalPages, totalPages)
        XCTAssertEqual(context.paginationInformation.currentQuery, currentQuery)
    }

    func testUserPassedToBlogIndexIfUserPassedIn() throws {
        let user = TestDataBuilder.anyUser()
        let pageInformation = buildPageInformation(currentPageURL: blogIndexURL, user: user)
        _ = presenter.indexView(on: basicContainer, posts: [], tags: [], authors: [], pageInformation: pageInformation, paginationTagInfo: buildPaginationInformation())

        let context = try XCTUnwrap(viewRenderer.capturedContext as? BlogIndexPageContext)
        XCTAssertEqual(context.pageInformation.loggedInUser?.name, user.name)
        XCTAssertEqual(context.pageInformation.loggedInUser?.username, user.username)
    }

    func testDisqusNameNotPassedToBlogIndexIfNotPassedIn() throws {
        let pageInformation = buildPageInformation(currentPageURL: blogIndexURL, disqusName: nil)
        _ = presenter.indexView(on: basicContainer, posts: [], tags: [], authors: [], pageInformation: pageInformation, paginationTagInfo: buildPaginationInformation())

        let context = try XCTUnwrap(viewRenderer.capturedContext as? BlogIndexPageContext)
        XCTAssertNil(context.pageInformation.disqusName)
    }

    func testTwitterHandleNotPassedToBlogIndexIfNotPassedIn() throws {
        let pageInformation = buildPageInformation(currentPageURL: blogIndexURL, siteTwitterHandle: nil)
        _ = presenter.indexView(on: basicContainer, posts: [], tags: [], authors: [], pageInformation: pageInformation, paginationTagInfo: buildPaginationInformation())

        let context = try XCTUnwrap(viewRenderer.capturedContext as? BlogIndexPageContext)
        XCTAssertNil(context.pageInformation.siteTwitterHandle)
    }

    func testGAIdentifierNotPassedToBlogIndexIfNotPassedIn() throws {
        let pageInformation = buildPageInformation(currentPageURL: blogIndexURL, googleAnalyticsIdentifier: nil)
        _ = presenter.indexView(on: basicContainer, posts: [], tags: [], authors: [], pageInformation: pageInformation, paginationTagInfo: buildPaginationInformation())

        let context = try XCTUnwrap(viewRenderer.capturedContext as? BlogIndexPageContext)
        XCTAssertNil(context.pageInformation.googleAnalyticsIdentifier)
    }

    // MARK: - Author page

    func testAuthorViewHasCorrectParametersSet() throws {
        let author = TestDataBuilder.anyUser(id: 0)
        let post1 = try TestDataBuilder.anyPost(author: author)
        let post2 = try TestDataBuilder.anyPost(author: author, title: "Another Post", slugUrl: "another-post")
        let page = 2
        let totalPages = 10
        let query = "page=2"

        let pageInformation = buildPageInformation(currentPageURL: authorURL)
        _ = presenter.authorView(on: basicContainer, author: author, posts: [post1, post2], postCount: 2, pageInformation: pageInformation, paginationTagInfo: buildPaginationInformation(currentPage: page, totalPages: totalPages, currentQuery: query))

        let context = try XCTUnwrap(viewRenderer.capturedContext as? AuthorPageContext)
        XCTAssertEqual(context.author.name, author.name)
        XCTAssertEqual(context.author.tagline, author.tagline)
        XCTAssertEqual(context.author.twitterHandle, author.twitterHandle)
        XCTAssertEqual(context.author.profilePicture, author.profilePicture)
        XCTAssertEqual(context.author.biography, author.biography)
        XCTAssertEqual(context.posts.count, 2)
        XCTAssertEqual(context.posts.first?.title, post1.title)
        XCTAssertEqual(context.posts.last?.title, post2.title)
        XCTAssertFalse(context.myProfile)
        XCTAssertTrue(context.profilePage)
        XCTAssertEqual(context.pageInformation.currentPageURL.absoluteString, "https://brokenhands.io/authors/luke")
        XCTAssertEqual(context.pageInformation.websiteURL.absoluteString, "https://brokenhands.io")
        XCTAssertNil(context.pageInformation.loggedInUser)
        XCTAssertEqual(context.pageInformation.disqusName, BlogPresenterTests.disqusName)
        XCTAssertEqual(context.pageInformation.googleAnalyticsIdentifier, BlogPresenterTests.googleAnalyticsIdentifier)
        XCTAssertEqual(context.pageInformation.siteTwitterHandle, BlogPresenterTests.siteTwitterHandle)
        XCTAssertEqual(viewRenderer.templatePath, "blog/profile")
        XCTAssertEqual(context.paginationInformation.currentPage, page)
        XCTAssertEqual(context.paginationInformation.totalPages, totalPages)
        XCTAssertEqual(context.paginationInformation.currentQuery, query)
    }

    func testAuthorViewGetsLoggedInUserIfProvider() throws {
        let author = TestDataBuilder.anyUser(id: 0)
        let user = TestDataBuilder.anyUser(id: 1, username: "hans")
        let pageInformation = buildPageInformation(currentPageURL: authorURL, user: user)
        _ = presenter.authorView(on: basicContainer, author: author, posts: [], postCount: 0, pageInformation: pageInformation, paginationTagInfo: buildPaginationInformation())

        let context = try XCTUnwrap(viewRenderer.capturedContext as? AuthorPageContext)
        XCTAssertEqual(context.pageInformation.loggedInUser?.userID, user.userID)
        XCTAssertEqual(context.pageInformation.loggedInUser?.username, user.username)
    }

    func testMyProfileFlagSetIfLoggedInUserIsTheSameAsAuthorOnAuthorView() throws {
        let author = TestDataBuilder.anyUser(id: 0)
        let pageInformation = buildPageInformation(currentPageURL: authorURL, user: author)
        _ = presenter.authorView(on: basicContainer, author: author, posts: [], postCount: 0, pageInformation: pageInformation, paginationTagInfo: buildPaginationInformation())

        let context = try XCTUnwrap(viewRenderer.capturedContext as? AuthorPageContext)
        XCTAssertTrue(context.myProfile)
    }

    func testAuthorViewDoesNotGetDisqusNameIfNotProvided() throws {
        let author = TestDataBuilder.anyUser()
        let pageInformation = buildPageInformation(currentPageURL: authorURL, disqusName: nil)
        _ = presenter.authorView(on: basicContainer, author: author, posts: [], postCount: 0, pageInformation: pageInformation, paginationTagInfo: buildPaginationInformation())

        let context = try XCTUnwrap(viewRenderer.capturedContext as? AuthorPageContext)
        XCTAssertNil(context.pageInformation.disqusName)
    }

    func testAuthorViewDoesNotGetTwitterHandleIfNotProvided() throws {
        let author = TestDataBuilder.anyUser()
        let pageInformation = buildPageInformation(currentPageURL: authorURL, siteTwitterHandle: nil)
        _ = presenter.authorView(on: basicContainer, author: author, posts: [], postCount: 0, pageInformation: pageInformation, paginationTagInfo: buildPaginationInformation())

        let context = try XCTUnwrap(viewRenderer.capturedContext as? AuthorPageContext)
        XCTAssertNil(context.pageInformation.siteTwitterHandle)
    }

    func testAuthorViewDoesNotGetGAIdentifierIfNotProvided() throws {
        let author = TestDataBuilder.anyUser()
        let pageInformation = buildPageInformation(currentPageURL: authorURL, googleAnalyticsIdentifier: nil)
        _ = presenter.authorView(on: basicContainer, author: author, posts: [], postCount: 0, pageInformation: pageInformation, paginationTagInfo: buildPaginationInformation())

        let context = try XCTUnwrap(viewRenderer.capturedContext as? AuthorPageContext)
        XCTAssertNil(context.pageInformation.googleAnalyticsIdentifier)
    }

    func testAuthorViewGetsPostCount() throws {
        let author = TestDataBuilder.anyUser(id: 0)
        let post1 = try TestDataBuilder.anyPost(author: author)
        let post2 = try TestDataBuilder.anyPost(author: author)
        let post3 = try TestDataBuilder.anyPost(author: author)
        let pageInformation = buildPageInformation(currentPageURL: authorURL)
        _ = presenter.authorView(on: basicContainer, author: author, posts: [post1, post2, post3], postCount: 3, pageInformation: pageInformation, paginationTagInfo: buildPaginationInformation())

        let context = try XCTUnwrap(viewRenderer.capturedContext as? AuthorPageContext)
        XCTAssertEqual(context.postCount, 3)
    }

    func testAuthorViewGetsLongSnippetForPosts() throws {
        let author = TestDataBuilder.anyUser(id: 0)
        let post1 = try TestDataBuilder.anyPost(author: author, contents: TestDataBuilder.longContents)
        let pageInformation = buildPageInformation(currentPageURL: authorURL)
        _ = presenter.authorView(on: basicContainer, author: author, posts: [post1], postCount: 1, pageInformation: pageInformation, paginationTagInfo: buildPaginationInformation())

        let context = try XCTUnwrap(viewRenderer.capturedContext as? AuthorPageContext)
        let characterCount = try XCTUnwrap(context.posts.first?.longSnippet.count)
        XCTAssertGreaterThan(characterCount, 900)
    }

    func testLoginViewGetsCorrectParameters() throws {
        let pageInformation = buildPageInformation(currentPageURL: loginURL)
        _ = presenter.loginView(on: basicContainer, loginWarning: false, errors: nil, username: nil, usernameError: false, passwordError: false, rememberMe: false, pageInformation: pageInformation)

        let context = try XCTUnwrap(viewRenderer.capturedContext as? LoginPageContext)
        XCTAssertNil(context.errors)
        XCTAssertFalse(context.loginWarning)
        XCTAssertNil(context.username)
        XCTAssertFalse(context.usernameError)
        XCTAssertFalse(context.passwordError)
        XCTAssertEqual(context.title, "Log In")
        XCTAssertFalse(context.rememberMe)
        XCTAssertEqual(context.pageInformation.currentPageURL.absoluteString, "https://brokenhands.io/admin/login")
        XCTAssertEqual(viewRenderer.templatePath, "blog/admin/login")
    }

    func testLoginViewWhenErrored() throws {
        let expectedError = "Username/password incorrect"
        let pageInformation = buildPageInformation(currentPageURL: loginURL)
        _ = presenter.loginView(on: basicContainer, loginWarning: true, errors: [expectedError], username: "tim", usernameError: true, passwordError: true, rememberMe: true, pageInformation: pageInformation)

        let context = try XCTUnwrap(viewRenderer.capturedContext as? LoginPageContext)
        XCTAssertEqual(context.errors?.count, 1)
        XCTAssertEqual(context.errors?.first, expectedError)
        XCTAssertTrue(context.loginWarning)
        XCTAssertEqual(context.username, "tim")
        XCTAssertTrue(context.usernameError)
        XCTAssertTrue(context.passwordError)
        XCTAssertTrue(context.rememberMe)
    }

    func testSearchPageGetsCorrectParameters() throws {
        let author = TestDataBuilder.anyUser(id: 0)
        let post1 = try TestDataBuilder.anyPost(author: author, title: "Vapor 1")
        let post2 = try TestDataBuilder.anyPost(author: author, title: "Vapor 2")
        let pageInformation = buildPageInformation(currentPageURL: searchURL)
        let paginationInformation = PaginationTagInformation(currentPage: 1, totalPages: 3, currentQuery: "?term=vapor")

        _ = presenter.searchView(on: basicContainer, totalResults: 2, posts: [post1, post2], authors: [author], searchTerm: "vapor", pageInformation: pageInformation, paginationTagInfo: paginationInformation)

        let context = try XCTUnwrap(viewRenderer.capturedContext as? SearchPageContext)
        XCTAssertEqual(context.title, "Search Blog")
        XCTAssertEqual(context.searchTerm, "vapor")
        XCTAssertEqual(context.posts.count, 2)
        XCTAssertEqual(context.posts.first?.title, "Vapor 1")
        XCTAssertEqual(context.posts.last?.title, "Vapor 2")

        XCTAssertEqual(viewRenderer.templatePath, "blog/search")
        XCTAssertEqual(context.pageInformation.disqusName, BlogPresenterTests.disqusName)
        XCTAssertEqual(context.pageInformation.googleAnalyticsIdentifier, BlogPresenterTests.googleAnalyticsIdentifier)
        XCTAssertEqual(context.pageInformation.siteTwitterHandle, BlogPresenterTests.siteTwitterHandle)
        XCTAssertNil(context.pageInformation.loggedInUser)
        XCTAssertEqual(context.pageInformation.websiteURL.absoluteString, "https://brokenhands.io")
        XCTAssertEqual(context.pageInformation.currentPageURL.absoluteString, "https://brokenhands.io/search?term=vapor")
        XCTAssertEqual(context.paginationTagInformation.currentPage, 1)
        XCTAssertEqual(context.paginationTagInformation.totalPages, 3)
        XCTAssertEqual(context.paginationTagInformation.currentQuery, "?term=vapor")
    }

    func testSearchPageGetsNilIfNoSearchTermProvided() throws {
        let pageInformation = buildPageInformation(currentPageURL: searchURL)
        let paginationInformation = PaginationTagInformation(currentPage: 0, totalPages: 0, currentQuery: nil)
        _ = presenter.searchView(on: basicContainer, totalResults: 0, posts: [], authors: [], searchTerm: nil, pageInformation: pageInformation, paginationTagInfo: paginationInformation)

        let context = try XCTUnwrap(viewRenderer.capturedContext as? SearchPageContext)
        XCTAssertNil(context.searchTerm)
    }

    // MARK: - Helpers

    private func buildPageInformation(currentPageURL: URL, siteTwitterHandle: String? = BlogPresenterTests.siteTwitterHandle, disqusName: String? = BlogPresenterTests.disqusName, googleAnalyticsIdentifier: String? = BlogPresenterTests.googleAnalyticsIdentifier, user: BlogUser? = nil) -> BlogGlobalPageInformation {
        return BlogGlobalPageInformation(disqusName: disqusName, siteTwitterHandle: siteTwitterHandle, googleAnalyticsIdentifier: googleAnalyticsIdentifier, loggedInUser: user, websiteURL: websiteURL, currentPageURL: currentPageURL)
    }
    
    private func buildPaginationInformation(currentPage: Int = 1, totalPages: Int = 5, currentQuery: String? = nil) -> PaginationTagInformation {
        return PaginationTagInformation(currentPage: currentPage, totalPages: totalPages, currentQuery: currentQuery)
    }

}
