import XCTest
@testable import SteamPress
import Vapor
import Fluent
import HTTP
import Foundation

class BlogControllerTests: XCTestCase {
    static var allTests = [
        ("testLinuxTestSuiteIncludesAllTests", testLinuxTestSuiteIncludesAllTests),
        ("testBlogIndexGetsPostsInReverseOrder", testBlogIndexGetsPostsInReverseOrder),
        ("testBlogIndexGetsAllTags", testBlogIndexGetsAllTags),
        ("testBlogIndexGetsAllAuthors", testBlogIndexGetsAllAuthors),
        ("testBlogPostRetrievedCorrectlyFromSlugUrl", testBlogPostRetrievedCorrectlyFromSlugUrl),
        ("testThatAccessingPathsRouteRedirectsToBlogIndex", testThatAccessingPathsRouteRedirectsToBlogIndex),
        ("testAuthorView", testAuthorView),
        ("testTagView", testTagView),
        ("testIndexPageGetsUri", testIndexPageGetsUri),
        ("testBlogPageGetsUri", testBlogPageGetsUri),
        ("testProfilePageGetsUri", testProfilePageGetsUri),
        ("testTagPageGetsUri", testTagPageGetsUri),
        ("testAllAuthorsPageGetsUri", testAllAuthorsPageGetsUri),
        ("testAllTagsPageGetsUri", testAllTagsPageGetsUri),
        ("testAllTagsPageGetsAllTags", testAllTagsPageGetsAllTags),
        ("testAllAuthorsPageGetAllAuthors", testAllAuthorsPageGetAllAuthors),
        ("testTagPageGetsOnlyPublishedPostsInDescendingOrder", testTagPageGetsOnlyPublishedPostsInDescendingOrder),
        ("testAuthorPageGetsOnlyPublishedPostsInDescendingOrder", testAuthorPageGetsOnlyPublishedPostsInDescendingOrder),
        ("testDisabledBlogAuthorsPath", testDisabledBlogAuthorsPath),
        ("testDisabledBlogTagsPath", testDisabledBlogTagsPath),
        ("testTagAPIEndpointReportsArrayOfTagsAsJson", testTagAPIEndpointReportsArrayOfTagsAsJson),
    ]

    private var drop: Droplet!
    private var database: Database!
    private var viewFactory: CapturingViewFactory!
    private var post: BlogPost!
    private var user: BlogUser!
    private let blogIndexPath = "/"
    private let blogPostPath = "/posts/test-path/"
    private let tagPath = "/tags/tatooine/"
    private let authorPath = "/authors/luke/"
    private let allAuthorsPath = "/authors/"
    private let allTagsPath = "/tags/"
    private var blogPostRequest: Request!
    private var authorRequest: Request!
    private var tagRequest: Request!
    private var blogIndexRequest: Request!
    private var allTagsRequest: Request!
    private var allAuthorsRequest: Request!

    override func setUp() {
        blogPostRequest = Request(method: .get, uri: blogPostPath)
        authorRequest = Request(method: .get, uri: authorPath)
        tagRequest = Request(method: .get, uri: tagPath)
        blogIndexRequest = Request(method: .get, uri: blogIndexPath)
        allTagsRequest = Request(method: .get, uri: allTagsPath)
        allAuthorsRequest = Request(method: .get, uri: allAuthorsPath)
        database = try! Database(MemoryDriver())
        try! Droplet.prepare(database: database)
    }
    
    override func tearDown() {
        try! Droplet.teardown(database: database)
    }

    func setupDrop(config: Config? = nil, setupData: Bool = true) throws {
        drop = try Droplet()

        viewFactory = CapturingViewFactory()
        let pathCreator = BlogPathCreator(blogPath: nil)
        let configToUse = config ?? drop.config

        let enableAuthorsPages = configToUse["enableAuthorsPages"]?.bool ?? true
        let enableTagsPages = configToUse["enableTagsPages"]?.bool ?? true

        let blogController = BlogController(drop: drop, pathCreator: pathCreator, viewFactory: viewFactory, enableAuthorsPages: enableAuthorsPages, enableTagsPages: enableTagsPages)
        blogController.addRoutes()

        let blogAdminController = BlogAdminController(drop: drop, pathCreator: pathCreator, viewFactory: viewFactory)
        blogAdminController.addRoutes()

        if setupData {
            user = TestDataBuilder.anyUser()
            try user.save()
            post = BlogPost(title: "Test Path", contents: "A long time ago", author: user, creationDate: Date(), slugUrl: "test-path", published: true)
            try post.save()

            try BlogTag.addTag("tatooine", to: post)
        }
    }
    
