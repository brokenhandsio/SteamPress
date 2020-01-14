import Vapor

public protocol BlogPresenter: Service {
    func indexView(on container: Container, posts: [BlogPost], tags: [BlogTag], authors: [BlogUser], pageInformation: BlogGlobalPageInformation) -> EventLoopFuture<View>
    func postView(on container: Container, post: BlogPost, author: BlogUser, pageInformation: BlogGlobalPageInformation) -> EventLoopFuture<View>
    func allAuthorsView(on container: Container, authors: [BlogUser], authorPostCounts: [Int: Int], pageInformation: BlogGlobalPageInformation) -> EventLoopFuture<View>
    func authorView(on container: Container, author: BlogUser, posts: [BlogPost], postCount: Int, pageInformation: BlogGlobalPageInformation) -> EventLoopFuture<View>
    func allTagsView(on container: Container, tags: [BlogTag], tagPostCounts: [Int: Int], pageInformation: BlogGlobalPageInformation) -> EventLoopFuture<View>
    func tagView(on container: Container, tag: BlogTag, posts: [BlogPost], pageInformation: BlogGlobalPageInformation) -> EventLoopFuture<View>
    func searchView(on container: Container, posts: [BlogPost], searchTerm: String?, pageInformation: BlogGlobalPageInformation) -> EventLoopFuture<View>
    func loginView(on container: Container, loginWarning: Bool, errors: [String]?, username: String?, usernameError: Bool, passwordError: Bool, rememberMe: Bool, pageInformation: BlogGlobalPageInformation) -> EventLoopFuture<View>
}
