import Vapor

public protocol BlogPresenter: Service {
    func allAuthorsView(on req: Request, authors: [BlogUser]) -> Future<View>
    func authorView(on req: Request, author: BlogUser, posts: [BlogPost]) -> Future<View>
}