    func testLinuxTestSuiteIncludesAllTests() {
        #if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
            let thisClass = type(of: self)
            let linuxCount = thisClass.allTests.count
            let darwinCount = Int(thisClass
                .defaultTestSuite().testCaseCount)
            XCTAssertEqual(linuxCount, darwinCount,
                           "\(darwinCount - linuxCount) tests are missing from allTests")
        #endif
    }

    func testBlogIndexGetsPostsInReverseOrder() throws {
        try setupDrop()

        let post2 = BlogPost(title: "A New Path", contents: "In a galaxy far, far, away", author: user, creationDate: Date(), slugUrl: "a-new-path", published: true)
        try post2.save()

        _ = try drop.respond(to: blogIndexRequest)

        XCTAssertEqual(viewFactory.paginatedPosts?.total, 2)
        XCTAssertEqual(viewFactory.paginatedPosts?.data[0].title, "A New Path")
        XCTAssertEqual(viewFactory.paginatedPosts?.data[1].title, "Test Path")

    }

    func testBlogIndexGetsAllTags() throws {
        try setupDrop()
        _ = try drop.respond(to: blogIndexRequest)

        XCTAssertEqual(viewFactory.blogIndexTags?.count, 1)
        XCTAssertEqual(viewFactory.blogIndexTags?.first?.name, "tatooine")
    }
    
    func testBlogIndexGetsAllAuthors() throws {
        try setupDrop()
        _ = try drop.respond(to: blogIndexRequest)
        
        XCTAssertEqual(viewFactory.blogIndexAuthors?.count, 1)
        XCTAssertEqual(viewFactory.blogIndexAuthors?.first?.name, "Luke")
    }

    func testBlogPostRetrievedCorrectlyFromSlugUrl() throws {
        try setupDrop()
        _ = try drop.respond(to: blogPostRequest)

        XCTAssertEqual(viewFactory.blogPost?.title, post.title)
        XCTAssertEqual(viewFactory.blogPost?.contents, post.contents)
        XCTAssertEqual(viewFactory.blogPostAuthor?.name, user.name)
        XCTAssertEqual(viewFactory.blogPostAuthor?.username, user.username)
    }

    func testThatAccessingPathsRouteRedirectsToBlogIndex() throws {
        try setupDrop()
        let request = Request(method: .get, uri: "/posts/")
        let response = try drop.respond(to: request)
        XCTAssertEqual(response.status, .movedPermanently)
        XCTAssertEqual(response.headers[HeaderKey.location], "/")
    }

    func testAuthorView() throws {
        try setupDrop()
        _ = try drop.respond(to: authorRequest)

        XCTAssertEqual(viewFactory.author?.username, user.username)
        XCTAssertEqual(viewFactory.authorPosts?.total, 1)
        XCTAssertEqual(viewFactory.authorPosts?.data[0].title, post.title)
        XCTAssertEqual(viewFactory.authorPosts?.data[0].contents, post.contents)
        XCTAssertEqual(viewFactory.isMyProfile, false)
    }

    func testTagView() throws {
        try setupDrop()
        _ = try drop.respond(to: tagRequest)

        XCTAssertEqual(viewFactory.tagPosts?.total, 1)
        XCTAssertEqual(viewFactory.tagPosts?.data[0].title, post.title)
        XCTAssertEqual(viewFactory.tag?.name, "tatooine")
    }

    func testIndexPageGetsUri() throws {
        try setupDrop()
        
        _ = try drop.respond(to: blogIndexRequest)
        
        XCTAssertEqual(blogIndexPath, viewFactory.blogIndexURI?.description)
    }
    
    func testBlogPageGetsUri() throws {
        try setupDrop()
        
        _ = try drop.respond(to: blogPostRequest)
        
        XCTAssertEqual(blogPostPath, viewFactory.blogPostURI?.description)
    }
    
    func testProfilePageGetsUri() throws {
        try setupDrop()
        
        _ = try drop.respond(to: authorRequest)
        
        XCTAssertEqual(authorPath, viewFactory.authorURI?.description)
    }
    
