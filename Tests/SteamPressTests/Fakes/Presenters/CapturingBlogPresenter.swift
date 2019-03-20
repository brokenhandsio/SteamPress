import SteamPress
import Vapor

import Foundation

class CapturingBlogPresenter: BlogPresenter {

    private(set) var allAuthors: [BlogUser]?
    func allAuthorsView(on req: Request, authors: [BlogUser]) -> EventLoopFuture<View> {
        self.allAuthors = authors
        let data = "authors".convertToData()
        let view = View(data: data)
        return req.future(view)
    }


}


