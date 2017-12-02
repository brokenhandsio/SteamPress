import Vapor
import URI
import Fluent
import Foundation

protocol LinkViewFactory {
    func createLinkView(isEditing: Bool, linkToEdit: BlogLink?) throws -> View
    func allLinksView(uri: URI, allLinks: [BlogLink]) throws -> View
}
