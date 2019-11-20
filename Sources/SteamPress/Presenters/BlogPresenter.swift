import Vapor

public protocol BlogPresenter: Service {
    func indexView(on req: Request, posts: [BlogPost], tags: [BlogTag], authors: [BlogUser]) -> EventLoopFuture<View>
    func postView(on req: Request, post: BlogPost, author: BlogUser) -> EventLoopFuture<View>
    func allAuthorsView(on req: Request, authors: [BlogUser]) -> EventLoopFuture<View>
    func authorView(on req: Request, author: BlogUser, posts: [BlogPost]) -> EventLoopFuture<View>
    func allTagsView(on req: Request, tags: [BlogTag]) -> EventLoopFuture<View>
    func tagView(on req: Request, tag: BlogTag, posts: [BlogPost]) -> EventLoopFuture<View>
    func searchView(on req: Request, posts: [BlogPost]?, searchTerm: String?) -> EventLoopFuture<View>
    func loginView(on req: Request, loginWarning: Bool, errors: [String]?, username: String?, usernameError: Bool, passwordError: Bool) throws -> EventLoopFuture<View>
}
