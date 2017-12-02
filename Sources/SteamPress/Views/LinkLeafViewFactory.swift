import Vapor
import URI
import HTTP
import SwiftMarkdown
import SwiftSoup
import Foundation
import Fluent

struct LinkLeafViewFactory: LinkViewFactory {

    let viewFactory: ViewFactory

    func allLinksView(uri: URI, allLinks: [BlogLink]) throws -> View {
        var parameters: [String: NodeRepresentable] = [:]

        if !allLinks.isEmpty {
            parameters["links"] = try allLinks.makeNode(in: nil)
        }

        return try viewFactory.createPublicView(template: "blog/links", uri: uri, parameters: parameters)
    }

    func createLinkView(isEditing: Bool = false, linkToEdit: BlogLink?) throws -> View {
        var parameters: [String: Vapor.Node] = [:]

        if isEditing {
            guard let link = linkToEdit else {
                throw Abort.badRequest
            }
            parameters["link"] = try link.makeNode(in: nil)
            parameters["editing"] = true
        }

        return try viewFactory.viewRenderer.make("blog/admin/createLink", parameters)
    }
}
