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

//    func testCreateBlogPostViewWhenEditing() throws {
//        let author = TestDataBuilder.anyUser()
//        try author.save()
//        let postToEdit = TestDataBuilder.anyPost(author: author)
//        try postToEdit.save()
//        let _ = try viewFactory.createBlogPostView(uri: editPostURI, title: postToEdit.title, contents: postToEdit.contents, slugUrl: postToEdit.slugUrl, tags: [Node(node: "test")], isEditing: true, postToEdit: postToEdit, user: author)
//        XCTAssertEqual(viewRenderer.capturedContext?["post_path_prefix"]?.string, "https://test.com/posts/")
//        XCTAssertFalse((viewRenderer.capturedContext?["title_error"]?.bool) ?? true)
//        XCTAssertFalse((viewRenderer.capturedContext?["contents_error"]?.bool) ?? true)
//        XCTAssertNil(viewRenderer.capturedContext?["errors"])
//        XCTAssertEqual(viewRenderer.capturedContext?["title_supplied"]?.string, postToEdit.title)
//        XCTAssertEqual(viewRenderer.capturedContext?["contents_supplied"]?.string, postToEdit.contents)
//        XCTAssertEqual(viewRenderer.capturedContext?["slug_url_supplied"]?.string, postToEdit.slugUrl)
//        XCTAssertEqual(viewRenderer.capturedContext?["tags_supplied"]?.array?.count, 1)
//        XCTAssertEqual(viewRenderer.capturedContext?["tags_supplied"]?.array?.first?.string, "test")
//        XCTAssertTrue((viewRenderer.capturedContext?["editing"]?.bool) ?? false)
//        XCTAssertEqual(viewRenderer.capturedContext?["post"]?["title"]?.string, postToEdit.title)
//        XCTAssertNil(viewRenderer.capturedContext?["create_blog_post_page"])
//        XCTAssertEqual(viewRenderer.capturedContext?["post"]?["published"]?.bool, true)
//        XCTAssertEqual(viewRenderer.capturedContext?["user"]?["name"]?.string, author.name)
//    }

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

//
//    func testDraftPassedThroughWhenEditingABlogPostThatHasNotBeenPublished() throws {
//        let author = TestDataBuilder.anyUser()
//        try author.save()
//        let postToEdit = TestDataBuilder.anyPost(author: author, published: false)
//        try postToEdit.save()
//        let _ = try viewFactory.createBlogPostView(uri: editPostURI, title: postToEdit.title, contents: postToEdit.contents, slugUrl: postToEdit.slugUrl, tags: [Node(node: "test")], isEditing: true, postToEdit: postToEdit, user: TestDataBuilder.anyUser())
//        XCTAssertEqual(viewRenderer.capturedContext?["post"]?["published"]?.bool, false)
//    }
//
//    func testSiteURIForHTTPDoesNotContainPort() throws {
//        let (postWithImage, user) = try setupBlogPost()
//        let httpURI = URI(scheme: "http", hostname: "test.com", path: "posts/test-post/")
//        _ = try viewFactory.blogPostView(uri: httpURI, post: postWithImage, author: user, user: nil)
//
//        XCTAssertEqual(viewRenderer.capturedContext?["site_uri"]?.string, "http://test.com/")
//    }

//func testTagPageGetsUri() throws {
//    _ = try testWorld.getResponse(to: tagRequestPath)
//    XCTAssertEqual(presenter.tagURL?.description, tagRequestPath)
//}
//
//func testTagPageGetsHTTPSUriFromReverseProxy() throws {
    //            try setupDrop()
    //
    //            let httpsReverseProxyRequest = Request(method: .get, uri: "http://geeks.brokenhands.io\(tagPath)")
    //            httpsReverseProxyRequest.headers["X-Forwarded-Proto"] = "https"
    //
    //            _ = try drop.respond(to: httpsReverseProxyRequest)
    //
    //            XCTAssertEqual("https://geeks.brokenhands.io/tags/tatooine/", viewFactory.tagURI?.descriptionWithoutPort)
