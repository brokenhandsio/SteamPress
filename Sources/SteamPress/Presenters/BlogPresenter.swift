import Vapor

public protocol BlogPresenter {
    func indexView(posts: [BlogPost], tags: [BlogTag], authors: [BlogUser], tagsForPosts: [Int: [BlogTag]], pageInformation: BlogGlobalPageInformation, paginationTagInfo: PaginationTagInformation) -> EventLoopFuture<View>
    func postView(post: BlogPost, author: BlogUser, tags: [BlogTag], pageInformation: BlogGlobalPageInformation) -> EventLoopFuture<View>
    func allAuthorsView(authors: [BlogUser], authorPostCounts: [Int: Int], pageInformation: BlogGlobalPageInformation) -> EventLoopFuture<View>
    func authorView(author: BlogUser, posts: [BlogPost], postCount: Int, tagsForPosts: [Int: [BlogTag]], pageInformation: BlogGlobalPageInformation, paginationTagInfo: PaginationTagInformation) -> EventLoopFuture<View>
    func allTagsView(tags: [BlogTag], tagPostCounts: [Int: Int], pageInformation: BlogGlobalPageInformation) -> EventLoopFuture<View>
    func tagView(tag: BlogTag, posts: [BlogPost], authors: [BlogUser], totalPosts: Int, pageInformation: BlogGlobalPageInformation, paginationTagInfo: PaginationTagInformation) -> EventLoopFuture<View>
    func searchView(totalResults: Int, posts: [BlogPost], authors: [BlogUser], searchTerm: String?, tagsForPosts: [Int: [BlogTag]], pageInformation: BlogGlobalPageInformation, paginationTagInfo: PaginationTagInformation) -> EventLoopFuture<View>
    func loginView(loginWarning: Bool, errors: [String]?, username: String?, usernameError: Bool, passwordError: Bool, rememberMe: Bool, pageInformation: BlogGlobalPageInformation) -> EventLoopFuture<View>
}

extension Request {
    var blogPresenter: BlogPresenter {
        self.application.blogPresenterFactory.makePresenter!(self)
    }
}

extension Application {
    private struct BlogPresenterKey: StorageKey {
        typealias Value = BlogPresenterFactory
    }
    var blogPresenterFactory: BlogPresenterFactory {
        get {
            self.storage[BlogPresenterKey.self] ?? .init()
        }
        set {
            self.storage[BlogPresenterKey.self] = newValue
        }
    }
}

struct BlogPresenterFactory {
    var makePresenter: ((Request) -> BlogPresenter)?
    mutating func use(_ makePresenter: @escaping (Request) -> BlogPresenter) {
        self.makePresenter = makePresenter
    }
}
