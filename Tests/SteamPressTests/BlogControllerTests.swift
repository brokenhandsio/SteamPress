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
        ("testDisqusNamePassedToBlogPostIfSpecified", testDisqusNamePassedToBlogPostIfSpecified),
    ]
    
    private var drop: Droplet!
    private var viewFactory: CapturingViewFactory!
    private var post: BlogPost!
    private var user: BlogUser!
    private var blogPostRequest: Request!
    
    override func setUp() {
        blogPostRequest = try! Request(method: .get, uri: "/posts/test-path")
    }
    
    func setupDrop(config: Config? = nil) throws {
        drop = Droplet(arguments: ["dummy/path/", "prepare"], config: config)
        drop.database = Database(MemoryDriver())
        
        let steampress = SteamPress.Provider(postsPerPage: 5)
        steampress.setup(drop)
        
        viewFactory = CapturingViewFactory()
        let blogController = BlogController(drop: drop, pathCreator: BlogPathCreator(blogPath: nil), viewFactory: viewFactory, postsPerPage: 5)
        blogController.addRoutes()
        try drop.runCommands()
        
        user = BlogUser(name: "Luke", username: "luke", password: "1234")
        try user.save()
        post = BlogPost(title: "Test Path", contents: "A long time ago", author: user, creationDate: Date(), slugUrl: "test-path")
        try post.save()
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
    
    func createProfileView(user: BlogUser, isMyProfile: Bool) throws -> View {
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