    func testTagPageGetsUri() throws {
        try setupDrop()
        
        _ = try drop.respond(to: tagRequest)
        
        XCTAssertEqual(tagPath, viewFactory.tagURI?.description)
    }
    
    func testAllAuthorsPageGetsUri() throws {
        try setupDrop()
        
        _ = try drop.respond(to: allAuthorsRequest)
        
        XCTAssertEqual(allAuthorsPath, viewFactory.allAuthorsURI?.description)
    }
    
    func testAllTagsPageGetsUri() throws {
        try setupDrop()
        
        _ = try drop.respond(to: allTagsRequest)
        
        XCTAssertEqual(allTagsPath, viewFactory.allTagsURI?.description)
    }
    
    func testAllTagsPageGetsAllTags() throws {
        try setupDrop()
        _ = try drop.respond(to: allTagsRequest)
        
        XCTAssertEqual(1, viewFactory.allTagsPageTags?.count)
        XCTAssertEqual("tatooine", viewFactory.allTagsPageTags?.first?.name)
    }
    
    func testAllAuthorsPageGetAllAuthors() throws {
        try setupDrop()
        _ = try drop.respond(to: allAuthorsRequest)
        
        XCTAssertEqual(1, viewFactory.allAuthorsPageAuthors?.count)
        XCTAssertEqual("Luke", viewFactory.allAuthorsPageAuthors?.first?.name)
    }
    
    func testTagPageGetsOnlyPublishedPostsInDescendingOrder() throws {
        try setupDrop()
        let post2 = TestDataBuilder.anyPost(author: self.user, title: "A later post")
        try post2.save()
        let draftPost = TestDataBuilder.anyPost(author: self.user, published: false)
        try draftPost.save()
        try BlogTag.addTag("tatooine", to: post2)
        try BlogTag.addTag("tatooine", to: draftPost)
        _ = try drop.respond(to: tagRequest)
        
        XCTAssertEqual(2, viewFactory.tagPosts?.total)
        XCTAssertEqual(post2.title, viewFactory.tagPosts?.data.first?.title)
    }
    
    func testAuthorPageGetsOnlyPublishedPostsInDescendingOrder() throws {
        try setupDrop()
        let post2 = TestDataBuilder.anyPost(author: self.user, title: "A later post")
        try post2.save()
        let draftPost = TestDataBuilder.anyPost(author: self.user, published: false)
        try draftPost.save()
        _ = try drop.respond(to: authorRequest)
        
        XCTAssertEqual(2, viewFactory.authorPosts?.total)
        XCTAssertEqual(post2.title, viewFactory.authorPosts?.data[0].title)
    }

    func testDisabledBlogAuthorsPath() throws {
        let config = Config(try Node(node: [
            "enableAuthorsPages": false
        ]))

        try setupDrop(config: config)

        let authorResponse = try drop.respond(to: authorRequest)
        let allAuthorsResponse = try drop.respond(to: allAuthorsRequest)

        XCTAssertEqual(404, authorResponse.status.statusCode)
        XCTAssertEqual(404, allAuthorsResponse.status.statusCode)
    }

    func testDisabledBlogTagsPath() throws {
        let config = Config(try Node(node: [
            "enableTagsPages": false
        ]))

        try setupDrop(config: config)

        let tagResponse = try drop.respond(to: tagRequest)
        let allTagsResponse = try drop.respond(to: allTagsRequest)

        XCTAssertEqual(404, tagResponse.status.statusCode)
        XCTAssertEqual(404, allTagsResponse.status.statusCode)
    }
    
    func testTagAPIEndpointReportsArrayOfTagsAsJson() throws {
        let tag1 = BlogTag(name: "The first tag")
        let tag2 = BlogTag(name: "The second tag")
        
        let pathCreator = BlogPathCreator(blogPath: nil)
        // TODO change to Stub
        let viewFactory = CapturingViewFactory()
        
        try setupDrop(setupData: false)
        let blogController = BlogController(drop: drop, pathCreator: pathCreator, viewFactory: viewFactory, enableAuthorsPages: true, enableTagsPages: true)
        blogController.addRoutes()
        
        try tag1.save()
        try tag2.save()
        
        let tagApiRequest = Request(method: .get, uri: "/api/tags/")
        let response = try drop.respond(to: tagApiRequest)
        
        let tagsJson = try JSON(bytes: response.body.bytes!)
        
        XCTAssertNotNil(tagsJson.array)
        XCTAssertEqual(tagsJson.array?.count, 2)
        
        guard let nodeArray = tagsJson.array else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(nodeArray[0]["name"]?.string, "The first tag")
        XCTAssertEqual(nodeArray[1]["name"]?.string, "The second tag")
    }
}

