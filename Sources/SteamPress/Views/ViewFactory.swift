import Vapor
import URI
import Paginator

protocol ViewFactory {
    
    // MARK: - Admin Controller
    func createBlogPostView(uri: URI, errors: [String]?, title: String?, contents: String?, slugUrl: String?, tags: String?, isEditing: Bool, postToEdit: BlogPost?) throws -> View
    func createUserView(editing: Bool, errors: [String]?, name: String?, username: String?, passwordError: Bool?, confirmPasswordError: Bool?, resetPasswordRequired: Bool?, userId: Node?) throws -> View
    func createLoginView(loginWarning: Bool, errors: [String]?, username: String?, password: String?) throws -> View
    func createBlogAdminView(errors: [String]?) throws -> View
    func createResetPasswordView(errors: [String]?, passwordError: Bool?, confirmPasswordError: Bool?) throws -> View
    func createProfileView(author: BlogUser, isMyProfile: Bool, posts: [BlogPost], loggedInUser: BlogUser?, disqusName: String?) throws -> View
    
    // MARK: - Blog Controller
    func blogIndexView(paginatedPosts: Paginator<BlogPost>, tags: [BlogTag], loggedInUser: BlogUser?, disqusName: String?) throws -> View
    func blogPostView(post: BlogPost, author: BlogUser, user: BlogUser?, disqusName: String?) throws -> View
    func tagView(tag: BlogTag, posts: [BlogPost], user: BlogUser?, disqusName: String?) throws -> View
}
