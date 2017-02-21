import Vapor
import URI

protocol ViewFactory {
    
    // MARK: - Admin Controller
    func createBlogPostView(uri: URI, errors: [String]?, title: String?, contents: String?, slugUrl: String?, tags: String?, isEditing: Bool, postToEdit: BlogPost?) throws -> View
    func createUserView(editing: Bool, errors: [String]?, name: String?, username: String?, passwordError: Bool?, confirmPasswordError: Bool?, resetPasswordRequired: Bool?, userId: Node?) throws -> View
    func createLoginView(loginWarning: Bool, errors: [String]?, username: String?, password: String?) throws -> View
    func createBlogAdminView(errors: [String]?) throws -> View
    func createResetPasswordView(errors: [String]?, passwordError: Bool?, confirmPasswordError: Bool?) throws -> View
    func createProfileView(user: BlogUser, isMyProfile: Bool) throws -> View
    
    // MARK: - Blog Controller
    func blogPostView(post: BlogPost, author: BlogUser, user: BlogUser?, disqusName: String?) throws -> View
}
