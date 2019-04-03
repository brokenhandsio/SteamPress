//import XCTest
//@testable import Vapor
//@testable import SteamPress
//import HTTP
//import Fluent
////import Sessions
////import Cookies
////import AuthProvider
//
//class BlogAdminControllerTests: XCTestCase {
//    static var allTests = [
//        ("testLinuxTestSuiteIncludesAllTests", testLinuxTestSuiteIncludesAllTests),
//        ("testLogin", testLogin),
//        ("testUserIsCreatedWhenSettingUpSteamPressFirstTime", testUserIsCreatedWhenSettingUpSteamPressFirstTime),
//        ("testNoUserCreatedWhenAccessingLoginPageIfOneAlreadyExists", testNoUserCreatedWhenAccessingLoginPageIfOneAlreadyExists),
//        ("testCannotAccessAdminPageWithoutBeingLoggedIn", testCannotAccessAdminPageWithoutBeingLoggedIn),
//        ("testCannotAccessCreateBlogPostPageWithoutBeingLoggedIn", testCannotAccessCreateBlogPostPageWithoutBeingLoggedIn),
//        ("testCannotSendCreateBlogPostPageWithoutBeingLoggedIn", testCannotSendCreateBlogPostPageWithoutBeingLoggedIn),
//        ("testCannotAccessEditPostPageWithoutLogin", testCannotAccessEditPostPageWithoutLogin),
//        ("testCannotSendEditPostPageWithoutLogin", testCannotSendEditPostPageWithoutLogin),
//        ("testCannotAccessCreateUserPageWithoutLogin", testCannotAccessCreateUserPageWithoutLogin),
//        ("testCannotSendCreateUserPageWithoutLogin", testCannotSendCreateUserPageWithoutLogin),
//        ("testCannotAccessEditUserPageWithoutLogin", testCannotAccessEditUserPageWithoutLogin),
//        ("testCannotSendEditUserPageWithoutLogin", testCannotSendEditUserPageWithoutLogin),
//        ("testCannotDeletePostWithoutLogin", testCannotDeletePostWithoutLogin),
//        ("testCannotDeleteUserWithoutLogin", testCannotDeleteUserWithoutLogin),
//        ("testCannotAccessResetPasswordPageWithoutLogin", testCannotAccessResetPasswordPageWithoutLogin),
//        ("testCannotSendResetPasswordPageWithoutLogin", testCannotSendResetPasswordPageWithoutLogin),
//        ("testCanAccessAdminPageWhenLoggedIn", testCanAccessAdminPageWhenLoggedIn),
//        ("testCanAccessCreatePostPageWhenLoggedIn", testCanAccessCreatePostPageWhenLoggedIn),
//        ("testCanAccessEditPostPageWhenLoggedIn", testCanAccessEditPostPageWhenLoggedIn),
//        ("testCanAccessCreateUserPageWhenLoggedIn", testCanAccessCreateUserPageWhenLoggedIn),
//        ("testCanAccessEditUserPageWhenLoggedIn", testCanAccessEditUserPageWhenLoggedIn),
//        ("testCanAccessResetPasswordPage", testCanAccessResetPasswordPage),
//        ("testCanDeleteBlogPost", testCanDeleteBlogPost),
//        ("testCanDeleteUser", testCanDeleteUser),
//        ("testCannotDeleteSelf", testCannotDeleteSelf),
//        ("testCannotDeleteLastUser", testCannotDeleteLastUser),
//        ("testUserCannotResetPasswordWithMismatchingPasswords", testUserCannotResetPasswordWithMismatchingPasswords),
//        ("testUserCanResetPassword", testUserCanResetPassword),
//        ("testUserCannotResetPasswordWithoutPassword", testUserCannotResetPasswordWithoutPassword),
//        ("testUserCannotResetPasswordWithoutConfirmPassword", testUserCannotResetPasswordWithoutConfirmPassword),
//        ("testUserCannotResetPasswordWithShortPassword", testUserCannotResetPasswordWithShortPassword),
//        ("testUserIsRedirectedWhenLoggingInAndPasswordResetRequired", testUserIsRedirectedWhenLoggingInAndPasswordResetRequired),
//        ("testPostCanBeCreated", testPostCanBeCreated),
//        ("testPostCannotBeCreatedIfDraftAndPublishNotSet", testPostCannotBeCreatedIfDraftAndPublishNotSet),
//        ("testCreatePostMustIncludeTitle", testCreatePostMustIncludeTitle),
//        ("testCreatePostMustIncludeContents", testCreatePostMustIncludeContents),
//        ("testCreatePostWithDraftDoesNotPublishPost", testCreatePostWithDraftDoesNotPublishPost),
//        ("testUserCanBeCreatedSuccessfully", testUserCanBeCreatedSuccessfully),
//        ("testUserMustResetPasswordIfSetToWhenCreatingUser", testUserMustResetPasswordIfSetToWhenCreatingUser),
//        ("testUserCannotBeCreatedWithoutName", testUserCannotBeCreatedWithoutName),
//        ("testUserCannotBeCreatedWithoutUsername", testUserCannotBeCreatedWithoutUsername),
//        ("testUserCannotBeCreatedWithoutPassword", testUserCannotBeCreatedWithoutPassword),
//        ("testUserCannotBeCreatedWithoutSpecifyingAConfirmPassword", testUserCannotBeCreatedWithoutSpecifyingAConfirmPassword),
//        ("testUserCannotBeCreatedWithPasswordsThatDontMatch", testUserCannotBeCreatedWithPasswordsThatDontMatch),
//        ("testUserCannotBeCreatedWithSimplePassword", testUserCannotBeCreatedWithSimplePassword),
//        ("testUserCannotBeCreatedWithEmptyName", testUserCannotBeCreatedWithEmptyName),
//        ("testUserCannotBeCreatedWithEmptyUsername", testUserCannotBeCreatedWithEmptyUsername),
//        ("testUserCannotBeCreatedWithInvalidName", testUserCannotBeCreatedWithInvalidName),
//        ("testUserCannotBeCreatedWithInvalidUsername", testUserCannotBeCreatedWithInvalidUsername),
//        ("testPostCanBeUpdated", testPostCanBeUpdated),
//        ("testUserCanBeUpdated", testUserCanBeUpdated),
//        ("testAdminPageGetsLoggedInUser", testAdminPageGetsLoggedInUser),
//        ("testCreatePostPageGetsLoggedInUser", testCreatePostPageGetsLoggedInUser),
//        ("testEditPostPageGetsLoggedInUser", testEditPostPageGetsLoggedInUser),
//        ("testCreateUserPageGetsLoggedInUser", testCreatePostPageGetsLoggedInUser),
//        ("testEditUserPageGetsLoggedInUser", testEditPostPageGetsLoggedInUser),
//        ("testResetPasswordPageGetsLoggedInUser", testResetPasswordPageGetsLoggedInUser),
//        ("testCreatePostPageGetsURI", testCreatePostPageGetsURI),
//        ("testCreatePostPageGetsHTTPSURIIfFromReverseProxy", testCreatePostPageGetsHTTPSURIIfFromReverseProxy),
//        ("testThatEditingPostGetsRedirectToPostPage", testThatEditingPostGetsRedirectToPostPage),
//    ]
//    
//    // MARK: - Properties
//    
//    var database: Database!
//    var drop: Droplet!
//    var capturingViewFactory: CapturingViewFactory!
//    var user: BlogUser!
//    
//    // MARK: - Overrides
//    
//    override func setUp() {
//        BlogUser.passwordHasher = FakePasswordHasher()
//        var config = Config([:])
//        let sessionsMiddleware = SessionsMiddleware(try! config.resolveSessions(), cookieName: SteamPress.Provider.cookieName, cookieFactory: Provider.createCookieFactory(for: .production))
//        config.addConfigurable(middleware: { (config) -> (SessionsMiddleware) in
//            return sessionsMiddleware
//        }, name: "steampress-sessions")
//        
//        let persistMiddleware = PersistMiddleware(BlogUser.self)
//        config.addConfigurable(middleware: { (config) -> (PersistMiddleware<BlogUser>) in
//            return persistMiddleware
//        }, name: "blog-persist")
//        try! config.set("droplet.middleware", ["error", "steampress-sessions", "blog-persist"])
//        try! config.set("steampress.postsPerPage", 5)
//        try! config.set("fluent.driver", "memory")
//        
//        try! config.addProvider(SteamPress.Provider.self)
//        try! config.addProvider(FluentProvider.Provider.self)
//        
//        drop = try! Droplet(config)
//        capturingViewFactory = CapturingViewFactory()
//        let adminController = BlogAdminController(drop: drop, pathCreator: BlogPathCreator(blogPath: "blog"), viewFactory: capturingViewFactory)
//        adminController.addRoutes()
//        let adminUser = try! BlogUser.all().first
//        
//        guard let createdUser = adminUser else {
//            XCTFail()
//            return
//        }
//        
//        user = createdUser
//        user.resetPasswordRequired = false
//        try! user.save()
//    }
//    
//    // Courtesy of https://oleb.net/blog/2017/03/keeping-xctest-in-sync/
//    func testLinuxTestSuiteIncludesAllTests() {
//        #if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
//            let thisClass = type(of: self)
//            let linuxCount = thisClass.allTests.count
//            let darwinCount = Int(thisClass.defaultTestSuite.testCaseCount)
//            XCTAssertEqual(linuxCount, darwinCount, "\(darwinCount - linuxCount) tests are missing from allTests")
//        #endif
//    }
//    
//    // MARK: - Tests

