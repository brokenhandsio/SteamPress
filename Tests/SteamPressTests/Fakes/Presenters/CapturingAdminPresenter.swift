import SteamPress
import Vapor

class CapturingAdminPresenter: BlogAdminPresenter {

    // MARK: - BlogPresenter
    private(set) var adminViewErrors: [String]?
    private(set) var adminViewPosts: [BlogPost]?
    private(set) var adminViewUsers: [BlogUser]?
    private(set) var adminViewPageInformation: BlogAdminPageInformation?
    func createIndexView(on container: Container, posts: [BlogPost], users: [BlogUser], errors: [String]?, pageInformation: BlogAdminPageInformation) -> EventLoopFuture<View> {
        #warning("Test this is set up when getting the admin page")
        self.adminViewErrors = errors
        self.adminViewPosts = posts
        self.adminViewUsers = users
        self.adminViewPageInformation = pageInformation
        return createFutureView(on: container)
    }

    private(set) var createPostErrors: [String]?
    private(set) var createPostTitle: String?
    private(set) var createPostContents: String?
    private(set) var createPostTags: [String]?
    private(set) var createPostIsEditing: Bool?
    private(set) var createPostPost: BlogPost?
    private(set) var createPostDraft: Bool?
    private(set) var createPostSlugURL: String?
    private(set) var createPostTitleError: Bool?
    private(set) var createPostContentsError: Bool?
    #warning("Test page information for all functions in this")
    func createPostView(on container: Container, errors: [String]?, title: String?, contents: String?, slugURL: String?, tags: [String]?, isEditing: Bool, post: BlogPost?, isDraft: Bool?, titleError: Bool, contentsError: Bool, pageInformation: BlogAdminPageInformation) -> EventLoopFuture<View> {
        self.createPostErrors = errors
        self.createPostTitle = title
        self.createPostContents = contents
        self.createPostSlugURL = slugURL
        self.createPostTags = tags
        self.createPostIsEditing = isEditing
        self.createPostPost = post
        self.createPostDraft = isDraft
        self.createPostTitleError = titleError
        self.createPostContentsError = contentsError
        return createFutureView(on: container)
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
    private(set) var createUserEditing: Bool?
    private(set) var createUserNameError: Bool?
    private(set) var createUserUsernameError: Bool?
    func createUserView(on container: Container, editing: Bool, errors: [String]?, name: String?, nameError: Bool, username: String?, usernameErorr: Bool, passwordError: Bool, confirmPasswordError: Bool, resetPasswordOnLogin: Bool, userID: Int?, profilePicture: String?, twitterHandle: String?, biography: String?, tagline: String?, pageInformation: BlogAdminPageInformation) -> EventLoopFuture<View> {
        self.createUserEditing = editing
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
        self.createUserNameError = nameError
        self.createUserUsernameError = usernameErorr
        self.createUserResetPasswordRequired = resetPasswordOnLogin
        return createFutureView(on: container)
    }

    private(set) var resetPasswordErrors: [String]?
    private(set) var resetPasswordError: Bool?
    private(set) var resetPasswordConfirmError: Bool?
    func createResetPasswordView(on container: Container, errors: [String]?, passwordError: Bool?, confirmPasswordError: Bool?, pageInformation: BlogAdminPageInformation) -> EventLoopFuture<View> {
        self.resetPasswordErrors = errors
        self.resetPasswordError = passwordError
        self.resetPasswordConfirmError = confirmPasswordError
        return createFutureView(on: container)
    }

    // MARK: - Helpers

    func createFutureView(on container: Container) -> EventLoopFuture<View> {
        let data = "some HTML".convertToData()
        let view = View(data: data)
        return container.future(view)
    }
}
