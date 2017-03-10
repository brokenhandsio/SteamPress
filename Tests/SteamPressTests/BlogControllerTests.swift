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
import Foundation

class BlogControllerTests: XCTestCase {
    static var allTests = [
        ("testBlogIndexGetsPostsInReverseOrder", testBlogIndexGetsPostsInReverseOrder),
        ("testBlogIndexGetsAllTags", testBlogIndexGetsAllTags),
        ("testBlogIndexGetsDisqusNameIfSetInConfig", testBlogIndexGetsDisqusNameIfSetInConfig),
        ("testBlogPostRetrievedCorrectlyFromSlugUrl", testBlogPostRetrievedCorrectlyFromSlugUrl),
        ("testDisqusNamePassedToBlogPostIfSpecified", testDisqusNamePassedToBlogPostIfSpecified),
        ("testAuthorView", testAuthorView),
        ("testAuthorViewGetsDisqusNameIfSet", testAuthorViewGetsDisqusNameIfSet),
        ("testTagView", testTagView),
        ("testTagViewGetsDisquqNameIfSet", testTagViewGetsDisquqNameIfSet),
    ]
    
    private var drop: Droplet!
    private var viewFactory: CapturingViewFactory!
    private var post: BlogPost!
    private var user: BlogUser!
    private var blogPostRequest: Request!
    private var authorRequest: Request!
    private var tagRequest: Request!
    private var blogIndexRequest: Request!
    
    override func setUp() {
        blogPostRequest = try! Request(method: .get, uri: "/posts/test-path/")
        authorRequest = try! Request(method: .get, uri: "/authors/luke/")
        tagRequest = try! Request(method: .get, uri: "/tags/tatooine/")
        blogIndexRequest = try! Request(method: .get, uri: "/")
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
            user = try BlogUser(credentials: userCredentials)
        }
        else {
            user = BlogUser(name: "Luke", username: "luke", password: "1234")
        }
        try user.save()
        post = BlogPost(title: "Test Path", contents: "A long time ago", author: user, creationDate: Date(), slugUrl: "test-path")
        try post.save()
        
        try BlogTag.addTag("tatooine", to: post)
    }
    
    func testBlogIndexGetsPostsInReverseOrder() throws {
        try setupDrop()
        
        var post2 = BlogPost(title: "A New Path", contents: "In a galaxy far, far, away", author: user, creationDate: Date(), slugUrl: "a-new-path")
        try post2.save()
        
        _ = try drop.respond(to: blogIndexRequest)
        
        XCTAssertEqual(viewFactory.paginatedPosts?.total, 2)
        XCTAssertEqual(viewFactory.paginatedPosts?.data?[0].title, "A New Path")
        XCTAssertEqual(viewFactory.paginatedPosts?.data?[1].title, "Test Path")
        
    }
    
    func testBlogIndexGetsAllTags() throws {
        try setupDrop()
        _ = try drop.respond(to: blogIndexRequest)
        
        XCTAssertEqual(viewFactory.blogIndexTags?.count, 1)
        XCTAssertEqual(viewFactory.blogIndexTags?.first?.name, "tatooine")
    }
    
    func testBlogIndexGetsDisqusNameIfSetInConfig() throws {
        let expectedName = "steampress"
        let config = Config(try Node(node: [
            "disqus": try Node(node: [
                "disqusName": expectedName.makeNode()
                ])
            ]))
        try setupDrop(config: config)
        
        _ = try drop.respond(to: blogIndexRequest)
        
        XCTAssertEqual(expectedName, viewFactory.indexDisqusName)
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
//        let requestData = "{\"username\": \"\(user.name)\", \"password\": \"1234\"}"
//        let loginRequest = try Request(method: .post, uri: "/admin/login/", body: requestData.makeBody())
//         _ = try drop.respond(to: loginRequest)
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
    
    func testAuthorViewGetsDisqusNameIfSet() throws {
        let expectedName = "steampress"
        let config = Config(try Node(node: [
            "disqus": try Node(node: [
                "disqusName": expectedName.makeNode()
                ])
            ]))
        try setupDrop(config: config)
        
        _ = try drop.respond(to: authorRequest)
        
        XCTAssertEqual(expectedName, viewFactory.authorDisqusName)
    }
    
    func testTagView() throws {
        try setupDrop()
        _ = try drop.respond(to: tagRequest)
        
        XCTAssertEqual(viewFactory.tagPosts?.total, 1)
        XCTAssertEqual(viewFactory.tagPosts?.data?[0].title, post.title)
        XCTAssertEqual(viewFactory.tag?.name, "tatooine")
    }
    
    func testTagViewGetsDisquqNameIfSet() throws {
        let expectedName = "steampress"
        let config = Config(try Node(node: [
            "disqus": try Node(node: [
                "disqusName": expectedName.makeNode()
                ])
            ]))
        try setupDrop(config: config)
        
        _ = try drop.respond(to: tagRequest)
        
        XCTAssertEqual(expectedName, viewFactory.tagDisqusName)
    }
}

import URI
import Paginator

class CapturingViewFactory: ViewFactory {
    
    func createBlogPostView(uri: URI, errors: [String]?, title: String?, contents: String?, slugUrl: String?, tags: [Node]?, isEditing: Bool, postToEdit: BlogPost?) throws -> View {
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
    private(set) var authorDisqusName: String? = nil
    func createProfileView(author: BlogUser, isMyProfile: Bool, posts: [BlogPost], loggedInUser: BlogUser?, disqusName: String?, siteTwitterHandle: String?) throws -> View {
        self.author = author
        self.isMyProfile = isMyProfile
        self.authorPosts = posts
        self.authorDisqusName = disqusName
        return View(data: try "Test".makeBytes())
    }
    
    private(set) var blogPost: BlogPost? = nil
    private(set) var blogPostAuthor: BlogUser? = nil
    private(set) var disqusName: String? = nil
    func blogPostView(uri: URI, post: BlogPost, author: BlogUser, user: BlogUser?, disqusName: String?, siteTwitterHandle: String?) throws -> View {
        self.blogPost = post
        self.blogPostAuthor = author
        self.disqusName = disqusName
        return View(data: try "Test".makeBytes())
    }
    
    private(set) var tag: BlogTag? = nil
    private(set) var tagPosts: Paginator<BlogPost>? = nil
    private(set) var tagUser: BlogUser? = nil
    private(set) var tagDisqusName: String? = nil
    func tagView(tag: BlogTag, paginatedPosts: Paginator<BlogPost>, user: BlogUser?, disqusName: String?, siteTwitterHandle: String?) throws -> View {
        self.tag = tag
        self.tagPosts = paginatedPosts
        self.tagUser = user
        self.tagDisqusName = disqusName
        
        return View(data: try "Test".makeBytes())
    }
    
    private(set) var blogIndexTags: [BlogTag]? = nil
    private(set) var indexDisqusName: String? = nil
    private(set) var paginatedPosts: Paginator<BlogPost>? = nil
    func blogIndexView(paginatedPosts: Paginator<BlogPost>, tags: [BlogTag], loggedInUser: BlogUser?, disqusName: String?, siteTwitterHandle: String?) throws -> View {
        self.blogIndexTags = tags
        self.paginatedPosts = paginatedPosts
        self.indexDisqusName = disqusName
        return View(data: try "Test".makeBytes())
    }
}
