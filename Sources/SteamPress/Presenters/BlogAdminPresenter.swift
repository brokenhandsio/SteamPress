import Vapor

public protocol BlogAdminPresenter {
    func createIndexView(posts: [BlogPost], users: [BlogUser], errors: [String]?, pageInformation: BlogAdminPageInformation) -> EventLoopFuture<View>
    func createPostView(errors: [String]?, title: String?, contents: String?, slugURL: String?, tags: [String]?, isEditing: Bool, post: BlogPost?, isDraft: Bool?, titleError: Bool, contentsError: Bool, pageInformation: BlogAdminPageInformation) -> EventLoopFuture<View>
    func createUserView(editing: Bool, errors: [String]?, name: String?, nameError: Bool, username: String?, usernameErorr: Bool, passwordError: Bool, confirmPasswordError: Bool, resetPasswordOnLogin: Bool, userID: Int?, profilePicture: String?, twitterHandle: String?, biography: String?, tagline: String?, pageInformation: BlogAdminPageInformation) -> EventLoopFuture<View>
    func createResetPasswordView(errors: [String]?, passwordError: Bool?, confirmPasswordError: Bool?, pageInformation: BlogAdminPageInformation) -> EventLoopFuture<View>
}

extension Request {
    var adminPresenter: BlogAdminPresenter {
        self.application.adminPresenter.makePresenter!(self)
    }
}

extension Application {
    var adminPresenter: AdminPresenterFactory {
        get {
            if let existing = self.userInfo["blogAdminPresenter"] as? AdminPresenterFactory {
                return existing
            } else {
                let new = AdminPresenterFactory()
                self.userInfo["blogAdminPresenter"] = new
                return new
            }
        }
        set {
            self.userInfo["blogAdminPresenter"] = newValue
        }
    }
}

struct AdminPresenterFactory {
    var makePresenter: ((Request) -> BlogAdminPresenter)?
    mutating func use(_ makePresenter: @escaping (Request) -> BlogAdminPresenter) {
        self.makePresenter = makePresenter
    }
}
