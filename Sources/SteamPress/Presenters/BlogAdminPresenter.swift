import Vapor

public protocol BlogAdminPresenter: Service {
    func createIndexView(on req: Request, errors: [String]?) -> Future<View>
    func createPostView(on req: Request, errors: [String]?) -> Future<View>
    func createUserView(on req: Request, errors: [String]?, name: String?, username: String?, passwordError: Bool, confirmPasswordError: Bool, userID: Int?, profilePicture: String?, twitterHandle: String?, biography: String?, tagline: String?) -> Future<View>
    func createResetPasswordView(on req: Request, errors: [String]?, passwordError: Bool?, confirmPasswordError: Bool?) -> Future<View>
}
