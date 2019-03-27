import Vapor

public protocol BlogAdminPresenter: Service {
    func createIndexView(on req: Request) -> Future<View>
    func createPostView(on req: Request) -> Future<View>
}
