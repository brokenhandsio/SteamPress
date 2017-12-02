import Vapor
import URI
import Fluent
import Foundation

protocol AuthorViewFactory {
    func profileView(uri: URI, author: BlogUser, paginatedPosts: Page<BlogPost>, loggedInUser: BlogUser?) throws -> View
    func allAuthorsView(uri: URI, allAuthors: [BlogUser], user: BlogUser?) throws -> View
    func createUserView(editing: Bool, errors: [String]?, name: String?, username: String?, passwordError: Bool?,
                        confirmPasswordError: Bool?, resetPasswordRequired: Bool?, userId: Identifier?,
                        profilePicture: String?, twitterHandle: String?, biography: String?,
                        tagline: String?, loggedInUser: BlogUser) throws -> View
}
