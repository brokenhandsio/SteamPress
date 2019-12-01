import XCTest
@testable import SteamPress
import Vapor

class BlogAdminPresenterTests: XCTestCase {
    
    // MARK: - Properties
    var basicContainer: BasicContainer!
    //    var presenter: ViewBlogAdminPresenter!
    var viewRenderer: CapturingViewRenderer!
    
    // MARK: - Overrides
    
    override func setUp() {
//        presenter = ViewBlogAdminPresenter()
        basicContainer = BasicContainer(config: Config.default(), environment: Environment.testing, services: .init(), on: EmbeddedEventLoop())
        basicContainer.services.register(ViewRenderer.self) { _ in
            return self.viewRenderer
        }
        viewRenderer = CapturingViewRenderer(worker: basicContainer)
    }
    
    // MARK: - Tests
    
    //    func testPasswordViewGivenCorrectParameters() throws {
    //        let user = TestDataBuilder.anyUser()
    //        let _ = try viewFactory.createResetPasswordView(errors: nil, passwordError: nil, confirmPasswordError: nil, user: user)
    //        XCTAssertNil(viewRenderer.capturedContext?["errors"])
    //        XCTAssertNil(viewRenderer.capturedContext?["password_error"])
    //        XCTAssertNil(viewRenderer.capturedContext?["confirm_password_error"])
    //        XCTAssertEqual(viewRenderer.capturedContext?["user"]?["name"]?.string, user.name)
    //        XCTAssertEqual(viewRenderer.leafPath, "blog/admin/resetPassword")
    //    }
    //
    //    func testPasswordViewHasCorrectParametersWhenError() throws {
    //        let user = TestDataBuilder.anyUser()
    //        let expectedError = "Passwords do not match"
    //        let _ = try viewFactory.createResetPasswordView(errors: [expectedError], passwordError: true, confirmPasswordError: true, user: user)
    //        XCTAssertEqual(viewRenderer.capturedContext?["errors"]?.array?.count, 1)
    //        XCTAssertEqual((viewRenderer.capturedContext?["errors"]?.array?.first)?.string, expectedError)
    //        XCTAssertTrue((viewRenderer.capturedContext?["password_error"]?.bool) ?? false)
    //        XCTAssertTrue((viewRenderer.capturedContext?["confirm_password_error"]?.bool) ?? false)
    //        XCTAssertEqual(viewRenderer.capturedContext?["user"]?["name"]?.string, user.name)
    //    }
    //
    //    func testLoginViewGetsCorrectParameters() throws {
    //        let _ = try viewFactory.createLoginView(loginWarning: false, errors: nil, username: nil, password: nil)
    //        XCTAssertFalse((viewRenderer.capturedContext?["username_error"]?.bool) ?? true)
    //        XCTAssertFalse((viewRenderer.capturedContext?["password_error"]?.bool) ?? true)
    //        XCTAssertNil(viewRenderer.capturedContext?["username_supplied"])
    //        XCTAssertNil(viewRenderer.capturedContext?["errors"])
    //        XCTAssertNil(viewRenderer.capturedContext?["login_warning"])
    //        XCTAssertEqual(viewRenderer.leafPath, "blog/admin/login")
    //    }
    //
    //    func testLoginViewWhenErrored() throws {
    //        let expectedError = "Username/password incorrect"
    //        let _ = try viewFactory.createLoginView(loginWarning: true, errors: [expectedError], username: "tim", password: "password")
    //        XCTAssertFalse((viewRenderer.capturedContext?["username_error"]?.bool) ?? true)
    //        XCTAssertFalse((viewRenderer.capturedContext?["password_error"]?.bool) ?? true)
    //        XCTAssertEqual(viewRenderer.capturedContext?["username_supplied"]?.string, "tim")
    //        XCTAssertTrue((viewRenderer.capturedContext?["login_warning"]?.bool) ?? false)
    //        XCTAssertEqual(viewRenderer.capturedContext?["errors"]?.array?.first?.string, expectedError)
    //    }
    //
    //    func testLoginPageUsernamePasswordErrorsMarkedWhenNotSuppliedAndErrored() throws {
    //        let expectedError = "Username/password incorrect"
    //        let _ = try viewFactory.createLoginView(loginWarning: true, errors: [expectedError], username: nil, password: nil)
    //        XCTAssertTrue((viewRenderer.capturedContext?["username_error"]?.bool) ?? false)
    //        XCTAssertTrue((viewRenderer.capturedContext?["password_error"]?.bool) ?? false)
    //    }
    //
    //    func testBlogAdminViewGetsCorrectParameters() throws {
    //        // Add some stuff to the database
    //        let (posts, _, users) = try setupBlogIndex()
    //        let draftPost = TestDataBuilder.anyPost(author: users.first!, title: "[DRAFT] This will be awesome", published: false)
    //        try draftPost.save()
    //        let _ = try viewFactory.createBlogAdminView(user: TestDataBuilder.anyUser())
    //        XCTAssertNil(viewRenderer.capturedContext?["errors"])
    //        XCTAssertTrue((viewRenderer.capturedContext?["blog_admin_page"]?.bool) ?? false)
    //        XCTAssertEqual(viewRenderer.capturedContext?["user"]?["name"]?.string, users.first?.name)
    //        XCTAssertEqual(viewRenderer.capturedContext?["users"]?.array?.count, 2)
    //        XCTAssertEqual(viewRenderer.capturedContext?["users"]?.array?.first?["name"]?.string, users.first?.name)
    //        XCTAssertEqual(viewRenderer.capturedContext?["published_posts"]?.array?.count, 2)
    //        XCTAssertEqual(viewRenderer.capturedContext?["published_posts"]?.array?.first?["title"]?.string, posts.data[1].title)
    //        XCTAssertEqual(viewRenderer.capturedContext?["draft_posts"]?.array?.count, 1)
    //        XCTAssertEqual(viewRenderer.capturedContext?["draft_posts"]?.array?.first?["title"]?.string, draftPost.title)
    //        XCTAssertEqual(viewRenderer.leafPath, "blog/admin/index")
    //    }
    //
    //    func testNoPostsPassedToAdminViewIfNone() throws {
    //        let _ = try viewFactory.createBlogAdminView(user: TestDataBuilder.anyUser())
    //        XCTAssertNil(viewRenderer.capturedContext?["posts"])
    //    }
    //
    //    func testAdminPageWithErrors() throws {
    //        let expectedError = "You cannot delete yourself!"
    //        let _ = try viewFactory.createBlogAdminView(errors: [expectedError], user: TestDataBuilder.anyUser())
    //        XCTAssertEqual(viewRenderer.capturedContext?["errors"]?.array?.first?.string, expectedError)
    //    }
    //
    //    func testCreateUserViewGetsCorrectParameters() throws {
    //        let user = TestDataBuilder.anyUser()
    //        let _ = try viewFactory.createUserView(loggedInUser: user)
    //        XCTAssertFalse((viewRenderer.capturedContext?["name_error"]?.bool) ?? true)
    //        XCTAssertFalse((viewRenderer.capturedContext?["username_error"]?.bool) ?? true)
    //        XCTAssertNil(viewRenderer.capturedContext?["errors"])
    //        XCTAssertNil(viewRenderer.capturedContext?["name_supplied"])
    //        XCTAssertNil(viewRenderer.capturedContext?["username_supplied"])
    //        XCTAssertNil(viewRenderer.capturedContext?["password_error"])
    //        XCTAssertNil(viewRenderer.capturedContext?["confirm_password_error"])
    //        XCTAssertNil(viewRenderer.capturedContext?["reset_password_on_login_supplied"])
    //        XCTAssertNil(viewRenderer.capturedContext?["editing"])
    //        XCTAssertNil(viewRenderer.capturedContext?["user_id"])
    //        XCTAssertNil(viewRenderer.capturedContext?["twitter_handle_supplied"])
    //        XCTAssertNil(viewRenderer.capturedContext?["profile_picture_supplied"])
    //        XCTAssertNil(viewRenderer.capturedContext?["biography_supplied"])
    //        XCTAssertNil(viewRenderer.capturedContext?["tagline_supplied"])
    //        XCTAssertEqual(viewRenderer.leafPath, "blog/admin/createUser")
    //        XCTAssertEqual(viewRenderer.capturedContext?["user"]?["name"]?.string, user.name)
    //    }
    //
    //    func testCreateUserViewWhenErrors() throws {
    //        let user = TestDataBuilder.anyUser()
    //        let expectedError = "Not valid password"
    //        let _ = try viewFactory.createUserView(errors: [expectedError], name: "Luke", username: "luke", passwordError: true, confirmPasswordError: true, resetPasswordRequired: true, profilePicture: "https://static.brokenhands.io/steampress/images/authors/luke.png", twitterHandle: "luke", biography: "The last Jedi in the Galaxy", tagline: "A son without a father", loggedInUser: user)
    //        XCTAssertFalse((viewRenderer.capturedContext?["name_error"]?.bool) ?? true)
    //        XCTAssertFalse((viewRenderer.capturedContext?["username_error"]?.bool) ?? true)
    //        XCTAssertEqual(viewRenderer.capturedContext?["errors"]?.array?.first?.string, expectedError)
    //        XCTAssertEqual(viewRenderer.capturedContext?["name_supplied"]?.string, "Luke")
    //        XCTAssertEqual(viewRenderer.capturedContext?["username_supplied"]?.string, "luke")
    //        XCTAssertTrue((viewRenderer.capturedContext?["password_error"]?.bool) ?? false)
    //        XCTAssertTrue((viewRenderer.capturedContext?["confirm_password_error"]?.bool) ?? false)
    //        XCTAssertTrue((viewRenderer.capturedContext?["reset_password_on_login_supplied"]?.bool) ?? false)
    //        XCTAssertEqual(viewRenderer.capturedContext?["profile_picture_supplied"]?.string, "https://static.brokenhands.io/steampress/images/authors/luke.png")
    //        XCTAssertEqual(viewRenderer.capturedContext?["twitter_handle_supplied"]?.string, "luke")
    //        XCTAssertEqual(viewRenderer.capturedContext?["tagline_supplied"]?.string, "A son without a father")
    //        XCTAssertEqual(viewRenderer.capturedContext?["biography_supplied"]?.string, "The last Jedi in the Galaxy")
    //        XCTAssertEqual(viewRenderer.capturedContext?["user"]?["name"]?.string, user.name)
    //    }
    //
    //    func testCreateUserViewWhenNoNameOrUsernameSupplied() throws {
    //        let user = TestDataBuilder.anyUser()
    //        let expectedError = "No name supplied"
    //        let _ = try viewFactory.createUserView(errors: [expectedError], name: nil, username: nil, passwordError: true, confirmPasswordError: true, resetPasswordRequired: true, loggedInUser: user)
    //        XCTAssertTrue((viewRenderer.capturedContext?["name_error"]?.bool) ?? false)
    //        XCTAssertTrue((viewRenderer.capturedContext?["username_error"]?.bool) ?? false)
    //        XCTAssertEqual(viewRenderer.capturedContext?["user"]?["name"]?.string, user.name)
    //    }
    //
    //    func testCreateUserViewForEditing() throws {
    //        let user = TestDataBuilder.anyUser()
    //        let _ = try viewFactory.createUserView(editing: true, errors: nil, name: "Luke", username: "luke", userId: Identifier(StructuredData.number(1), in: nil), profilePicture: "https://static.brokenhands.io/steampress/images/authors/luke.png", twitterHandle: "luke", biography: "The last Jedi in the Galaxy", tagline: "A son without a father", loggedInUser: user)
    //        XCTAssertEqual(viewRenderer.capturedContext?["name_supplied"]?.string, "Luke")
    //        XCTAssertEqual(viewRenderer.capturedContext?["username_supplied"]?.string, "luke")
    //        XCTAssertTrue((viewRenderer.capturedContext?["editing"]?.bool) ?? false)
    //        XCTAssertEqual(viewRenderer.capturedContext?["user_id"]?.int, 1)
    //        XCTAssertEqual(viewRenderer.capturedContext?["profile_picture_supplied"]?.string, "https://static.brokenhands.io/steampress/images/authors/luke.png")
    //        XCTAssertEqual(viewRenderer.capturedContext?["twitter_handle_supplied"]?.string, "luke")
    //        XCTAssertEqual(viewRenderer.capturedContext?["tagline_supplied"]?.string, "A son without a father")
    //        XCTAssertEqual(viewRenderer.capturedContext?["biography_supplied"]?.string, "The last Jedi in the Galaxy")
    //        XCTAssertEqual(viewRenderer.leafPath, "blog/admin/createUser")
    //        XCTAssertEqual(viewRenderer.capturedContext?["user"]?["name"]?.string, user.name)
    //    }
    //
    //    func testCreateUserViewThrowsWhenTryingToEditWithoutUserId() throws {
    //        var errored = false
    //        do {
    //            let _ = try viewFactory.createUserView(editing: true, errors: nil, name: "Luke", username: "luke", userId: nil, loggedInUser: TestDataBuilder.anyUser())
    //        } catch {
    //            errored = true
    //        }
    //
    //        XCTAssertTrue(errored)
    //    }
    //
    //    func testCreateBlogPostViewGetsCorrectParameters() throws {
    //        let user = TestDataBuilder.anyUser()
    //        let _ = try viewFactory.createBlogPostView(uri: createPostURI, user: user)
    //        XCTAssertEqual(viewRenderer.capturedContext?["post_path_prefix"]?.string, "https://test.com/posts/")
    //        XCTAssertFalse((viewRenderer.capturedContext?["title_error"]?.bool) ?? true)
    //        XCTAssertFalse((viewRenderer.capturedContext?["contents_error"]?.bool) ?? true)
    //        XCTAssertNil(viewRenderer.capturedContext?["errors"])
    //        XCTAssertNil(viewRenderer.capturedContext?["title_supplied"])
    //        XCTAssertNil(viewRenderer.capturedContext?["contents_supplied"])
    //        XCTAssertNil(viewRenderer.capturedContext?["slug_url_supplied"])
    //        XCTAssertNil(viewRenderer.capturedContext?["tags_supplied"])
    //        XCTAssertEqual(viewRenderer.leafPath, "blog/admin/createPost")
    //        XCTAssertTrue((viewRenderer.capturedContext?["create_blog_post_page"]?.bool) ?? false)
    //        XCTAssertTrue((viewRenderer.capturedContext?["draft"]?.bool) ?? false)
    //        XCTAssertNil(viewRenderer.capturedContext?["editing"])
    //        XCTAssertEqual(viewRenderer.capturedContext?["user"]?["name"]?.string, user.name)
    //    }
    //
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
    //
    //    func testEditBlogPostViewThrowsWithNoPostToEdit() throws {
    //        var errored = false
    //        do {
    //            let _ = try viewFactory.createBlogPostView(uri: createPostURI, isEditing: true, postToEdit: nil, user: TestDataBuilder.anyUser())
    //        } catch {
    //            errored = true
    //        }
    //
    //        XCTAssertTrue(errored)
    //    }
    //
    //    func testCreateBlogPostViewWithErrorsAndNoTitleOrContentsSupplied() throws {
    //        let expectedError = "Please enter a title"
    //        let user = TestDataBuilder.anyUser()
    //        let _ = try viewFactory.createBlogPostView(uri: createPostURI, errors: [expectedError], title: nil, contents: nil, slugUrl: nil, tags: nil, isEditing: false, user: user)
    //        XCTAssertTrue((viewRenderer.capturedContext?["title_error"]?.bool) ?? false)
    //        XCTAssertTrue((viewRenderer.capturedContext?["contents_error"]?.bool) ?? false)
    //        XCTAssertEqual(viewRenderer.capturedContext?["errors"]?.array?.count, 1)
    //        XCTAssertEqual(viewRenderer.capturedContext?["errors"]?.array?.first?.string, expectedError)
    //        XCTAssertEqual(viewRenderer.capturedContext?["user"]?["name"]?.string, user.name)
    //    }
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
    //
    //    func testSearchPageGetsCorrectParameters() throws {
    //        let (posts, _, users) = try setupBlogIndex()
    //        _ = try viewFactory.searchView(uri: searchURI, searchTerm: "Test", foundPosts: posts, emptySearch: false, user: users[0])
    //
    //        XCTAssertEqual(viewRenderer.capturedContext?["uri"]?.string, searchURI.descriptionWithoutPort)
    //
    //        XCTAssertEqual(viewRenderer.capturedContext?["posts"]?["data"]?.array?.count, posts.total)
    //        XCTAssertEqual((viewRenderer.capturedContext?["posts"]?["data"]?.array?.first)?["title"]?.string, posts.data.first?.title)
    //        XCTAssertEqual(viewRenderer.capturedContext?["user"]?["name"]?.string, users.first?.name)
    //        XCTAssertEqual(viewRenderer.leafPath, "blog/search")
    //        XCTAssertNil(viewRenderer.capturedContext?["emptySearch"]?.bool)
    //        XCTAssertEqual(viewRenderer.capturedContext?["searchTerm"]?.string, "Test")
    //        XCTAssertEqual(viewRenderer.capturedContext?["searchCount"]?.int, 2)
    //        XCTAssertEqual(viewRenderer.capturedContext?["disqus_name"]?.string, disqusName)
    //        XCTAssertEqual(viewRenderer.capturedContext?["site_twitter_handle"]?.string, siteTwitterHandle)
    //        XCTAssertEqual(viewRenderer.capturedContext?["google_analytics_identifier"]?.string, googleAnalyticsIdentifier)
    //    }
    //
    //    func testSearchPageGetsFlagIfNoSearchTermProvided() throws {
    //        _ = try viewFactory.searchView(uri: searchURI, searchTerm: nil, foundPosts: nil, emptySearch: true, user: nil)
    //
    //        XCTAssertTrue(viewRenderer.capturedContext?["emptySearch"]?.bool ?? false)
    //        XCTAssertNil(viewRenderer.capturedContext?["posts"])
    //    }
    //
    //    func testSearchPageGetsCountIfNoPagesFound() throws {
    //        _ = try viewFactory.searchView(uri: searchURI, searchTerm: "Test", foundPosts: BlogPost.makeQuery().paginate(for: indexRequest), emptySearch: false, user: nil)
    //
    //        XCTAssertEqual(viewRenderer.capturedContext?["searchCount"]?.int, 0)
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
}
