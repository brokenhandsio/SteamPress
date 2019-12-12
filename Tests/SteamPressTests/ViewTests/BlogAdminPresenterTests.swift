import XCTest
@testable import SteamPress
import Vapor

class BlogAdminPresenterTests: XCTestCase {
    
    // MARK: - Properties
    var basicContainer: BasicContainer!
    var presenter: ViewBlogAdminPresenter!
    var viewRenderer: CapturingViewRenderer!
    
    private let currentUser = TestDataBuilder.anyUser(id: 0)
    private let websiteURL = URL(string: "https://brokenhands.io")!
    private let resetPasswordURL = URL(string: "https://brokenhands.io/blog/admin/resetPassword")!
    private let adminPageURL = URL(string: "https://brokenhands.io/blog/admin")!
    private let createUserPageURL = URL(string: "https://brokenhands.io/blog/admin/createUser")!
    private let editUserPageURL = URL(string: "https://brokenhands.io/blog/admin/users/0/edit")!
    private let createBlogPageURL = URL(string: "https://brokenhands.io/blog/admin/createPost")!
    private let editPostPageURL = URL(string: "https://brokenhands.io/blog/admin/posts/0/edit")!
    
    private static let siteTwitterHandle = "brokenhandsio"
    private static let disqusName = "steampress"
    private static let googleAnalyticsIdentifier = "UA-12345678-1"
    
    // MARK: - Overrides
    
    override func setUp() {
        presenter = ViewBlogAdminPresenter(pathCreator: BlogPathCreator(blogPath: "blog"))
        basicContainer = BasicContainer(config: Config.default(), environment: Environment.testing, services: .init(), on: EmbeddedEventLoop())
        basicContainer.services.register(ViewRenderer.self) { _ in
            return self.viewRenderer
        }
        viewRenderer = CapturingViewRenderer(worker: basicContainer)
    }
    
    // MARK: - Tests
    
    // MARK: - Reset Password
    
    func testPasswordViewGivenCorrectParameters() throws {
        let pageInformation = buildPageInformation(currentPageURL: resetPasswordURL)
        _ = presenter.createResetPasswordView(on: basicContainer, errors: nil, passwordError: nil, confirmPasswordError: nil, pageInformation: pageInformation)
        
        let context = try XCTUnwrap(viewRenderer.capturedContext as? ResetPasswordPageContext)
        XCTAssertNil(context.errors)
        XCTAssertNil(context.passwordError)
        XCTAssertNil(context.confirmPasswordError)
        XCTAssertEqual(context.pageInformation.loggedInUser.username, currentUser.username)
        XCTAssertEqual(context.pageInformation.websiteURL.absoluteString, "https://brokenhands.io")
        XCTAssertEqual(context.pageInformation.currentPageURL.absoluteString, "https://brokenhands.io/blog/admin/resetPassword")
        XCTAssertEqual(viewRenderer.templatePath, "blog/admin/resetPassword")
    }

    func testPasswordViewHasCorrectParametersWhenError() throws {
        let expectedError = "Passwords do not match"
        let pageInformation = buildPageInformation(currentPageURL: resetPasswordURL)
        _ = presenter.createResetPasswordView(on: basicContainer, errors: [expectedError], passwordError: true, confirmPasswordError: true, pageInformation: pageInformation)
        
        let context = try XCTUnwrap(viewRenderer.capturedContext as? ResetPasswordPageContext)
        XCTAssertEqual(context.errors?.count, 1)
        XCTAssertEqual(context.errors?.first, expectedError)
        let passwordError = try XCTUnwrap(context.passwordError)
        let confirmPasswordError = try XCTUnwrap(context.confirmPasswordError)
        XCTAssertTrue(passwordError)
        XCTAssertTrue(confirmPasswordError)
    }
    
    // MARK: - Admin Page

