//
//  BlogControllerTests.swift
//  SteamPress
//
//  Created by Tim Condon on 20/02/2017.
//
//

import XCTest
@testable import SteamPress
@testable import Vapor
import Fluent
import HTTP

class BlogControllerTests: XCTestCase {
    static var allTests = [
        ("testBlogIndexGetsPostsInReverseOrder", testBlogIndexGetsPostsInReverseOrder),
        ("testBlogIndexGetsAllTags", testBlogIndexGetsAllTags),
        ("testBlogIndexGetsDisqusNameIfSetInConfig", testBlogIndexGetsDisqusNameIfSetInConfig),
        ("testBlogPostRetrievedCorrectlyFromSlugUrl", testBlogPostRetrievedCorrectlyFromSlugUrl),
        ("testDisqusNamePassedToBlogPostIfSpecified", testDisqusNamePassedToBlogPostIfSpecified),
        ("testAuthorView", testAuthorView),
        ("testTagView", testTagView)
    ]
    
    private var drop: Droplet!
    private var viewFactory: CapturingViewFactory!
    private var post: BlogPost!
    private var user: BlogUser!
    private var blogPostRequest: Request!
    private var authorRequest: Request!
    
    override func setUp() {
        blogPostRequest = try! Request(method: .get, uri: "/posts/test-path/")
        authorRequest = try! Request(method: .get, uri: "/authors/luke/")
    }
    
    func setupDrop(config: Config? = nil, loginUser: Bool = false) throws {
        drop = Droplet(arguments: ["dummy/path/", "prepare"], config: config)
        drop.database = Database(MemoryDriver())
        
        let steampress = SteamPress.Provider(postsPerPage: 5)
        steampress.setup(drop)
        
        viewFactory = CapturingViewFactory()
        let pathCreator = BlogPathCreator(blogPath: nil)
        let blogController = BlogController(drop: drop, pathCreator: pathCreator, viewFactory: viewFactory, postsPerPage: 5)
        blogController.addRoutes()
        
        let blogAdminController = BlogAdminController(drop: drop, pathCreator: pathCreator, viewFactory: viewFactory)
        blogAdminController.addRoutes()
        try drop.runCommands()
        
        if loginUser {
            let userCredentials = BlogUserCredentials(username: "luke", password: "1234", name: "Luke")
            user = BlogUser(credentials: userCredentials)
        }
        else {
            user = BlogUser(name: "Luke", username: "luke", password: "1234")
        }
        try user.save()
        post = BlogPost(title: "Test Path", contents: "A long time ago", author: user, creationDate: Date(), slugUrl: "test-path")
        try post.save()
    }
    
    func testBlogIndexGetsPostsInReverseOrder() throws {
        
    }
    
    func testBlogIndexGetsAllTags() throws {
        
    }
    
    func testBlogIndexGetsDisqusNameIfSetInConfig() throws {
        
    }
    
    func testBlogPostRetrievedCorrectlyFromSlugUrl() throws {
        try setupDrop()
        _ = try drop.respond(to: blogPostRequest)
        
        XCTAssertEqual(viewFactory.blogPost?.title, post.title)
        XCTAssertEqual(viewFactory.blogPost?.contents, post.contents)
        XCTAssertEqual(viewFactory.blogPostAuthor?.name, user.name)
        XCTAssertEqual(viewFactory.blogPostAuthor?.username, user.username)
    }
    
    func testDisqusNamePassedToBlogPostIfSpecified() throws {
        let expectedName = "steampress"
        let config = Config(try Node(node: [
            "disqus": try Node(node: [
                "disqusName": expectedName.makeNode()
                ])
        ]))
        try setupDrop(config: config)
        
        _ = try drop.respond(to: blogPostRequest)
        
        XCTAssertEqual(expectedName, viewFactory.disqusName)
    }
    
//    func testUserPassedToBlogPostIfLoggedIn() throws {
//        try setupDrop(loginUser: true)
//        let loginRequest = try Request(method: .post, uri: "/admin/login/")
//    }
    
    func testAuthorView() throws {
        try setupDrop()
        _ = try drop.respond(to: authorRequest)
        
        XCTAssertEqual(viewFactory.author?.username, user.username)
        XCTAssertEqual(viewFactory.authorPosts?.count, 1)
        XCTAssertEqual(viewFactory.authorPosts?.first?.title, post.title)
        XCTAssertEqual(viewFactory.authorPosts?.first?.contents, post.contents)
        XCTAssertEqual(viewFactory.isMyProfile, false)
    }
    
    func testTagView() throws {
        
    }
}

import URI

class CapturingViewFactory: ViewFactory {
    
    func createBlogPostView(uri: URI, errors: [String]?, title: String?, contents: String?, slugUrl: String?, tags: String?, isEditing: Bool, postToEdit: BlogPost?) throws -> View {
        return View(data: try "Test".makeBytes())
    }
    
    func createUserView(editing: Bool, errors: [String]?, name: String?, username: String?, passwordError: Bool?, confirmPasswordError: Bool?, resetPasswordRequired: Bool?, userId: Node?) throws -> View {
        return View(data: try "Test".makeBytes())
    }
    
    func createLoginView(loginWarning: Bool, errors: [String]?, username: String?, password: String?) throws -> View {
        return View(data: try "Test".makeBytes())
    }
    
    func createBlogAdminView(errors: [String]?) throws -> View {
        return View(data: try "Test".makeBytes())
    }
    
    func createResetPasswordView(errors: [String]?, passwordError: Bool?, confirmPasswordError: Bool?) throws -> View {
        return View(data: try "Test".makeBytes())
    }
    
    private(set) var author: BlogUser? = nil
    private(set) var isMyProfile: Bool? = nil
    private(set) var authorPosts: [BlogPost]? = nil
    func createProfileView(user: BlogUser, isMyProfile: Bool, posts: [BlogPost]) throws -> View {
        self.author = user
        self.isMyProfile = isMyProfile
        self.authorPosts = posts
        return View(data: try "Test".makeBytes())
    }
    
    private(set) var blogPost: BlogPost? = nil
    private(set) var blogPostAuthor: BlogUser? = nil
    private(set) var disqusName: String? = nil
    func blogPostView(post: BlogPost, author: BlogUser, user: BlogUser?, disqusName: String?) throws -> View {
        self.blogPost = post
        self.blogPostAuthor = author
        self.disqusName = disqusName
        return View(data: try "Test".makeBytes())
    }
}
