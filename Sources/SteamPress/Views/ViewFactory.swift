import Vapor
import URI
//import Paginator
import Foundation

protocol ViewFactory {
    
    // MARK: - Admin Controller
    func createBlogPostView(uri: URI, errors: [String]?, title: String?, contents: String?, slugUrl: String?, tags: [Node]?, isEditing: Bool, postToEdit: BlogPost?, draft: Bool) throws -> View
    func createUserView(editing: Bool, errors: [String]?, name: String?, username: String?, passwordError: Bool?, confirmPasswordError: Bool?, resetPasswordRequired: Bool?, userId: Node?, profilePicture: String?, twitterHandle: String?, biography: String?, tagline: String?) throws -> View
    func createLoginView(loginWarning: Bool, errors: [String]?, username: String?, password: String?) throws -> View
    func createBlogAdminView(errors: [String]?) throws -> View
    func createResetPasswordView(errors: [String]?, passwordError: Bool?, confirmPasswordError: Bool?) throws -> View
    func createProfileView(uri: URI, author: BlogUser, isMyProfile: Bool, paginatedPosts: Paginator<BlogPost>, loggedInUser: BlogUser?, disqusName: String?, siteTwitterHandle: String?) throws -> View
    
    // MARK: - Blog Controller
    func blogIndexView(uri: URI, paginatedPosts: Paginator<BlogPost>, tags: [BlogTag], authors: [BlogUser], loggedInUser: BlogUser?, disqusName: String?, siteTwitterHandle: String?) throws -> View
    func blogPostView(uri: URI, post: BlogPost, author: BlogUser, user: BlogUser?, disqusName: String?, siteTwitterHandle: String?) throws -> View
    func tagView(uri: URI, tag: BlogTag, paginatedPosts: Paginator<BlogPost>, user: BlogUser?, disqusName: String?, siteTwitterHandle: String?) throws -> View
    func allAuthorsView(uri: URI, allAuthors: [BlogUser], user: BlogUser?, siteTwitterHandle: String?) throws -> View
    func allTagsView(uri: URI, allTags: [BlogTag], user: BlogUser?, siteTwitterHandle: String?) throws -> View
}
