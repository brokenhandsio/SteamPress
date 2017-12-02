import Vapor
import URI
import Fluent
import Foundation

protocol PostViewFactory {
    func blogPostView(uri: URI, post: BlogPost, author: BlogUser, user: BlogUser?) throws -> View
    func createBlogPostView(uri: URI, errors: [String]?, title: String?, contents: String?, slugUrl: String?, tags: [Node]?, isEditing: Bool, postToEdit: BlogPost?, draft: Bool, user: BlogUser) throws -> View
}