    func testBlogAdminViewGetsCorrectParameters() throws {
        let draftPost = try TestDataBuilder.anyPost(author: currentUser, title: "[DRAFT] This will be awesome", published: false)
        let post = try TestDataBuilder.anyPost(author: currentUser)
        
        let pageInformation = buildPageInformation(currentPageURL: adminPageURL)
        _ = presenter.createIndexView(on: basicContainer, posts: [draftPost, post], users: [currentUser], errors: nil, pageInformation: pageInformation)
        
        let context = try XCTUnwrap(viewRenderer.capturedContext as? AdminPageContext)
        
        XCTAssertEqual(viewRenderer.templatePath, "blog/admin/index")
        XCTAssertTrue(context.blogAdminPage)
        XCTAssertEqual(context.title, "Blog Admin")
        XCTAssertNil(context.errors)
        XCTAssertEqual(context.publishedPosts.count, 1)
        XCTAssertEqual(context.publishedPosts.first?.title, post.title)
        XCTAssertEqual(context.draftPosts.count, 1)
        XCTAssertEqual(context.draftPosts.first?.title, draftPost.title)
        XCTAssertEqual(context.users.count, 1)
        XCTAssertEqual(context.users.first?.name, currentUser.name)
        
        XCTAssertEqual(context.pageInformation.loggedInUser.name, currentUser.name)
        XCTAssertEqual(context.pageInformation.currentPageURL.absoluteString, "https://brokenhands.io/blog/admin")
        XCTAssertEqual(context.pageInformation.websiteURL.absoluteString, "https://brokenhands.io")
    }

    func testAdminPageWithErrors() throws {
        let expectedError = "You cannot delete yourself!"
        let pageInformation = buildPageInformation(currentPageURL: adminPageURL)
        _ = presenter.createIndexView(on: basicContainer, posts: [], users: [], errors: [expectedError], pageInformation: pageInformation)
        
        let context = try XCTUnwrap(viewRenderer.capturedContext as? AdminPageContext)
        XCTAssertEqual(context.errors?.first, expectedError)
    }
    
    // MARK: - Create/Edit User Page

    func testCreateUserViewGetsCorrectParameters() throws {
        let pageInformation = buildPageInformation(currentPageURL: createUserPageURL)
        _ = presenter.createUserView(on: basicContainer, editing: false, errors: nil, name: nil, nameError: false, username: nil, usernameErorr: false, passwordError: false, confirmPasswordError: false, resetPasswordOnLogin: false, userID: nil, profilePicture: nil, twitterHandle: nil, biography: nil, tagline: nil, pageInformation: pageInformation)
        
        let context = try XCTUnwrap(viewRenderer.capturedContext as? CreateUserPageContext)
        
        XCTAssertEqual(context.title, "Create User")
        XCTAssertFalse(context.editing)
        XCTAssertNil(context.errors)
        XCTAssertNil(context.nameSupplied)
        XCTAssertFalse(context.nameError)
        XCTAssertNil(context.usernameSupplied)
        XCTAssertFalse(context.usernameError)
        XCTAssertFalse(context.passwordError)
        XCTAssertFalse(context.confirmPasswordError)
        XCTAssertFalse(context.resetPasswordOnLoginSupplied)
        XCTAssertNil(context.userID)
        XCTAssertNil(context.twitterHandleSupplied)
        XCTAssertNil(context.profilePictureSupplied)
        XCTAssertNil(context.taglineSupplied)
        XCTAssertNil(context.biographySupplied)
        XCTAssertEqual(viewRenderer.templatePath, "blog/admin/createUser")
        
        XCTAssertEqual(context.pageInformation.currentPageURL.absoluteString, "https://brokenhands.io/blog/admin/createUser")
        XCTAssertEqual(context.pageInformation.websiteURL.absoluteString, "https://brokenhands.io")
        XCTAssertEqual(context.pageInformation.loggedInUser.name, currentUser.name)
    }

