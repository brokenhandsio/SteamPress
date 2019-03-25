import XCTest
import Vapor
import SteamPress

class TagTests: XCTestCase {
    
    // MARK: - allTests
    
    static var allTests = [
        ("testLinuxTestSuiteIncludesAllTests", testLinuxTestSuiteIncludesAllTests),
        ("testAllTagsPageGetsAllTags", testAllTagsPageGetsAllTags),
        ("testTagPageGetsOnlyPublishedPostsInDescendingOrder", testTagPageGetsOnlyPublishedPostsInDescendingOrder),
        ("testDisabledBlogTagsPath", testDisabledBlogTagsPath),
        ("testTagView", testTagView),
        ("testTagNameContainsUrlEncodedName", testTagNameContainsUrlEncodedName)
    ]
    
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
    
    // MARK: - Overrides
    
    override func setUp() {
        testWorld = try! TestWorld.create()
        postData = try! testWorld.createPost()
        tag = try! testWorld.createTag(tagName, on: postData.post)
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
    
    func testAllTagsPageGetsAllTags() throws {
        _ = try testWorld.getResponse(to: allTagsRequestPath)

        XCTAssertEqual(1, presenter.allTagsPageTags?.count)
        XCTAssertEqual(tag.name, presenter.allTagsPageTags?.first?.name)
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
        testWorld = try TestWorld.create(enableTagPages: false)
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
}

