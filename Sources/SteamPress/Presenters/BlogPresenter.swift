import Vapor

public protocol BlogPresenter: Service {
    func indexView(on container: Container, posts: [BlogPost], tags: [BlogTag], authors: [BlogUser]) -> EventLoopFuture<View>
    func postView(on container: Container, post: BlogPost, author: BlogUser) -> EventLoopFuture<View>
    func allAuthorsView(on container: Container, authors: [BlogUser]) -> EventLoopFuture<View>
    func authorView(on container: Container, author: BlogUser, posts: [BlogPost]) -> EventLoopFuture<View>
    func allTagsView(on container: Container, tags: [BlogTag]) -> EventLoopFuture<View>
    func tagView(on container: Container, tag: BlogTag, posts: [BlogPost]) -> EventLoopFuture<View>
    func searchView(on container: Container, posts: [BlogPost]?, searchTerm: String?) -> EventLoopFuture<View>
    func loginView(on container: Container, loginWarning: Bool, errors: [String]?, username: String?, usernameError: Bool, passwordError: Bool) throws -> EventLoopFuture<View>
}