    func testCreateUserViewWhenErrors() throws {
        let expectedError = "Not valid password"
        let expectedName = "Luke"
        let expectedUsername = "luke"
        let expectedProfilePicture = "https://static.brokenhands.io/steampress/images/authors/luke.png"
        let expectedTwitterHandler = "luke"
        let expectedBiography = "The last Jedi in the Galaxy"
        let expectedTagline = "A son without a father"
        let pageInformation = buildPageInformation(currentPageURL: createUserPageURL)
        
        _ = presenter.createUserView(on: basicContainer, editing: false, errors: [expectedError], name: expectedName, nameError: false, username: expectedUsername, usernameErorr: false, passwordError: true, confirmPasswordError: true, resetPasswordOnLogin: true, userID: nil, profilePicture: expectedProfilePicture, twitterHandle: expectedTwitterHandler, biography: expectedBiography, tagline: expectedTagline, pageInformation: pageInformation)
       
        let context = try XCTUnwrap(viewRenderer.capturedContext as? CreateUserPageContext)
        XCTAssertEqual(context.errors?.count, 1)
        XCTAssertEqual(context.errors?.first, expectedError)
        XCTAssertEqual(context.nameSupplied, expectedName)
        XCTAssertFalse(context.nameError)
        XCTAssertEqual(context.usernameSupplied, expectedUsername)
        XCTAssertFalse(context.usernameError)
        XCTAssertTrue(context.passwordError)
        XCTAssertTrue(context.confirmPasswordError)
        XCTAssertTrue(context.resetPasswordOnLoginSupplied)
        XCTAssertEqual(context.profilePictureSupplied, expectedProfilePicture)
        XCTAssertEqual(context.twitterHandleSupplied, expectedTwitterHandler)
        XCTAssertEqual(context.taglineSupplied, expectedTagline)
        XCTAssertEqual(context.biographySupplied, expectedBiography)
    }

    func testCreateUserViewWhenNoNameOrUsernameSupplied() throws {
        let expectedError = "No name supplied"
        let pageInformation = buildPageInformation(currentPageURL: createUserPageURL)
        
        _ = presenter.createUserView(on: basicContainer, editing: false, errors: [expectedError], name: nil, nameError: true, username: nil, usernameErorr: true, passwordError: false, confirmPasswordError: false, resetPasswordOnLogin: true, userID: nil, profilePicture: nil, twitterHandle: nil, biography: nil, tagline: nil, pageInformation: pageInformation)
        
        let context = try XCTUnwrap(viewRenderer.capturedContext as? CreateUserPageContext)
        XCTAssertNil(context.nameSupplied)
        XCTAssertTrue(context.nameError)
        XCTAssertNil(context.usernameSupplied)
        XCTAssertTrue(context.usernameError)
    }

    func testCreateUserViewForEditing() throws {
        let pageInformation = buildPageInformation(currentPageURL: editUserPageURL)
        _ = presenter.createUserView(on: basicContainer, editing: true, errors: nil, name: currentUser.name, nameError: false, username: currentUser.username, usernameErorr: false, passwordError: false, confirmPasswordError: false, resetPasswordOnLogin: false, userID: currentUser.userID, profilePicture: currentUser.profilePicture, twitterHandle: currentUser.twitterHandle, biography: currentUser.biography, tagline: currentUser.tagline, pageInformation: pageInformation)
        let context = try XCTUnwrap(viewRenderer.capturedContext as? CreateUserPageContext)
        XCTAssertEqual(context.nameSupplied, currentUser.name)
        XCTAssertFalse(context.nameError)
        XCTAssertEqual(context.usernameSupplied, currentUser.username)
        XCTAssertFalse(context.usernameError)
        XCTAssertFalse(context.passwordError)
        XCTAssertFalse(context.confirmPasswordError)
        XCTAssertFalse(context.resetPasswordOnLoginSupplied)
        XCTAssertEqual(context.profilePictureSupplied, currentUser.profilePicture)
        XCTAssertEqual(context.twitterHandleSupplied, currentUser.twitterHandle)
        XCTAssertEqual(context.taglineSupplied, currentUser.tagline)
        XCTAssertEqual(context.biographySupplied, currentUser.biography)
        XCTAssertEqual(context.userID, currentUser.userID)
        XCTAssertTrue(context.editing)
        
        XCTAssertEqual(viewRenderer.templatePath, "blog/admin/createUser")
        XCTAssertEqual(context.pageInformation.loggedInUser.name, currentUser.name)
        XCTAssertEqual(context.pageInformation.websiteURL.absoluteString, "https://brokenhands.io")
        XCTAssertEqual(context.pageInformation.currentPageURL.absoluteString, "https://brokenhands.io/blog/admin/users/0/edit")
    }