import URI
import Foundation

class CapturingViewFactory: ViewFactory {
    
    private func createDummyView() -> View {
        return View(data: "Test".makeBytes())
    }

    func createBlogPostView(uri: URI, errors: [String]?, title: String?, contents: String?, slugUrl: String?, tags: [Node]?, isEditing: Bool, postToEdit: BlogPost?, draft: Bool) throws -> View {
        return createDummyView()
    }

    func createUserView(editing: Bool, errors: [String]?, name: String?, username: String?, passwordError: Bool?, confirmPasswordError: Bool?, resetPasswordRequired: Bool?, userId: Identifier?, profilePicture: String?, twitterHandle: String?, biography: String?, tagline: String?) throws -> View {
        return createDummyView()
    }

    func createLoginView(loginWarning: Bool, errors: [String]?, username: String?, password: String?) throws -> View {
        return createDummyView()
    }

    private(set) var adminViewErrors: [String]? = nil
    func createBlogAdminView(errors: [String]?) throws -> View {
        adminViewErrors = errors
        return createDummyView()
    }

    func createResetPasswordView(errors: [String]?, passwordError: Bool?, confirmPasswordError: Bool?) throws -> View {
        return createDummyView()
    }

    private(set) var author: BlogUser? = nil
    private(set) var isMyProfile: Bool? = nil
    private(set) var authorPosts: Page<BlogPost>? = nil
    private(set) var authorURI: URI? = nil
    func createProfileView(uri: URI, author: BlogUser, isMyProfile: Bool, paginatedPosts: Page<BlogPost>, loggedInUser: BlogUser?) throws -> View {
        self.author = author
        self.isMyProfile = isMyProfile
        self.authorPosts = paginatedPosts
        self.authorURI = uri
        return createDummyView()
    }

    private(set) var blogPost: BlogPost? = nil
    private(set) var blogPostAuthor: BlogUser? = nil
    private(set) var blogPostURI: URI? = nil
    func blogPostView(uri: URI, post: BlogPost, author: BlogUser, user: BlogUser?) throws -> View {
        self.blogPost = post
        self.blogPostAuthor = author
        self.blogPostURI = uri
        return createDummyView()
    }

    private(set) var tag: BlogTag? = nil
    private(set) var tagPosts: Page<BlogPost>? = nil
    private(set) var tagUser: BlogUser? = nil
    private(set) var tagURI: URI? = nil
    func tagView(uri: URI, tag: BlogTag, paginatedPosts: Page<BlogPost>, user: BlogUser?) throws -> View {
        self.tag = tag
        self.tagPosts = paginatedPosts
        self.tagUser = user
        self.tagURI = uri
        return createDummyView()
    }

    private(set) var blogIndexTags: [BlogTag]? = nil
    private(set) var blogIndexAuthors: [BlogUser]? = nil
    private(set) var paginatedPosts: Page<BlogPost>? = nil
    private(set) var blogIndexURI: URI? = nil
    func blogIndexView(uri: URI, paginatedPosts: Page<BlogPost>, tags: [BlogTag], authors: [BlogUser], loggedInUser: BlogUser?) throws -> View {
        self.blogIndexTags = tags
        self.paginatedPosts = paginatedPosts
        self.blogIndexURI = uri
        self.blogIndexAuthors = authors
        return createDummyView()
    }
    
    private(set) var allAuthorsURI: URI? = nil
    private(set) var allAuthorsPageAuthors: [BlogUser]? = nil
    func allAuthorsView(uri: URI, allAuthors: [BlogUser], user: BlogUser?) throws -> View {
        self.allAuthorsURI = uri
        self.allAuthorsPageAuthors = allAuthors
        return createDummyView()
    }
    
    private(set) var allTagsURI: URI? = nil
    private(set) var allTagsPageTags: [BlogTag]? = nil
    func allTagsView(uri: URI, allTags: [BlogTag], user: BlogUser?) throws -> View {
        self.allTagsURI = uri
        self.allTagsPageTags = allTags
        return createDummyView()
    }
}