//    #warning("Implement")
//}
//
//func testAllTagsPageGetsUri() throws {
//    _ = try testWorld.getResponse(to: allTagsRequestPath)
//    XCTAssertEqual(presenter.allTagsURL?.description, allTagsRequestPath)
//}
//
//func testAllTagsPageGetsHTTPSUriFromReverseProxy() throws {
    //            try setupDrop()
    //
    //            let httpsReverseProxyRequest = Request(method: .get, uri: "http://geeks.brokenhands.io\(allTagsPath)")
    //            httpsReverseProxyRequest.headers["X-Forwarded-Proto"] = "https"
    //
    //            _ = try drop.respond(to: httpsReverseProxyRequest)
    //
    //            XCTAssertEqual("https://geeks.brokenhands.io/tags/", viewFactory.allTagsURI?.descriptionWithoutPort)
//    #warning("Implement")
//}
//func testAllAuthorsPageGetsUri() throws {
//    _ = try testWorld.getResponse(to: allAuthorsRequestPath)
//    XCTAssertEqual(presenter.allAuthorsURL?.description, allAuthorsRequestPath)
//}
//
//func testAllAuthorsPageGetsHTTPSUriFromReverseProxy() throws {
//    //        try setupDrop()
//    //
//    //        let httpsReverseProxyRequest = Request(method: .get, uri: "http://geeks.brokenhands.io\(allAuthorsPath)")
//    //        httpsReverseProxyRequest.headers["X-Forwarded-Proto"] = "https"
//    //
//    //        _ = try drop.respond(to: httpsReverseProxyRequest)
//    //
//    //        XCTAssertEqual("https://geeks.brokenhands.io/authors/", viewFactory.allAuthorsURI?.descriptionWithoutPort)
//    XCTFail("Implement")
//}
//func testProfilePageGetsUri() throws {
//    _ = try testWorld.getResponse(to: authorsRequestPath)
//
//    XCTAssertEqual(presenter.authorURL?.description, authorsRequestPath)
//}
//
//func testProfilePageGetsHTTPSUriFromReverseProxy() throws {
//    //        try setupDrop()
//    //
//    //        let httpsReverseProxyRequest = Request(method: .get, uri: "http://geeks.brokenhands.io\(authorPath)")
//    //        httpsReverseProxyRequest.headers["X-Forwarded-Proto"] = "https"
//    //
//    //        _ = try drop.respond(to: httpsReverseProxyRequest)
//    //
//    //        XCTAssertEqual("https://geeks.brokenhands.io/authors/luke/", viewFactory.authorURI?.descriptionWithoutPort)
//    #warning("Implement")
//}
//func testIndexPageGetsUri() throws {
//        try setupDrop()
//
//        _ = try drop.respond(to: blogIndexRequest)
//
//        XCTAssertEqual(blogIndexPath, viewFactory.blogIndexURI?.description)
//    }
//
//    func testIndexPageGetsHTTPSUriFromReverseProxy() throws {
//        try setupDrop()
//
//        let httpsReverseProxyRequest = Request(method: .get, uri: "http://geeks.brokenhands.io\(blogIndexPath)")
//        httpsReverseProxyRequest.headers["X-Forwarded-Proto"] = "https"
//
//        _ = try drop.respond(to: httpsReverseProxyRequest)
//
//        XCTAssertEqual("https://geeks.brokenhands.io/", viewFactory.blogIndexURI?.descriptionWithoutPort)
//    }
//
//    func testBlogPageGetsUri() throws {
//        try setupDrop()
//
//        _ = try drop.respond(to: blogPostRequest)
//
//        XCTAssertEqual(blogPostPath, viewFactory.blogPostURI?.description)
//    }
//
//    func testHTTPSPassedThroughToBlogPageURI() throws {
//        try setupDrop()
//
//        let httpsRequest = Request(method: .get, uri: "https://localhost\(blogPostPath)")
//        _ = try drop.respond(to: httpsRequest)
//
//        XCTAssertEqual("https://localhost/posts/test-path/", viewFactory.blogPostURI?.descriptionWithoutPort)
//    }
//
//    func testHTTPSURIPassedThroughAsBlogPageURIIfAccessingViaReverseProxyOverHTTPS() throws {
//        try setupDrop()
//
//        let httpsReverseProxyRequest = Request(method: .get, uri: "http://geeks.brokenhands.io\(blogPostPath)")
//        httpsReverseProxyRequest.headers["X-Forwarded-Proto"] = "https"
//
//        _ = try drop.respond(to: httpsReverseProxyRequest)
//
//        XCTAssertEqual("https://geeks.brokenhands.io/posts/test-path/", viewFactory.blogPostURI?.descriptionWithoutPort)
//    }
//
//    func testBlogPostPageGetHTPSURIFromReverseProxyLowerCase() throws {
//        try setupDrop()
//
//        let httpsReverseProxyRequest = Request(method: .get, uri: "http://geeks.brokenhands.io\(blogPostPath)")
//        httpsReverseProxyRequest.headers["x-forwarded-proto"] = "https"
//
//        _ = try drop.respond(to: httpsReverseProxyRequest)
//
//        XCTAssertEqual("https://geeks.brokenhands.io/posts/test-path/", viewFactory.blogPostURI?.descriptionWithoutPort)
//    }
//    func testAdminPageGetsLoggedInUser() throws {
//        let request = try createLoggedInRequest(method: .get, path: "", for: user)
//        _ = try drop.respond(to: request)
//
//        XCTAssertEqual(user.name, capturingViewFactory.adminUser?.name)
//    }
//
//    func testCreatePostPageGetsLoggedInUser() throws {
//        let request = try createLoggedInRequest(method: .get, path: "createPost", for: user)
//        _ = try drop.respond(to: request)
//
//        XCTAssertEqual(user.name, capturingViewFactory.createBlogPostUser?.name)
//    }
//
//    func testEditPostPageGetsLoggedInUser() throws {
//        let user = TestDataBuilder.anyUser()
//        try user.save()
//        let post = TestDataBuilder.anyPost(author: user)
//        try post.save()
//        let request = try createLoggedInRequest(method: .get, path: "posts/\(post.id!.string!)/edit", for: user)
//        _ = try drop.respond(to: request)
//
//        XCTAssertEqual(user.name, capturingViewFactory.createBlogPostUser?.name)
//    }
//
//    func testCreateUserPageGetsLoggedInUser() throws {
//        let request = try createLoggedInRequest(method: .get, path: "createUser", for: user)
//        _ = try drop.respond(to: request)
//
//        XCTAssertEqual(user.name, capturingViewFactory.createUserLoggedInUser?.name)
//    }
//
//    func testEditUserPageGetsLoggedInUser() throws {
//        let user = TestDataBuilder.anyUser()
//        try user.save()
//        let request = try createLoggedInRequest(method: .get, path: "users/\(user.id!.string!)/edit", for: user)
//        _ = try drop.respond(to: request)
//
//        XCTAssertEqual(user.name, capturingViewFactory.createUserLoggedInUser?.name)
//    }
//
//    func testResetPasswordPageGetsLoggedInUser() throws {
//        let request = try createLoggedInRequest(method: .get, path: "resetPassword", for: user)
//        _ = try drop.respond(to: request)
//
//        XCTAssertEqual(user.name, capturingViewFactory.resetPasswordUser?.name)
//    }
//
//    func testCreatePostPageGetsURI() throws {
//        let request = try createLoggedInRequest(method: .get, path: "createPost")
//        _ = try drop.respond(to: request)
//
//        XCTAssertEqual(capturingViewFactory.createPostURI?.descriptionWithoutPort, "/blog/admin/createPost/")
//    }
//
//    func testCreatePostPageGetsHTTPSURIIfFromReverseProxy() throws {
//        let request = Request(method: .get, uri: "http://geeks.brokenhands.io/blog/admin/createPost/")
//        let user = TestDataBuilder.anyUser()
//        try user.save()
//        request.storage["auth-authenticated"] = user
//        request.headers["X-Forwarded-Proto"] = "https"
//
//        _ = try drop.respond(to: request)
//
//        XCTAssertEqual(capturingViewFactory.createPostURI?.descriptionWithoutPort, "https://geeks.brokenhands.io/blog/admin/createPost/")
//    }
    
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