    func testCreateUserViewThrowsWhenTryingToEditWithoutUserId() throws {
        let pageInformation = buildPageInformation(currentPageURL: editUserPageURL)
        var errored = false
        
        do {
            _ = try presenter.createUserView(on: basicContainer, editing: true, errors: [], name: currentUser.name, nameError: false, username: currentUser.username, usernameErorr: false, passwordError: false, confirmPasswordError: false, resetPasswordOnLogin: false, userID: nil, profilePicture: currentUser.profilePicture, twitterHandle: currentUser.twitterHandle, biography: currentUser.biography, tagline: currentUser.tagline, pageInformation: pageInformation).wait()
        } catch {
            errored = true
        }
        XCTAssertTrue(errored)
    }

    
    // MARK: - Create/Edit Blog Post
    
    func testCreateBlogPostViewGetsCorrectParameters() throws {
        let pageInformation = buildPageInformation(currentPageURL: createBlogPageURL)
        _ = presenter.createPostView(on: basicContainer, errors: nil, title: nil, contents: nil, slugURL: nil, tags: nil, isEditing: false, post: nil, isDraft: nil, titleError: false, contentsError: false, pageInformation: pageInformation)
        
        let context = try XCTUnwrap(viewRenderer.capturedContext as? CreatePostPageContext)
        
        XCTAssertEqual(context.title, "Create Blog Post")
        XCTAssertFalse(context.editing)
        XCTAssertNil(context.post)
        XCTAssertFalse(context.draft)
        XCTAssertNil(context.tagsSupplied)
        XCTAssertNil(context.errors)
        XCTAssertNil(context.titleSupplied)
        XCTAssertNil(context.contentsSupplied)
        XCTAssertNil(context.slugURLSupplied)
        XCTAssertFalse(context.titleError)
        XCTAssertFalse(context.contentsError)
        XCTAssertEqual(context.postPathPrefix, "https://brokenhands.io/blog/posts/")
        
        XCTAssertEqual(context.pageInformation.websiteURL.absoluteString, "https://brokenhands.io")
        XCTAssertEqual(context.pageInformation.currentPageURL.absoluteString, "https://brokenhands.io/blog/admin/createPost")
        XCTAssertEqual(context.pageInformation.loggedInUser.name, currentUser.name)
        
        XCTAssertEqual(viewRenderer.templatePath, "blog/admin/createPost")
    }
    
    func testCreateBlogPostViewWithErrorsAndNoTitleOrContentsSupplied() throws {
        let expectedError = "Please enter a title"
        
        let pageInformation = buildPageInformation(currentPageURL: createBlogPageURL)
        _ = presenter.createPostView(on: basicContainer, errors: [expectedError], title: nil, contents: nil, slugURL: nil, tags: nil, isEditing: false, post: nil, isDraft: nil, titleError: true, contentsError: true, pageInformation: pageInformation)
        
        let context = try XCTUnwrap(viewRenderer.capturedContext as? CreatePostPageContext)

        XCTAssertTrue(context.titleError)
        XCTAssertTrue(context.contentsError)
        XCTAssertEqual(context.errors?.count, 1)
        XCTAssertEqual(context.errors?.first, expectedError)
        
        XCTAssertEqual(context.pageInformation.websiteURL.absoluteString, "https://brokenhands.io")
        XCTAssertEqual(context.pageInformation.currentPageURL.absoluteString, "https://brokenhands.io/blog/admin/createPost")
        XCTAssertEqual(context.pageInformation.loggedInUser.name, currentUser.name)
    }

