import Vapor

public protocol BlogPresenter: Service {
    func allAuthorsView(on req: Request, authors: [BlogUser]) -> Future<View>
}
