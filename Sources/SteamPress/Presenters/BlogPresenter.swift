import Vapor

public protocol BlogPresenter: Service {
    func indexView(on req: Request, posts: [BlogPost], tags: [BlogTag], authors: [BlogUser]) -> Future<View>
    func postView(on req: Request, post: BlogPost, author: BlogUser) -> Future<View>
    func allAuthorsView(on req: Request, authors: [BlogUser]) -> Future<View>
    func authorView(on req: Request, author: BlogUser, posts: [BlogPost]) -> Future<View>
    func allTagsView(on req: Request, tags: [BlogTag]) -> Future<View>
    func tagView(on req: Request, tag: BlogTag, posts: [BlogPost]) -> Future<View>
    func searchView(on req: Request, posts: [BlogPost]?, searchTerm: String?) -> Future<View>
}
