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
        return createFutureView(on: req)
    }
    
    private(set) var post: BlogPost?
    private(set) var postAuthor: BlogUser?
    func postView(on req: Request, post: BlogPost, author: BlogUser) -> EventLoopFuture<View> {
        self.post = post
        self.postAuthor = author
        return createFutureView(on: req)
    }
    
    private(set) var allAuthors: [BlogUser]?
    func allAuthorsView(on req: Request, authors: [BlogUser]) -> Future<View> {
        self.allAuthors = authors
        return createFutureView(on: req)
    }
    
    private(set) var author: BlogUser?
    private(set) var authorPosts: [BlogPost]?
    func authorView(on req: Request, author: BlogUser, posts: [BlogPost]) -> Future<View> {
        self.author = author
        self.authorPosts = posts
        return createFutureView(on: req)
    }
    
    // MARK: - Helpers

    func createFutureView(on req: Request) -> Future<View> {
        let data = "some HTML".convertToData()
        let view = View(data: data)
        return req.future(view)
    }
}


