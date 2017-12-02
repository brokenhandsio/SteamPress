import Vapor
import URI
import Fluent
import Foundation

protocol TagViewFactory {
    func tagView(uri: URI, tag: BlogTag, paginatedPosts: Page<BlogPost>, user: BlogUser?) throws -> View
    func allTagsView(uri: URI, allTags: [BlogTag], user: BlogUser?) throws -> View
}
