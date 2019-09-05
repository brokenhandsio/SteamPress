import SteamPress
import Vapor

import Foundation

class CapturingBlogPresenter: BlogPresenter {

    // MARK: - BlogPresenter
    private(set) var indexPosts: [BlogPost]?
    private(set) var indexTags: [BlogTag]?
    private(set) var indexAuthors: [BlogUser]?
    func indexView(on req: Request, posts: [BlogPost], tags: [BlogTag], authors: [BlogUser]) -> EventLoopFuture<View> {
        self.indexPosts = posts
        self.indexTags = tags
        self.indexAuthors = authors
        return TestDataBuilder.createFutureView(on: req)
    }
    
    private(set) var post: BlogPost?
    private(set) var postAuthor: BlogUser?
    func postView(on req: Request, post: BlogPost, author: BlogUser) -> EventLoopFuture<View> {
        self.post = post
        self.postAuthor = author
        return TestDataBuilder.createFutureView(on: req)
    }
    
    private(set) var allAuthors: [BlogUser]?
    func allAuthorsView(on req: Request, authors: [BlogUser]) -> Future<View> {
        self.allAuthors = authors
        return TestDataBuilder.createFutureView(on: req)
    }
    
    private(set) var author: BlogUser?
    private(set) var authorPosts: [BlogPost]?
    func authorView(on req: Request, author: BlogUser, posts: [BlogPost]) -> Future<View> {
        self.author = author
        self.authorPosts = posts
        return TestDataBuilder.createFutureView(on: req)
    }
    
    private(set) var allTagsPageTags: [BlogTag]?
    func allTagsView(on req: Request, tags: [BlogTag]) -> EventLoopFuture<View> {
        self.allTagsPageTags = tags
        return TestDataBuilder.createFutureView(on: req)
    }
    
    private(set) var tag: BlogTag?
    private(set) var tagPosts: [BlogPost]?
    func tagView(on req: Request, tag: BlogTag, posts: [BlogPost]) -> Future<View> {
        self.tag = tag
        self.tagPosts = posts
        return TestDataBuilder.createFutureView(on: req)
    }
    
    private(set) var searchPosts: [BlogPost]?
    private(set) var searchTerm: String?
    func searchView(on req: Request, posts: [BlogPost]?, searchTerm: String?) -> EventLoopFuture<View> {
        self.searchPosts = posts
        self.searchTerm = searchTerm
        return TestDataBuilder.createFutureView(on: req)
    }
    
    private(set) var loginWarning: Bool?
    private(set) var loginErrors: [String]?
    private(set) var loginUsername: String?
    private(set) var loginUsernameError: Bool?
    private(set) var loginPasswordError: Bool?
    func loginView(on req: Request, loginWarning: Bool, errors: [String]?, username: String?, usernameError: Bool, passwordError: Bool) throws -> EventLoopFuture<View> {
        self.loginWarning = loginWarning
        self.loginErrors = errors
        self.loginUsername = username
        self.loginUsernameError = usernameError
        self.loginPasswordError = passwordError
        return TestDataBuilder.createFutureView(on: req)
    }
}


