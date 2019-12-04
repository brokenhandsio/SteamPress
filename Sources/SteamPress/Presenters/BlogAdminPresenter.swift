import Vapor

public protocol BlogAdminPresenter: Service {
    func createIndexView(on container: Container, errors: [String]?) -> EventLoopFuture<View>
    func createPostView(on container: Container, errors: [String]?, title: String?, contents: String?, slugURL: String?, tags: [String]?, isEditing: Bool, post: BlogPost?, isDraft: Bool?) -> EventLoopFuture<View>
    func createUserView(on container: Container, errors: [String]?, name: String?, username: String?, passwordError: Bool, confirmPasswordError: Bool, userID: Int?, profilePicture: String?, twitterHandle: String?, biography: String?, tagline: String?) -> EventLoopFuture<View>
    func createResetPasswordView(on container: Container, errors: [String]?, passwordError: Bool?, confirmPasswordError: Bool?) -> EventLoopFuture<View>
}
