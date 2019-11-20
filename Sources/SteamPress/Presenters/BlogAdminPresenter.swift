import Vapor

public protocol BlogAdminPresenter: Service {
    func createIndexView(on req: Request, errors: [String]?) -> EventLoopFuture<View>
    func createPostView(on req: Request, errors: [String]?, title: String?, contents: String?, slugURL: String?, tags: [String]?, isEditing: Bool, post: BlogPost?, isDraft: Bool?) -> EventLoopFuture<View>
    func createUserView(on req: Request, errors: [String]?, name: String?, username: String?, passwordError: Bool, confirmPasswordError: Bool, userID: Int?, profilePicture: String?, twitterHandle: String?, biography: String?, tagline: String?) -> EventLoopFuture<View>
    func createResetPasswordView(on req: Request, errors: [String]?, passwordError: Bool?, confirmPasswordError: Bool?) -> EventLoopFuture<View>
}