    func testCreateBlogPostViewWhenEditing() throws {
        let postToEdit = try TestDataBuilder.anyPost(author: currentUser)
        let tag = "Engineering"
        let pageInformation = buildPageInformation(currentPageURL: editPostPageURL)
        
        _ = presenter.createPostView(on: basicContainer, errors: nil, title: postToEdit.title, contents: postToEdit.contents, slugURL: postToEdit.slugUrl, tags: [tag], isEditing: true, post: postToEdit, isDraft: false, titleError: false, contentsError: false, pageInformation: pageInformation)
        
        let context = try XCTUnwrap(viewRenderer.capturedContext as? CreatePostPageContext)
        
        XCTAssertEqual(context.title, "Edit Blog Post")
        XCTAssertTrue(context.editing)
        XCTAssertEqual(context.titleSupplied, postToEdit.title)
        XCTAssertEqual(context.contentsSupplied, postToEdit.contents)
        XCTAssertEqual(context.slugURLSupplied, postToEdit.slugUrl)
        XCTAssertEqual(context.post?.title, postToEdit.title)
        XCTAssertEqual(context.post?.blogID, postToEdit.blogID)
        XCTAssertFalse(context.draft)
        XCTAssertEqual(context.tagsSupplied?.count, 1)
        XCTAssertEqual(context.tagsSupplied?.first, tag)
        XCTAssertNil(context.errors)
        XCTAssertFalse(context.titleError)
        XCTAssertFalse(context.contentsError)
        XCTAssertEqual(context.postPathPrefix, "https://brokenhands.io/blog/posts/")
        
        XCTAssertEqual(context.pageInformation.websiteURL.absoluteString, "https://brokenhands.io")
        XCTAssertEqual(context.pageInformation.currentPageURL.absoluteString, "https://brokenhands.io/blog/admin/posts/0/edit")
        XCTAssertEqual(context.pageInformation.loggedInUser.name, currentUser.name)
        
        XCTAssertEqual(viewRenderer.templatePath, "blog/admin/createPost")
    }

    func testEditBlogPostViewThrowsWithNoPostToEdit() throws {
        var errored = false
        do {
            let pageInformation = buildPageInformation(currentPageURL: editPostPageURL)
            _ = try presenter.createPostView(on: basicContainer, errors: nil, title: nil, contents: nil, slugURL: nil, tags: nil, isEditing: true, post: nil, isDraft: nil, titleError: false, contentsError: false, pageInformation: pageInformation).wait()
        } catch {
            errored = true
        }

        XCTAssertTrue(errored)
    }

    func testDraftPassedThroughWhenEditingABlogPostThatHasNotBeenPublished() throws {
        let draftPost = try TestDataBuilder.anyPost(author: currentUser, published: false)
        let pageInformation = buildPageInformation(currentPageURL: editPostPageURL)
        
        _ = presenter.createPostView(on: basicContainer, errors: nil, title: draftPost.title, contents: draftPost.contents, slugURL: draftPost.slugUrl, tags: nil, isEditing: true, post: draftPost, isDraft: true, titleError: false, contentsError: false, pageInformation: pageInformation)
        let context = try XCTUnwrap(viewRenderer.capturedContext as? CreatePostPageContext)
        
        XCTAssertTrue(context.draft)
    }
    
    // MARK: - Helpers
    
    private func buildPageInformation(currentPageURL: URL, user: BlogUser? = nil) -> BlogAdminPageInformation {
        let loggedInUser: BlogUser
        if let user = user {
            loggedInUser = user
        } else {
            loggedInUser = currentUser
        }
        return BlogAdminPageInformation(loggedInUser: loggedInUser, websiteURL: websiteURL, currentPageURL: currentPageURL)
    }
}
