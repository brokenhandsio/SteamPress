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
        self.application.presenter.makePresenter!(self)
    }
}

extension Application {
    var presenter: PresenterFactory {
        get {
            if let existing = self.userInfo["blogPresenter"] as? PresenterFactory {
                return existing
            } else {
                let new = PresenterFactory()
                self.userInfo["blogPresenter"] = new
                return new
            }
        }
        set {
            self.userInfo["blogPresenter"] = newValue
        }
    }
}

struct PresenterFactory {
    var makePresenter: ((Request) -> BlogPresenter)?
    mutating func use(_ makePresenter: @escaping (Request) -> BlogPresenter) {
        self.makePresenter = makePresenter
    }
}
