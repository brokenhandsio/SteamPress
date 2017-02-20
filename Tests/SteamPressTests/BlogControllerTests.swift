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

class BlogControllerTests: XCTestCase {
    static var allTests = [
        ("testDisqusNamePassedToBlogPostIfSpecified", testDisqusNamePassedToBlogPostIfSpecified),
    ]
    
    func testDisqusNamePassedToBlogPostIfSpecified() throws {
        let drop = Droplet(arguments: ["dummy/path/", "prepare"])
        drop.database = Database(MemoryDriver())
        
        let blogController = BlogController(drop: drop, pathCreator: BlogPathCreator(blogPath: "blog"), viewFactory: CapturingViewFactory(), postsPerPage: 5)
        blogController.addRoutes()
        
        try drop.runCommands()
    }
}

import URI

struct CapturingViewFactory: ViewFactory {
    
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
}
