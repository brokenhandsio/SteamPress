import Vapor
import URI
import Fluent
import Foundation

protocol BlogViewFactory {
    func searchView(uri: URI, searchTerm: String?, foundPosts: Page<BlogPost>?, emptySearch: Bool, user: BlogUser?) throws -> View
    func blogIndexView(uri: URI, paginatedPosts: Page<BlogPost>, tags: [BlogTag], links: [BlogLink], authors: [BlogUser], loggedInUser: BlogUser?) throws -> View
    func createLoginView(loginWarning: Bool, errors: [String]?, username: String?, password: String?) throws -> View
    func createBlogAdminView(errors: [String]?, user: BlogUser) throws -> View
    func createResetPasswordView(errors: [String]?, passwordError: Bool?, confirmPasswordError: Bool?, user: BlogUser) throws -> View
}
