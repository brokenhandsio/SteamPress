import XCTest
import Vapor
import SteamPress

class AdminPostTests: XCTestCase {
    
    // MARK: - allTests
    
    static var allTests = [
        ("testLinuxTestSuiteIncludesAllTests", testLinuxTestSuiteIncludesAllTests),
        ("testPostCanBeCreated", testPostCanBeCreated),
        ("testPostCannotBeCreatedIfDraftAndPublishNotSet", testPostCannotBeCreatedIfDraftAndPublishNotSet),
        ("testCreatePostMustIncludeTitle", testCreatePostMustIncludeTitle),
        ("testCreatePostMustIncludeContents", testCreatePostMustIncludeContents),
        ("testCreatePostWithDraftDoesNotPublishPost", testCreatePostWithDraftDoesNotPublishPost),
        ("testPostCanBeUpdated", testPostCanBeUpdated),
        ]
    
    // MARK: - Properties
    private var app: Application!
    private var testWorld: TestWorld!
    private let createPostPath = "/admin/createPost/"
    private var user: BlogUser!
    private var presenter: CapturingAdminPresenter {
        return testWorld.context.blogAdminPresenter
    }
    
    // MARK: - Overrides
    
    override func setUp() {
        testWorld = try! TestWorld.create()
        user = testWorld.createUser(username: "leia")
    }
    
    // MARK: - Tests
    
    func testLinuxTestSuiteIncludesAllTests() {
        #if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
        let thisClass = type(of: self)
        let linuxCount = thisClass.allTests.count
        let darwinCount = Int(thisClass
            .defaultTestSuite.testCaseCount)
        XCTAssertEqual(linuxCount, darwinCount,
                       "\(darwinCount - linuxCount) tests are missing from allTests")
        #endif
    }
    
    func testPostCanBeCreated() throws {
        struct CreatePostData: Content {
            static let defaultContentType = MediaType.urlEncodedForm
            let title = "Post Title"
            let contents = "# Post Title\n\nWe have a post"
            let tags = ["First Tag", "Second Tag"]
            let slugURL = "post-title"
            let publish = true
        }
        let createData = CreatePostData()
        let response = try testWorld.getResponse(to: createPostPath, body: createData, loggedInUser: user)
        
        XCTAssertEqual(testWorld.context.repository.posts.count, 1)
        XCTAssertEqual(testWorld.context.repository.posts.first?.title, createData.title)
        XCTAssertTrue(testWorld.context.repository.posts.first?.published ?? false)
        XCTAssertEqual(response.http.status, .seeOther)
        XCTAssertEqual(response.http.headers[.location].first, "/posts/post-title/")
    }
    
    func testPostCannotBeCreatedIfDraftAndPublishNotSet() throws {
        struct CreatePostData: Content {
            static let defaultContentType = MediaType.urlEncodedForm
            let title = "Post Title"
            let contents = "# Post Title\n\nWe have a post"
            let tags = ["First Tag", "Second Tag"]
            let slugURL = "post-title"
        }
        let createData = CreatePostData()
        
        let response = try testWorld.getResponse(to: createPostPath, body: createData, loggedInUser: user)

        XCTAssertEqual(response.http.status, .badRequest)
    }

    func testCreatePostMustIncludeTitle() throws {
        struct CreatePostData: Content {
            static let defaultContentType = MediaType.urlEncodedForm
            let contents = "# Post Title\n\nWe have a post"
            let tags = ["First Tag", "Second Tag"]
            let slugURL = "post-title"
            let publish = true
        }
        let createData = CreatePostData()
        _ = try testWorld.getResponse(to: createPostPath, body: createData, loggedInUser: user)

        XCTAssertTrue(presenter.createPostErrors?.contains("You must specify a blog post title") ?? false)
    }

    func testCreatePostMustIncludeContents() throws {
        struct CreatePostData: Content {
            static let defaultContentType = MediaType.urlEncodedForm
            let title = "Post Title"
            let tags = ["First Tag", "Second Tag"]
            let slugURL = "post-title"
            let publish = true
        }
        let createData = CreatePostData()
        _ = try testWorld.getResponse(to: createPostPath, body: createData, loggedInUser: user)

        XCTAssertTrue(presenter.createPostErrors?.contains("You must have some content in your blog post") ?? false)
    }

    func testCreatePostWithDraftDoesNotPublishPost() throws {
        struct CreatePostData: Content {
            static let defaultContentType = MediaType.urlEncodedForm
            let title = "Post Title"
            let contents = "# Post Title\n\nWe have a post"
            let tags = ["First Tag", "Second Tag"]
            let slugURL = "post-title"
            let draft = true
        }
        let createData = CreatePostData()
        _ = try testWorld.getResponse(to: createPostPath, body: createData, loggedInUser: user)

        XCTAssertEqual(testWorld.context.repository.posts.count, 1)
        XCTAssertEqual(testWorld.context.repository.posts.first?.title, createData.title)
        XCTAssertFalse(testWorld.context.repository.posts.first?.published ?? true)
    }
    
    func testPostCanBeUpdated() throws {
        struct UpdatePostData: Content {
            static let defaultContentType = MediaType.urlEncodedForm
            let title = "Post Title"
            let contents = "# Post Title\n\nWe have a post"
            let tags = ["First Tag", "Second Tag"]
            let slugURL = "post-title"
            let draft = true
        }
        
        let testData = try testWorld.createPost(title: "Initial title", contents: "Some initial contents", slugUrl: "initial-title")
        let updateData = UpdatePostData()
        
        let updatePostPath = "/admin/posts/\(testData.post.blogID!)/edit"
        _ = try testWorld.getResponse(to: updatePostPath, body: updateData, loggedInUser: user)

        XCTAssertEqual(testWorld.context.repository.posts.count, 1)
        XCTAssertEqual(testWorld.context.repository.posts.first?.title, updateData.title)
        XCTAssertEqual(testWorld.context.repository.posts.first?.contents, updateData.contents)
        XCTAssertEqual(testWorld.context.repository.posts.first?.slugUrl, updateData.slugURL)
        XCTAssertEqual(testWorld.context.repository.posts.first?.blogID, testData.post.blogID)
    }

}
