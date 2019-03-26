import Vapor

public protocol BlogAdminPresenter: Service {
    func createPostView(on req: Request) -> Future<View>
}
