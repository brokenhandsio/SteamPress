import Vapor
//import URI
import Foundation

protocol ViewFactory {

//    // MARK: - Admin Controller
//    func createBlogPostView(uri: URI, errors: [String]?, title: String?, contents: String?, slugUrl: String?,
//                            tags: [Node]?, isEditing: Bool, postToEdit: BlogPost?, draft: Bool, user: BlogUser) throws -> View
//    func createUserView(editing: Bool, errors: [String]?, name: String?, username: String?, passwordError: Bool?,
//                        confirmPasswordError: Bool?, resetPasswordRequired: Bool?, userId: Identifier?,
//                        profilePicture: String?, twitterHandle: String?, biography: String?,
//                        tagline: String?, loggedInUser: BlogUser) throws -> View
//    func createLoginView(loginWarning: Bool, errors: [String]?, username: String?, password: String?) throws -> View
//    func createBlogAdminView(errors: [String]?, user: BlogUser) throws -> View
//    func createResetPasswordView(errors: [String]?, passwordError: Bool?, confirmPasswordError: Bool?, user: BlogUser) throws -> View
//
//    // MARK: - Blog Controller
//    func blogIndexView(uri: URI, paginatedPosts: Page<BlogPost>, tags: [BlogTag],
//                       authors: [BlogUser], loggedInUser: BlogUser?) throws -> View
//    func blogPostView(uri: URI, post: BlogPost, author: BlogUser, user: BlogUser?) throws -> View
//    func tagView(uri: URI, tag: BlogTag, paginatedPosts: Page<BlogPost>, user: BlogUser?) throws -> View
//    func allAuthorsView(uri: URI, allAuthors: [BlogUser], user: BlogUser?) throws -> View
//    func allTagsView(uri: URI, allTags: [BlogTag], user: BlogUser?) throws -> View
//    func profileView(uri: URI, author: BlogUser, paginatedPosts: Page<BlogPost>, loggedInUser: BlogUser?) throws -> View
//    func searchView(uri: URI, searchTerm: String?, foundPosts: Page<BlogPost>?, emptySearch: Bool, user: BlogUser?) throws -> View
}
