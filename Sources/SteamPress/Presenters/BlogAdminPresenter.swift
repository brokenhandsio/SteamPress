import Vapor

public protocol BlogAdminPresenter: Service {
    func createIndexView(on req: Request) -> Future<View>
    func createPostView(on req: Request, errors: [String]?) -> Future<View>
    func createUserView(on req: Request, errors: [String]?) -> Future<View>
}
