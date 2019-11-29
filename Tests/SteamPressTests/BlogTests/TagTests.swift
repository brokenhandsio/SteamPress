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
    
    func testTagsPageGetsPassedAllTagsWithBlogCount() throws {
//        let user = TestDataBuilder.anyUser()
//        let tag = BlogTag(name: "test tag")
//        let post1 = TestDataBuilder.anyPost(author: user)
//        try post1.save()
//        try BlogTag.addTag(tag.name, to: post1)
//
//        _ = try viewFactory.allTagsView(uri: tagsURI, allTags: [tag], user: nil)
//        XCTAssertEqual((viewRenderer.capturedContext?["tags"]?.array?.first)?["post_count"], 1)
        #warning("test")
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

    func testGettingTagViewWithURLEncodedName() throws {
        let tagName = "Some Tag"
        _ = try testWorld.createTag(tagName)

        let urlEncodedName = try XCTUnwrap(tagName.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed))
        let response = try testWorld.getResponse(to: "/tags/\(urlEncodedName)")

        XCTAssertEqual(response.http.status, .ok)
        XCTAssertEqual(presenter.tag?.name.removingPercentEncoding, tagName)
        #warning("Test that this is URL decoded in the Leaf presenter")
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
