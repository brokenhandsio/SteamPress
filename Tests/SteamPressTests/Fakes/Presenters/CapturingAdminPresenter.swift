import SteamPress
import Vapor

class CapturingAdminPresenter: BlogAdminPresenter {

    // MARK: - BlogPresenter
    private(set) var adminViewErrors: [String]?
    func createIndexView(on req: Request, errors: [String]?) -> EventLoopFuture<View> {
        self.adminViewErrors = errors
        return createFutureView(on: req)
    }

    private(set) var createPostErrors: [String]?
    private(set) var createPostTitle: String?
    private(set) var createPostContents: String?
    private(set) var createPostTags: [String]?
    private(set) var createPostIsEditing: Bool?
    private(set) var createPostPost: BlogPost?
    private(set) var createPostDraft: Bool?
    private(set) var createPostSlugURL: String?
    func createPostView(on req: Request, errors: [String]?, title: String?, contents: String?, slugURL: String?, tags: [String]?, isEditing: Bool, post: BlogPost?, isDraft: Bool?) -> EventLoopFuture<View> {
        self.createPostErrors = errors
        self.createPostTitle = title
        self.createPostContents = contents
        self.createPostSlugURL = slugURL
        self.createPostTags = tags
        self.createPostIsEditing = isEditing
        self.createPostPost = post
        self.createPostDraft = isDraft
        return createFutureView(on: req)
    }

    private(set) var createUserErrors: [String]?
    private(set) var createUserName: String?
    private(set) var createUserUsername: String?
    private(set) var createUserPasswordError: Bool?
    private(set) var createUserConfirmPasswordError: Bool?
    private(set) var createUserResetPasswordRequired: Bool?
    private(set) var createUserUserID: Int?
    private(set) var createUserProfilePicture: String?
    private(set) var createUserTwitterHandle: String?
    private(set) var createUserBiography: String?
    private(set) var createUserTagline: String?
    func createUserView(on req: Request, errors: [String]?, name: String?, username: String?, passwordError: Bool, confirmPasswordError: Bool, userID: Int?, profilePicture: String?, twitterHandle: String?, biography: String?, tagline: String?) -> EventLoopFuture<View> {
        self.createUserErrors = errors
        self.createUserName = name
        self.createUserUsername = username
        self.createUserPasswordError = passwordError
        self.createUserConfirmPasswordError = confirmPasswordError
        self.createUserUserID = userID
        self.createUserProfilePicture = profilePicture
        self.createUserTwitterHandle = twitterHandle
        self.createUserBiography = biography
        self.createUserTagline = tagline
        return createFutureView(on: req)
    }

    private(set) var resetPasswordErrors: [String]?
    private(set) var resetPasswordError: Bool?
    private(set) var resetPasswordConfirmError: Bool?
    func createResetPasswordView(on req: Request, errors: [String]?, passwordError: Bool?, confirmPasswordError: Bool?) -> EventLoopFuture<View> {
        self.resetPasswordErrors = errors
        self.resetPasswordError = passwordError
        self.resetPasswordConfirmError = confirmPasswordError
        return createFutureView(on: req)
    }

    // MARK: - Helpers

    func createFutureView(on req: Request) -> EventLoopFuture<View> {
        let data = "some HTML".convertToData()
        let view = View(data: data)
        return req.future(view)
    }
}