//    // MARK: - Delete tests
//    
//    
//    func testCanDeleteUser() throws {
//        let user2 = TestDataBuilder.anyUser(name: "Han", username: "han")
//        try user2.save()
//        
//        let request = try createLoggedInRequest(method: .get, path: "users/\(user2.id!.string!)/delete")
//        let response = try drop.respond(to: request)
//        
//        XCTAssertEqual(response.status, .seeOther)
//        XCTAssertEqual(try BlogUser.count(), 2)
//        XCTAssertNotEqual(try BlogUser.all().first?.name, "Han")
//    }
//    
//    func testCannotDeleteSelf() throws {
//        let user = TestDataBuilder.anyUser(name: "Han", username: "han")
//        try user.save()
//        
//        let request = try createLoggedInRequest(method: .get, path: "users/\(user.id!.string!)/delete", for: user)
//        _ = try drop.respond(to: request)
//        
//        XCTAssertTrue(capturingViewFactory.adminViewErrors?.contains("You cannot delete yourself whilst logged in") ?? false)
//    }
//    
//    func testCannotDeleteLastUser() throws {
//        let user = try BlogUser.all().first
//        
//        let userID = user!.id!.string!
//        
//        let request = try createLoggedInRequest(method: .get, path: "users/\(userID)/delete", for: user)
//        _ = try drop.respond(to: request)
//        
//        XCTAssertTrue(capturingViewFactory.adminViewErrors?.contains("You cannot delete the last user") ?? false)
//    }
//    
//    // MARK: - Reset Password tests
//    
//    func testUserCannotResetPasswordWithMismatchingPasswords() throws {
//        let user = TestDataBuilder.anyUser()
//        try user.save()
//        
//        let request = try createLoggedInRequest(method: .post, path: "resetPassword", for: user)
//        let resetPasswordData = try Node(node: [
//            "inputPassword": "Th3S@m3password",
//            "inputConfirmPassword": "An0th3rPass!"
//            ])
//        request.formURLEncoded = resetPasswordData
//        
//        _ = try drop.respond(to: request)
//        
//        XCTAssertTrue(capturingViewFactory.resetPasswordErrors?.contains("Your passwords must match!") ?? false)
//    }
//    
//    func testUserCanResetPassword() throws {
//        BlogUser.passwordHasher = FakePasswordHasher()
//        let user = TestDataBuilder.anyUser()
//        try user.save()
//        let newPassword = "Th3S@m3password"
//        
//        let request = try createLoggedInRequest(method: .post, path: "resetPassword", for: user)
//        let resetPasswordData = try Node(node: [
//            "inputPassword": newPassword,
//            "inputConfirmPassword": newPassword
//            ])
//        request.formURLEncoded = resetPasswordData
//        
//        let response = try drop.respond(to: request)
//        
//        XCTAssertEqual(user.password, newPassword.makeBytes())
//        XCTAssertEqual(response.status, .seeOther)
//        XCTAssertEqual(response.headers[HeaderKey.location], "/blog/admin/")
//    }
//    
//    func testUserCannotResetPasswordWithoutPassword() throws {
//        let user = TestDataBuilder.anyUser()
//        try user.save()
//        
//        let request = try createLoggedInRequest(method: .post, path: "resetPassword", for: user)
//        let resetPasswordData = try Node(node: [
//            "inputConfirmPassword": "Th3S@m3password",
//            ])
//        request.formURLEncoded = resetPasswordData
//        
//        _ = try drop.respond(to: request)
//        
//        XCTAssertTrue(capturingViewFactory.resetPasswordErrors?.contains("You must specify a password") ?? false)
//    }
//    
//    func testUserCannotResetPasswordWithoutConfirmPassword() throws {
//        let user = TestDataBuilder.anyUser()
//        try user.save()
//        
//        let request = try createLoggedInRequest(method: .post, path: "resetPassword", for: user)
//        let resetPasswordData = try Node(node: [
//            "inputPassword": "Th3S@m3password",
//            ])
//        request.formURLEncoded = resetPasswordData
//        
//        _ = try drop.respond(to: request)
//        
//        XCTAssertTrue(capturingViewFactory.resetPasswordErrors?.contains("You must confirm your password") ?? false)
//    }
//    
//    func testUserCannotResetPasswordWithShortPassword() throws {
//        let user = TestDataBuilder.anyUser()
//        try user.save()
//        
//        let request = try createLoggedInRequest(method: .post, path: "resetPassword", for: user)
//        let resetPasswordData = try Node(node: [
//            "inputPassword": "S12$345",
//            "inputConfirmPassword": "S12$345"
//            ])
//        request.formURLEncoded = resetPasswordData
//        
//        _ = try drop.respond(to: request)
//        
//        XCTAssertTrue(capturingViewFactory.resetPasswordErrors?.contains("Your password must contain a lowercase letter, an upperacase letter, a number and a symbol") ?? false)
//    }
//    
//    func testUserIsRedirectedWhenLoggingInAndPasswordResetRequired() throws {
//        let user = TestDataBuilder.anyUser()
//        user.resetPasswordRequired = true
//        try user.save()
//        
//        let request = try createLoggedInRequest(method: .get, path: "", for: user)
//        
//        let response = try drop.respond(to: request)
//        
//        XCTAssertEqual(response.status, .seeOther)
//        XCTAssertEqual(response.headers[HeaderKey.location], "/blog/admin/resetPassword/")
//    }
//    
//    // MARK: - Create Post Tests
//    
//    
//    
//    // MARK: - Create User Tests
//    
//    func testUserCanBeCreatedSuccessfully() throws {
//        BlogUser.passwordHasher = FakePasswordHasher()
//        let request = try createLoggedInRequest(method: .post, path: "createUser")
//        let newName = "Leia"
//        let newUsername = "leia"
//        let password = "AS3cretPassword"
//        let profilePicture = "https://static.brokenhands.io/images/cat.png"
//        let tagline = "The awesome tagline"
//        let biography = "The biograhy"
//        let twitterHandle = "brokenhandsio"
//        var userData = Node([:], in: nil)
//        try userData.set("inputName", newName)
//        try userData.set("inputUsername", newUsername)
//        try userData.set("inputPassword", password)
//        try userData.set("inputConfirmPassword", password)
//        try userData.set("inputProfilePicture", profilePicture)
//        try userData.set("inputTagline", tagline)
//        try userData.set("inputBiography", biography)
//        try userData.set("inputTwitterHandle", twitterHandle)
//        request.formURLEncoded = userData
//        
//        let _ = try drop.respond(to: request)
//        
//        // We create the first user when setting up the logged in request
//        XCTAssertEqual(try BlogUser.count(), 3)
//        let user = try BlogUser.makeQuery().filter("name", newName).all().first
//        XCTAssertNotNil(user)
//        XCTAssertEqual(user?.username, newUsername)
//        XCTAssertEqual(user?.profilePicture, profilePicture)
//        XCTAssertEqual(user?.tagline, tagline)
//        XCTAssertEqual(user?.biography, biography)
//        XCTAssertEqual(user?.twitterHandle, twitterHandle)
//    }
//    
//    func testUserMustResetPasswordIfSetToWhenCreatingUser() throws {
//        BlogUser.passwordHasher = FakePasswordHasher()
//        let request = try createLoggedInRequest(method: .post, path: "createUser")
//        let newName = "Leia"
//        let password = "AS3cretPassword"
//        var userData = Node([:], in: nil)
//        try userData.set("inputName", newName)
//        try userData.set("inputUsername", "leia")
//        try userData.set("inputPassword", password)
//        try userData.set("inputConfirmPassword", password)
//        try userData.set("inputResetPasswordOnLogin", "true")
//        request.formURLEncoded = userData
//        
//        let _ = try drop.respond(to: request)
//        
//        XCTAssertTrue(try BlogUser.makeQuery().filter("name", newName).all().first?.resetPasswordRequired ?? false)
//    }
//    
//    func testUserCannotBeCreatedWithoutName() throws {
//        let request = try createLoggedInRequest(method: .post, path: "createUser")
//        let password = "AS3cretPassword"
//        var userData = Node([:], in: nil)
//        try userData.set("inputUsername", "leia")
//        try userData.set("inputPassword", password)
//        try userData.set("inputConfirmPassword", password)
//        try userData.set("inputResetPasswordOnLogin", "true")
//        request.formURLEncoded = userData
//        
//        let _ = try drop.respond(to: request)
//        
//        XCTAssertTrue(capturingViewFactory.createUserErrors?.contains("You must specify a name") ?? false)
//    }
//    
//    func testUserCannotBeCreatedWithoutUsername() throws {
//        let request = try createLoggedInRequest(method: .post, path: "createUser")
//        let password = "AS3cretPassword"
//        var userData = Node([:], in: nil)
//        try userData.set("inputName", "Leia")
//        try userData.set("inputPassword", password)
//        try userData.set("inputConfirmPassword", password)
//        try userData.set("inputResetPasswordOnLogin", "true")
//        request.formURLEncoded = userData
//        
//        let _ = try drop.respond(to: request)
//        
//        XCTAssertTrue(capturingViewFactory.createUserErrors?.contains("You must specify a username") ?? false)
//    }
//    
//    func testUserCannotBeCreatedWithoutPassword() throws {
//        let request = try createLoggedInRequest(method: .post, path: "createUser")
//        let password = "AS3cretPassword"
//        var userData = Node([:], in: nil)
//        try userData.set("inputName", "Leia")
//        try userData.set("inputUsername", "leia")
//        try userData.set("inputConfirmPassword", password)
//        try userData.set("inputResetPasswordOnLogin", "true")
//        request.formURLEncoded = userData
//        
//        let _ = try drop.respond(to: request)
//        
//        XCTAssertTrue(capturingViewFactory.createUserErrors?.contains("You must specify a password") ?? false)
//    }
//    
//    func testUserCannotBeCreatedWithoutSpecifyingAConfirmPassword() throws {
//        let request = try createLoggedInRequest(method: .post, path: "createUser")
//        let password = "AS3cretPassword"
//        var userData = Node([:], in: nil)
//        try userData.set("inputName", "Leia")
//        try userData.set("inputUsername", "leia")
//        try userData.set("inputPassword", password)
//        try userData.set("inputResetPasswordOnLogin", "true")
//        request.formURLEncoded = userData
//        
//        let _ = try drop.respond(to: request)
//        
//        XCTAssertTrue(capturingViewFactory.createUserErrors?.contains("You must confirm your password") ?? false)
//    }
//    
//    func testUserCannotBeCreatedWithPasswordsThatDontMatch() throws {
//        let request = try createLoggedInRequest(method: .post, path: "createUser")
//        let password = "AS3cretPassword"
//        var userData = Node([:], in: nil)
//        try userData.set("inputName", "Leia")
//        try userData.set("inputUsername", "leia")
//        try userData.set("inputPassword", password)
//        try userData.set("inputConfirmPassword", "Som£th!ngDifferent")
//        try userData.set("inputResetPasswordOnLogin", "true")
//        request.formURLEncoded = userData
//        
//        let _ = try drop.respond(to: request)
//        
//        XCTAssertTrue(capturingViewFactory.createUserErrors?.contains("Your passwords must match!") ?? false)
//    }
//    
//    func testUserCannotBeCreatedWithSimplePassword() throws {
//        let request = try createLoggedInRequest(method: .post, path: "createUser")
//        let password = "simple"
//        var userData = Node([:], in: nil)
//        try userData.set("inputName", "Leia")
//        try userData.set("inputUsername", "leia")
//        try userData.set("inputPassword", password)
//        try userData.set("inputConfirmPassword", password)
//        try userData.set("inputResetPasswordOnLogin", "true")
//        request.formURLEncoded = userData
//        
//        let _ = try drop.respond(to: request)
//        
//        XCTAssertTrue(capturingViewFactory.createUserErrors?.contains("Your password must contain a lowercase letter, an upperacase letter, a number and a symbol") ?? false)
//    }
//    
//    func testUserCannotBeCreatedWithEmptyName() throws {
//        let request = try createLoggedInRequest(method: .post, path: "createUser")
//        let password = "AComl3xPass!"
//        var userData = Node([:], in: nil)
//        try userData.set("inputName", "")
//        try userData.set("inputUsername", "leia")
//        try userData.set("inputPassword", password)
//        try userData.set("inputConfirmPassword", password)
//        try userData.set("inputResetPasswordOnLogin", "true")
//        request.formURLEncoded = userData
//        
//        let _ = try drop.respond(to: request)
//        
//        XCTAssertTrue(capturingViewFactory.createUserErrors?.contains("You must specify a name") ?? false)
//    }
//    
//    func testUserCannotBeCreatedWithEmptyUsername() throws {
//        let request = try createLoggedInRequest(method: .post, path: "createUser")
//        let password = "AComl3xPass!"
//        var userData = Node([:], in: nil)
//        try userData.set("inputName", "Leia")
//        try userData.set("inputUsername", "")
//        try userData.set("inputPassword", password)
//        try userData.set("inputConfirmPassword", password)
//        try userData.set("inputResetPasswordOnLogin", "true")
//        request.formURLEncoded = userData
//        
//        let _ = try drop.respond(to: request)
//        
//        XCTAssertTrue(capturingViewFactory.createUserErrors?.contains("You must specify a username") ?? false)
//    }
//    
//    func testUserCannotBeCreatedWithInvalidName() throws {
//        let request = try createLoggedInRequest(method: .post, path: "createUser")
//        let password = "AComl3xPass!"
//        var userData = Node([:], in: nil)
//        try userData.set("inputName", "An invalid Name!3")
//        try userData.set("inputUsername", "leia")
//        try userData.set("inputPassword", password)
//        try userData.set("inputConfirmPassword", password)
//        try userData.set("inputResetPasswordOnLogin", "true")
//        request.formURLEncoded = userData
//        
//        let _ = try drop.respond(to: request)
//        
//        XCTAssertTrue(capturingViewFactory.createUserErrors?.contains("The name provided is not valid") ?? false)
//    }
//    
//    func testUserCannotBeCreatedWithInvalidUsername() throws {
//        let request = try createLoggedInRequest(method: .post, path: "createUser")
//        let password = "AComl3xPass!"
//        var userData = Node([:], in: nil)
//        try userData.set("inputName", "Leia")
//        try userData.set("inputUsername", "LEIA!")
//        try userData.set("inputPassword", password)
//        try userData.set("inputConfirmPassword", password)
//        try userData.set("inputResetPasswordOnLogin", "true")
//        request.formURLEncoded = userData
//        
//        let _ = try drop.respond(to: request)
//        
//        XCTAssertTrue(capturingViewFactory.createUserErrors?.contains("The username provided is not valid") ?? false)
//    }
//    
//    // MARK: - Edit Post Tests
//    
//    func testPostCanBeUpdated() throws {
//        let author = TestDataBuilder.anyUser()
//        try author.save()
//        
//        let post = TestDataBuilder.anyPost(author: author, title: "Initial title", contents: "Some initial contents", slugUrl: "initial-title")
//        try post.save()
//        
//        let request = try createLoggedInRequest(method: .post, path: "posts/\(post.id!.string!)/edit", for: author)
//        let newTitle = "New Title"
//        let newContents = "We have updated the contents"
//        let newSlug = "new-title"
//        var postData = Node([:], in: nil)
//        try postData.set("inputTitle", newTitle)
//        try postData.set("inputPostContents", newContents)
//        try postData.set("inputSlugUrl", newSlug)
//        request.formURLEncoded = postData
//        
//        let _  = try drop.respond(to: request)
//        
//        XCTAssertEqual(try BlogPost.count(), 1)
//        XCTAssertEqual(try BlogPost.all().first?.title, newTitle)
//        XCTAssertEqual(try BlogPost.all().first?.contents, newContents)
//        XCTAssertEqual(try BlogPost.all().first?.id, post.id)
//    }
//    
//    // MARK: - Edit User Tests
//    
//    func testUserCanBeUpdated() throws {
//        let author = TestDataBuilder.anyUser(name: "Luke", username: "luke")
//        try author.save()
//        
//        let request = try createLoggedInRequest(method: .post, path: "users/\(author.id!.string!)/edit", for: author)
//        let newName = "Darth Vader"
//        let newUsername = "darth_vader"
//        var userData = Node([:], in: nil)
//        try userData.set("inputName", newName)
//        try userData.set("inputUsername", newUsername)
//        request.formURLEncoded = userData
//        
//        let _  = try drop.respond(to: request)
//        
//        XCTAssertEqual(try BlogUser.count(), 2)
//        XCTAssertEqual(try BlogUser.all()[1].id, author.id)
//        XCTAssertEqual(try BlogUser.all()[1].name, newName)
//        XCTAssertEqual(try BlogUser.all()[1].username, newUsername)
//    }
//    
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
//
//    func testThatEditingPostGetsRedirectToPostPage() throws {
//        let post = BlogPost(title: "Test Post", contents: "Blah 1", author: user, creationDate: Date(), slugUrl: "test-post", published: true)
//        try post.save()
//
//        let request = try createLoggedInRequest(method: .post, path: "posts/\(post.id!.string!)/edit", for: user)
//
//        let requestData = [
//            "inputTitle": "Test Post".makeNode(in: nil),
//            "inputPostContents": "Blah 2".makeNode(in: nil),
//            "inputSlugUrl": "test-post",
//            "publish": "publish"
//        ]
//
//        request.formURLEncoded = try requestData.makeNode(in: nil)
//
//        let response = try drop.respond(to: request)
//
//        XCTAssertEqual(response.status, .seeOther)
//        XCTAssertEqual(response.headers[.location], "/blog/posts/\(post.slugUrl)/")
//    }
//    
//    // MARK: - Helper functions
//
//    private func createLoggedInRequest(method: HTTP.Method, path: String, for user: BlogUser? = nil) throws -> Request {
//        let uri = "/blog/admin/\(path)/"
//        
//        let request = Request(method: method, uri: uri)
//        
//        let authAuthenticatedKey = "auth-authenticated"
//        
//        if let user = user {
//            request.storage[authAuthenticatedKey] = user
//        }
//        else {
//            let testUser = TestDataBuilder.anyUser()
//            try testUser.save()
//            request.storage[authAuthenticatedKey] = testUser
//        }
//        
//        return request
//    }
//}


