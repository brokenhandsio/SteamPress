import XCTest
import Vapor
import SteamPress

class AdminPostTests: XCTestCase {
    
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
        
        let post = try XCTUnwrap(testWorld.context.repository.posts.first)
        XCTAssertEqual(testWorld.context.repository.posts.count, 1)
        XCTAssertEqual(post.title, createData.title)
        XCTAssertTrue(post.published)
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

        let createPostErrors = try XCTUnwrap(presenter.createPostErrors)
        XCTAssertTrue(createPostErrors.contains("You must specify a blog post title"))
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

        let createPostErrors = try XCTUnwrap(presenter.createPostErrors)
        XCTAssertTrue(createPostErrors.contains("You must have some content in your blog post"))
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
        let post = try XCTUnwrap(testWorld.context.repository.posts.first)
        XCTAssertEqual(post.title, createData.title)
        XCTAssertFalse(post.published)
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
        let post = try XCTUnwrap(testWorld.context.repository.posts.first)
        XCTAssertEqual(post.title, updateData.title)
        XCTAssertEqual(post.contents, updateData.contents)
        XCTAssertEqual(post.slugUrl, updateData.slugURL)
        XCTAssertEqual(post.blogID, testData.post.blogID)
    }

    func testCanDeleteBlogPost() throws {
        let testData = try testWorld.createPost()
        let response = try testWorld.getResponse(to: "/admin/posts/\(testData.post.blogID!)/delete", method: .POST, body: EmptyContent(), loggedInUser: user)
        
        XCTAssertEqual(response.http.status, .seeOther)
        XCTAssertEqual(response.http.headers[.location].first, "/admin/")
        XCTAssertEqual(testWorld.context.repository.posts.count, 0)
    }
    
    func testEditPageGetsPostInfo() throws {
        let post = try testWorld.createPost().post
        _ = try testWorld.getResponse(to: "/admin/posts/\(post.blogID!)/edit", loggedInUser: user)
        
        XCTAssertEqual(presenter.createPostTitle, post.title)
        XCTAssertEqual(presenter.createPostContents, post.contents)
        XCTAssertEqual(presenter.createPostSlugURL, post.slugUrl)
        XCTAssertTrue(presenter.createPostIsEditing ?? false)
        XCTAssertEqual(presenter.createPostPost?.blogID, post.blogID)
        XCTAssertEqual(presenter.createPostDraft, !post.published)
    }
    
    func testThatEditingPostGetsRedirectToPostPage() throws {
        let testData = try testWorld.createPost()
        
        struct UpdateData: Content {
            let title: String
            let contents = "Updated contents"
            let slugURL: String
            let publish = true
        }
        
        let updateData = UpdateData(title: testData.post.title, slugURL: testData.post.slugUrl)
        let response = try testWorld.getResponse(to: "/admin/posts/\(testData.post.blogID!)/edit", body: updateData, loggedInUser: user)

        XCTAssertEqual(response.http.status, .seeOther)
        XCTAssertEqual(response.http.headers[.location].first, "/posts/\(updateData.slugURL)/")
    }

}
