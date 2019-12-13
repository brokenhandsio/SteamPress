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

    // MARK: - Post Creation

    func testPostCanBeCreated() throws {
        struct CreatePostData: Content {
            static let defaultContentType = MediaType.urlEncodedForm
            let title = "Post Title"
            let contents = "# Post Title\n\nWe have a post"
            let tags = ["First Tag", "Second Tag"]
            let publish = true
        }
        let createData = CreatePostData()
        let response = try testWorld.getResponse(to: createPostPath, body: createData, loggedInUser: user)

        let post = try XCTUnwrap(testWorld.context.repository.posts.first)
        XCTAssertEqual(testWorld.context.repository.posts.count, 1)
        XCTAssertEqual(post.title, createData.title)
        XCTAssertEqual(post.slugUrl, "post-title")
        XCTAssertTrue(post.published)
        XCTAssertEqual(post.created.timeIntervalSince1970, Date().timeIntervalSince1970, accuracy: 0.1)
        XCTAssertTrue(post.created < Date())

        XCTAssertEqual(testWorld.context.repository.tags.count, 2)
        let firstTagID = testWorld.context.repository.tags[0].tagID!
        let secondTagID = testWorld.context.repository.tags[1].tagID!
        XCTAssertTrue(testWorld.context.repository.postTagLinks
            .contains { $0.postID == post.blogID! && $0.tagID == firstTagID })
        XCTAssertTrue(testWorld.context.repository.postTagLinks
            .contains { $0.postID == post.blogID! && $0.tagID == secondTagID })

        XCTAssertEqual(response.http.status, .seeOther)
        XCTAssertEqual(response.http.headers[.location].first, "/posts/post-title/")
    }

    func testCreatingPostWithNonUniqueSlugFromSameTitle() throws {
        let randomNumber = 345
        testWorld = try TestWorld.create(randomNumberGenerator: StubbedRandomNumberGenerator(numberToReturn: randomNumber))
        let initialPostData = try testWorld.createPost(title: "Post Title", slugUrl: "post-title")

        struct CreatePostData: Content {
            static let defaultContentType = MediaType.urlEncodedForm
            let title = "Post Title"
            let contents = "# Post Title\n\nWe have a post"
            let tags = ["First Tag", "Second Tag"]
            let publish = true
        }
        let createData = CreatePostData()
        let response = try testWorld.getResponse(to: createPostPath, body: createData, loggedInUser: initialPostData.author)

        XCTAssertEqual(testWorld.context.repository.posts.count, 2)
        let post = try XCTUnwrap(testWorld.context.repository.posts.last)
        XCTAssertEqual(post.slugUrl, "post-title-\(randomNumber)")
        XCTAssertEqual(response.http.headers[.location].first, "/posts/post-title-\(randomNumber)/")
    }

    func testPostCreationPageGetsBasicInfo() throws {
        _ = try testWorld.getResponse(to: createPostPath, loggedInUser: user)

        let isEditing = try XCTUnwrap(presenter.createPostIsEditing)
        XCTAssertFalse(isEditing)
    }

    func testPostCannotBeCreatedIfDraftAndPublishNotSet() throws {
        struct CreatePostData: Content {
            static let defaultContentType = MediaType.urlEncodedForm
            let title = "Post Title"
            let contents = "# Post Title\n\nWe have a post"
            let tags = ["First Tag", "Second Tag"]
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
            let publish = true
        }
        let createData = CreatePostData()
        _ = try testWorld.getResponse(to: createPostPath, body: createData, loggedInUser: user)

        let createPostErrors = try XCTUnwrap(presenter.createPostErrors)
        XCTAssertTrue(createPostErrors.contains("You must have some content in your blog post"))
    }

    func testPresenterGetsDataIfValidationOfDataFails() throws {
        struct CreatePostData: Content {
            static let defaultContentType = MediaType.urlEncodedForm
            let title = "Post Title"
            let tags = ["First Tag", "Second Tag"]
            let publish = true
            let contents = ""
        }
        let createData = CreatePostData()
        _ = try testWorld.getResponse(to: createPostPath, body: createData, loggedInUser: user)

        let createPostErrors = try XCTUnwrap(presenter.createPostErrors)
        XCTAssertTrue(createPostErrors.contains("You must have some content in your blog post"))
        XCTAssertEqual(presenter.createPostTags, createData.tags)
        XCTAssertEqual(presenter.createPostContents, createData.contents)
        XCTAssertEqual(presenter.createPostTitle, createData.title)
    }

    func testCreatePostWithDraftDoesNotPublishPost() throws {
        struct CreatePostData: Content {
            static let defaultContentType = MediaType.urlEncodedForm
            let title = "Post Title"
            let contents = "# Post Title\n\nWe have a post"
            let tags = ["First Tag", "Second Tag"]
            let draft = true
        }
        let createData = CreatePostData()
        _ = try testWorld.getResponse(to: createPostPath, body: createData, loggedInUser: user)

        XCTAssertEqual(testWorld.context.repository.posts.count, 1)
        let post = try XCTUnwrap(testWorld.context.repository.posts.first)
        XCTAssertEqual(post.title, createData.title)
        XCTAssertFalse(post.published)
    }

    func testCreatingPostWithExistingTagsDoesntDuplicateTag() throws {
        let existingPost = try testWorld.createPost()
        let existingTagName = "First Tag"
        let existingTag = try testWorld.createTag(existingTagName, on: existingPost.post)

        struct CreatePostData: Content {
            static let defaultContentType = MediaType.urlEncodedForm
            let title = "Post Title"
            let contents = "# Post Title\n\nWe have a post"
            let tags = ["First Tag", "Second Tag"]
            let publish = true
        }
        let createData = CreatePostData()
        _ = try testWorld.getResponse(to: createPostPath, body: createData, loggedInUser: user)

        let newPostID = testWorld.context.repository.posts.last?.blogID!

        XCTAssertNotEqual(existingPost.post.blogID, newPostID)
        XCTAssertEqual(testWorld.context.repository.tags.count, 2)
        XCTAssertTrue(testWorld.context.repository.postTagLinks
            .contains { $0.postID == newPostID && $0.tagID == existingTag.tagID! })
    }

    // MARK: - Post editing

    func testPostCanBeUpdated() throws {
        struct UpdatePostData: Content {
            static let defaultContentType = MediaType.urlEncodedForm
            let title = "Post Title"
            let contents = "# Post Title\n\nWe have a post"
            let tags = ["First Tag", "Second Tag"]
        }

        let testData = try testWorld.createPost(title: "Initial title", contents: "Some initial contents", slugUrl: "initial-title")
        let updateData = UpdatePostData()

        let updatePostPath = "/admin/posts/\(testData.post.blogID!)/edit"
        _ = try testWorld.getResponse(to: updatePostPath, body: updateData, loggedInUser: user)

        XCTAssertEqual(testWorld.context.repository.posts.count, 1)
        let post = try XCTUnwrap(testWorld.context.repository.posts.first)
        XCTAssertEqual(post.title, updateData.title)
        XCTAssertEqual(post.contents, updateData.contents)
        XCTAssertEqual(post.slugUrl, testData.post.slugUrl)
        XCTAssertEqual(post.blogID, testData.post.blogID)
        XCTAssertTrue(post.published)
    }

    func testPostCanBeUpdatedAndUpdateSlugURL() throws {
        struct UpdatePostData: Content {
            static let defaultContentType = MediaType.urlEncodedForm
            let title = "Post Title"
            let contents = "# Post Title\n\nWe have a post"
            let tags = ["First Tag", "Second Tag"]
            let updateSlugURL = true
        }

        let testData = try testWorld.createPost(title: "Initial title", contents: "Some initial contents", slugUrl: "initial-title")
        let updateData = UpdatePostData()

        let updatePostPath = "/admin/posts/\(testData.post.blogID!)/edit"
        _ = try testWorld.getResponse(to: updatePostPath, body: updateData, loggedInUser: user)

        let post = try XCTUnwrap(testWorld.context.repository.posts.first)
        XCTAssertEqual(post.slugUrl, "post-title")
    }

    func testEditPageGetsPostInfo() throws {
        let post = try testWorld.createPost().post
        let tag1Name = "Engineering"
        let tag2Name = "SteamPress"
        _ = try testWorld.createTag(tag1Name, on: post)
        _ = try testWorld.createTag(tag2Name, on: post)
        _ = try testWorld.getResponse(to: "/admin/posts/\(post.blogID!)/edit", loggedInUser: user)

        XCTAssertEqual(presenter.createPostTitle, post.title)
        XCTAssertEqual(presenter.createPostContents, post.contents)
        XCTAssertEqual(presenter.createPostSlugURL, post.slugUrl)
        let isEditing = try XCTUnwrap(presenter.createPostIsEditing)
        XCTAssertTrue(isEditing)
        XCTAssertEqual(presenter.createPostPost?.blogID, post.blogID)
        XCTAssertEqual(presenter.createPostDraft, !post.published)
        XCTAssertEqual(presenter.createPostTags?.count, 2)
        let postTags = try XCTUnwrap(presenter.createPostTags)
        XCTAssertTrue(postTags.contains(tag1Name))
        XCTAssertTrue(postTags.contains(tag2Name))
    }

    func testThatEditingPostGetsRedirectToPostPage() throws {
        let testData = try testWorld.createPost()

        struct UpdateData: Content {
            let title: String
            let contents = "Updated contents"
            let tags = [String]()
        }

        let updateData = UpdateData(title: testData.post.title)
        let response = try testWorld.getResponse(to: "/admin/posts/\(testData.post.blogID!)/edit", body: updateData, loggedInUser: user)

        XCTAssertEqual(response.http.status, .seeOther)
        XCTAssertEqual(response.http.headers[.location].first, "/posts/\(testData.post.slugUrl)/")
    }

    func testThatEditingPostGetsRedirectToPostPageWithNewSlugURL() throws {
        let testData = try testWorld.createPost()

        struct UpdateData: Content {
            let title: String
            let contents = "Updated contents"
            let tags = [String]()
            let updateSlugURL = true
        }

        let updateData = UpdateData(title: "Some New Title")
        let response = try testWorld.getResponse(to: "/admin/posts/\(testData.post.blogID!)/edit", body: updateData, loggedInUser: user)

        XCTAssertEqual(response.http.status, .seeOther)
        XCTAssertEqual(response.http.headers[.location].first, "/posts/some-new-title/")
    }

    func testEditingPostWithNewTagsRemovesOldLinksAndAddsNewLinks() throws {
        let post = try testWorld.createPost(title: "Initial title", contents: "Some initial contents", slugUrl: "initial-title").post
        let firstTagName = "Some Tag"
        let secondTagName = "Engineering"
        let firstTag = try testWorld.createTag(firstTagName, on: post)
        let secondTag = try testWorld.createTag(secondTagName, on: post)

        let newTagName = "A New Tag"

        struct UpdatePostData: Content {
            static let defaultContentType = MediaType.urlEncodedForm
            let title = "Post Title"
            let contents = "# Post Title\n\nWe have a post"
            let tags: [String]
        }

        let updateData = UpdatePostData(tags: [firstTagName, newTagName])

        let updatePostPath = "/admin/posts/\(post.blogID!)/edit"
        _ = try testWorld.getResponse(to: updatePostPath, body: updateData, loggedInUser: user)

        XCTAssertTrue(testWorld.context.repository.postTagLinks
            .contains { $0.postID == post.blogID! && $0.tagID == firstTag.tagID! })
        XCTAssertFalse(testWorld.context.repository.postTagLinks
            .contains { $0.postID == post.blogID! && $0.tagID == secondTag.tagID! })
        let newTag = try XCTUnwrap(testWorld.context.repository.tags.first { $0.name.removingPercentEncoding == newTagName })
        XCTAssertTrue(testWorld.context.repository.postTagLinks
            .contains { $0.postID == post.blogID! && $0.tagID == newTag.tagID! })
        XCTAssertEqual(testWorld.context.repository.tags.filter { $0.name.removingPercentEncoding == firstTagName}.count, 1)
    }

    func testLastUpdatedTimeGetsChangedWhenEditingAPost() throws {
        struct UpdatePostData: Content {
            static let defaultContentType = MediaType.urlEncodedForm
            let title = "Post Title"
            let contents = "# Post Title\n\nWe have a post"
            let tags = ["First Tag", "Second Tag"]
        }

        let testData = try testWorld.createPost(title: "Initial title", contents: "Some initial contents", slugUrl: "initial-title")

        let updateData = UpdatePostData()

        let updatePostPath = "/admin/posts/\(testData.post.blogID!)/edit"
        _ = try testWorld.getResponse(to: updatePostPath, body: updateData, loggedInUser: user)

        let post = try XCTUnwrap(testWorld.context.repository.posts.first)
        let postLastEdited = try XCTUnwrap(post.lastEdited)
        XCTAssertEqual(postLastEdited.timeIntervalSince1970, Date().timeIntervalSince1970, accuracy: 0.1)
        XCTAssertTrue(postLastEdited > post.created)
    }

    func testCreatedTimeSetWhenPublishingADraft() throws {
        struct UpdatePostData: Content {
            static let defaultContentType = MediaType.urlEncodedForm
            let title = "Post Title"
            let contents = "# Post Title\n\nWe have a post"
            let tags = ["First Tag", "Second Tag"]
            let publish = true
        }

        let testData = try testWorld.createPost(title: "Initial title", contents: "Some initial contents", slugUrl: "initial-title", published: false)

        let updateData = UpdatePostData()

        let updatePostPath = "/admin/posts/\(testData.post.blogID!)/edit"
        _ = try testWorld.getResponse(to: updatePostPath, body: updateData, loggedInUser: user)

        let post = try XCTUnwrap(testWorld.context.repository.posts.first)
        XCTAssertEqual(post.created.timeIntervalSince1970, Date().timeIntervalSince1970, accuracy: 0.1)
        XCTAssertTrue(post.published)
        XCTAssertNil(post.lastEdited)
    }

    func testCreatedTimeSetAndMarkedAsDraftWhenSavingADraft() throws {
        struct UpdatePostData: Content {
            static let defaultContentType = MediaType.urlEncodedForm
            let title = "Post Title"
            let contents = "# Post Title\n\nWe have a post"
            let tags = ["First Tag", "Second Tag"]
            let draft = true
        }

        let testData = try testWorld.createPost(title: "Initial title", contents: "Some initial contents", slugUrl: "initial-title", published: false)

        let updateData = UpdatePostData()

        let updatePostPath = "/admin/posts/\(testData.post.blogID!)/edit"
        _ = try testWorld.getResponse(to: updatePostPath, body: updateData, loggedInUser: user)

        let post = try XCTUnwrap(testWorld.context.repository.posts.first)
        XCTAssertFalse(post.published)
        XCTAssertNil(post.lastEdited)
        XCTAssertEqual(post.created.timeIntervalSince1970, Date().timeIntervalSince1970, accuracy: 0.1)
    }

    func testEditingPageWithInvalidDataPassesExistingDataToPresenter() throws {
        struct UpdatePostData: Content {
            static let defaultContentType = MediaType.urlEncodedForm
            let title = ""
            let contents = "# Post Title\n\nWe have a post"
            let tags = ["First Tag", "Second Tag"]
        }

        let testData = try testWorld.createPost(title: "Initial title", contents: "Some initial contents", slugUrl: "initial-title")
        let updateData = UpdatePostData()

        let updatePostPath = "/admin/posts/\(testData.post.blogID!)/edit"
        _ = try testWorld.getResponse(to: updatePostPath, body: updateData, loggedInUser: user)

        XCTAssertEqual(presenter.createPostTitle, "")
        XCTAssertEqual(presenter.createPostPost?.blogID, testData.post.blogID)
        XCTAssertEqual(presenter.createPostContents, updateData.contents)
        XCTAssertEqual(presenter.createPostSlugURL, testData.post.slugUrl)
        XCTAssertEqual(presenter.createPostTags, updateData.tags)
        XCTAssertEqual(presenter.createPostIsEditing, true)
        XCTAssertEqual(presenter.createPostDraft, false)
        let createPostErrors = try XCTUnwrap(presenter.createPostErrors)
        XCTAssertTrue(createPostErrors.contains("You must specify a blog post title"))
    }

    // MARK: - Post Deletion

    func testCanDeleteBlogPost() throws {
        let testData = try testWorld.createPost()
        let response = try testWorld.getResponse(to: "/admin/posts/\(testData.post.blogID!)/delete", method: .POST, body: EmptyContent(), loggedInUser: user)

        XCTAssertEqual(response.http.status, .seeOther)
        XCTAssertEqual(response.http.headers[.location].first, "/admin/")
        XCTAssertEqual(testWorld.context.repository.posts.count, 0)
    }

    func testDeletingBlogPostRemovesTagLinks() throws {
        let testData = try testWorld.createPost()
        _ = try testWorld.createTag(on: testData.post)
        _ = try testWorld.createTag("SteamPress", on: testData.post)

        XCTAssertEqual(testWorld.context.repository.postTagLinks.count, 2)

        _ = try testWorld.getResponse(to: "/admin/posts/\(testData.post.blogID!)/delete", method: .POST, body: EmptyContent(), loggedInUser: user)

        XCTAssertEqual(testWorld.context.repository.postTagLinks.count, 0)
    }

    // MARK: - Slug URL Generation

    func testThatSlugUrlCalculatedCorrectlyForTitleWithSpaces() throws {
        let title = "This is a title"
        let expectedSlugUrl = "this-is-a-title"
        let post = try createPostViaRequest(title: title)
        XCTAssertEqual(post.slugUrl, expectedSlugUrl)
    }

    func testThatSlugUrlCalculatedCorrectlyForTitleWithPunctuation() throws {
        let title = "This is an awesome post!"
        let expectedSlugUrl = "this-is-an-awesome-post"
        let post = try createPostViaRequest(title: title)
        XCTAssertEqual(expectedSlugUrl, post.slugUrl)
    }

    func testThatSlugUrlStripsWhitespace() throws {
        let title = "    Title  "
        let expectedSlugUrl = "title"
        let post = try createPostViaRequest(title: title)
        XCTAssertEqual(expectedSlugUrl, post.slugUrl)
    }

    func testNumbersRemainInUrl() throws {
        let title = "The 2nd url"
        let expectedSlugUrl = "the-2nd-url"
        let post = try createPostViaRequest(title: title)
        XCTAssertEqual(expectedSlugUrl, post.slugUrl)
    }

    func testSlugUrlLowerCases() throws {
        let title = "AN AMAZING POST"
        let expectedSlugUrl = "an-amazing-post"
        let post = try createPostViaRequest(title: title)
        XCTAssertEqual(expectedSlugUrl, post.slugUrl)
    }

    func testEverythingWithLotsOfCharacters() throws {
        let title = " This should remove! \nalmost _all_ of the @ punctuation, but it doesn't?"
        let expectedSlugUrl = "this-should-remove-almost-all-of-the-punctuation-but-it-doesnt"
        let post = try createPostViaRequest(title: title)
        XCTAssertEqual(expectedSlugUrl, post.slugUrl)
    }

    // MARK: - Helpers

    private func createPostViaRequest(title: String) throws -> BlogPost {
        struct CreatePostData: Content {
            static let defaultContentType = MediaType.urlEncodedForm
            let title: String
            let contents = "# Post Title\n\nWe have a post"
            let tags = ["First Tag", "Second Tag"]
            let publish = true
        }
        let createData = CreatePostData(title: title)
        _ = try testWorld.getResponse(to: createPostPath, body: createData, loggedInUser: user)

        let post = try XCTUnwrap(testWorld.context.repository.posts.first)
        return post
    }

}
