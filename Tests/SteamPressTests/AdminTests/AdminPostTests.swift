import XCTest
import Vapor
import SteamPress

class AdminPostTests: XCTestCase {
    
    // MARK: - allTests
    
    static var allTests = [
        ("testLinuxTestSuiteIncludesAllTests", testLinuxTestSuiteIncludesAllTests),
        ("testPostCanBeCreated", testPostCanBeCreated),
        ]
    
    // MARK: - Properties
    private var app: Application!
    private var testWorld: TestWorld!
    private let createPostPath = "/admin/createPost/"
    private let authorsRequestPath = "/authors/leia"
    private var user: BlogUser!
    private var postData: TestData!
    private var presenter: CapturingBlogPresenter {
        return testWorld.context.blogPresenter
    }
    
    // MARK: - Overrides
    
    override func setUp() {
        testWorld = try! TestWorld.create()
//        user = testWorld.createUser(username: "leia")
//        postData = try! testWorld.createPost(author: user)
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
            let content = "# Post Title\n\nWe have a post"
            let tags = ["First Tag", "Second Tag"]
            let slugURL = "post-title"
            let publish = true
        }
        let createData = CreatePostData()
        _ = try testWorld.getResponse(to: createPostPath, body: createData)
        
        XCTAssertEqual(testWorld.context.repository.posts.count, 1)
        XCTAssertEqual(testWorld.context.repository.posts.first?.title, createData.title)
        XCTAssertTrue(testWorld.context.repository.posts.first?.published ?? false)
    }
    
//    func testPostCannotBeCreatedIfDraftAndPublishNotSet() throws {
//        let request = try createLoggedInRequest(method: .post, path: "createPost")
//        var postData = Node([:], in: nil)
//        try postData.set("inputTitle", "Post Title")
//        try postData.set("inputPostContents", "# Post Title\n\nWe have a post")
//        try postData.set("inputTags", ["First Tag", "Second Tag"])
//        try postData.set("inputSlugUrl", "post-title")
//        request.formURLEncoded = postData
//
//        let response  = try drop.respond(to: request)
//
//        XCTAssertEqual(response.status.statusCode, 400)
//    }
//
//    func testCreatePostMustIncludeTitle() throws {
//        let request = try createLoggedInRequest(method: .post, path: "createPost")
//        var postData = Node([:], in: nil)
//        try postData.set("inputPostContents", "# Post Title\n\nWe have a post")
//        try postData.set("inputTags", ["First Tag", "Second Tag"])
//        try postData.set("inputSlugUrl", "post-title")
//        try postData.set("publish", "true")
//        request.formURLEncoded = postData
//
//        let _  = try drop.respond(to: request)
//
//        XCTAssertTrue(capturingViewFactory.createPostErrors?.contains("You must specify a blog post title") ?? false)
//    }
//
//    func testCreatePostMustIncludeContents() throws {
//        let request = try createLoggedInRequest(method: .post, path: "createPost")
//        var postData = Node([:], in: nil)
//        try postData.set("inputTitle", "post-title")
//        try postData.set("inputTags", ["First Tag", "Second Tag"])
//        try postData.set("inputSlugUrl", "post-title")
//        try postData.set("publish", "true")
//        request.formURLEncoded = postData
//
//        let _  = try drop.respond(to: request)
//
//        XCTAssertTrue(capturingViewFactory.createPostErrors?.contains("You must have some content in your blog post") ?? false)
//    }
//
//    func testCreatePostWithDraftDoesNotPublishPost() throws {
//        let request = try createLoggedInRequest(method: .post, path: "createPost")
//        let postTitle = "Post Title"
//        var postData = Node([:], in: nil)
//        try postData.set("inputTitle", postTitle)
//        try postData.set("inputPostContents", "# Post Title\n\nWe have a post")
//        try postData.set("inputTags", ["First Tag", "Second Tag"])
//        try postData.set("inputSlugUrl", "post-title")
//        try postData.set("save-draft", "true")
//        request.formURLEncoded = postData
//
//        let _  = try drop.respond(to: request)
//
//        XCTAssertEqual(try BlogPost.count(), 1)
//        XCTAssertEqual(try BlogPost.all().first?.title, postTitle)
//        XCTAssertFalse(try BlogPost.all().first?.published ?? true)
//    }
}
