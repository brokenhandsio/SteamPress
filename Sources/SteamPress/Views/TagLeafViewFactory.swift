import Vapor
import URI
import HTTP
import SwiftMarkdown
import SwiftSoup
import Foundation
import Fluent

struct TagLeafViewFactory: TagViewFactory {

    let viewFactory: ViewFactory

    func tagView(uri: URI, tag: BlogTag, paginatedPosts: Page<BlogPost>, user: BlogUser?) throws -> View {

        var parameters: [String: NodeRepresentable] = [:]
        parameters["tag"] = try tag.makeNode(in: BlogTagContext.withPostCount)
        parameters["tag_page"] = true

        if paginatedPosts.total > 0 {
            parameters["posts"] = try paginatedPosts.makeNode(for: uri, in: BlogPostContext.longSnippet)
        }

        return try viewFactory.createPublicView(template: "blog/tag", uri: uri, parameters: parameters, user: user)
    }

    func allTagsView(uri: URI, allTags: [BlogTag], user: BlogUser?) throws -> View {
        var parameters: [String: NodeRepresentable] = [:]

        if !allTags.isEmpty {
            let sortedTags = allTags.sorted { return (try? $0.sortedPosts().count() > $1.sortedPosts().count()) ?? false }
            parameters["tags"] = try sortedTags.makeNode(in: BlogTagContext.withPostCount)
        }

        return try viewFactory.createPublicView(template: "blog/tags", uri: uri, parameters: parameters, user: user)
    }
}
