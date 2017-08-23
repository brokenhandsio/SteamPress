import Vapor
import URI
import Fluent
import Foundation

protocol ViewFactory {

    // MARK: - Admin Controller
    func createBlogPostView(uri: URI, errors: [String]?, title: String?, contents: String?, slugUrl: String?, tags: [Node]?, isEditing: Bool, postToEdit: BlogPost?, draft: Bool) throws -> View
    func createUserView(editing: Bool, errors: [String]?, name: String?, username: String?, passwordError: Bool?, confirmPasswordError: Bool?, resetPasswordRequired: Bool?, userId: Identifier?, profilePicture: String?, twitterHandle: String?, biography: String?, tagline: String?) throws -> View
    func createLoginView(loginWarning: Bool, errors: [String]?, username: String?, password: String?) throws -> View
    func createBlogAdminView(errors: [String]?) throws -> View
    func createResetPasswordView(errors: [String]?, passwordError: Bool?, confirmPasswordError: Bool?) throws -> View
    func createProfileView(uri: URI, author: BlogUser, isMyProfile: Bool, paginatedPosts: Page<BlogPost>, loggedInUser: BlogUser?) throws -> View

    // MARK: - Blog Controller
    func blogIndexView(uri: URI, paginatedPosts: Page<BlogPost>, tags: [BlogTag], authors: [BlogUser], loggedInUser: BlogUser?) throws -> View
    func blogPostView(uri: URI, post: BlogPost, author: BlogUser, user: BlogUser?) throws -> View
    func tagView(uri: URI, tag: BlogTag, paginatedPosts: Page<BlogPost>, user: BlogUser?) throws -> View
    func allAuthorsView(uri: URI, allAuthors: [BlogUser], user: BlogUser?) throws -> View
    func allTagsView(uri: URI, allTags: [BlogTag], user: BlogUser?) throws -> View
}
