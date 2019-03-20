import SteamPress
import Vapor

import Foundation

class CapturingBlogPresenter: BlogPresenter {

    // MARK: - BlogPresenter
    private(set) var allAuthors: [BlogUser]?
    func allAuthorsView(on req: Request, authors: [BlogUser]) -> Future<View> {
        self.allAuthors = authors
        return createFutureView(on: req)
    }
    
    private(set) var authorPosts: [BlogPost]?
    func authorView(on req: Request, author: BlogUser, posts: [BlogPost]) -> Future<View> {
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


