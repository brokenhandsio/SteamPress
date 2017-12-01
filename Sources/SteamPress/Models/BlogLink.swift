import Foundation
import Vapor
import FluentProvider

// MARK: - Model

public final class BlogLink: Model {
    public struct Properties {
        public static let linkID = "id"
        public static let name = "name"
        public static let href = "href"
    }

    public let storage = Storage()

    var name: String
    var href: String

    public init(name: String, href: String) {
        self.name = name
        self.href = href
    }

    required public init(row: Row) throws {
        name = try row.get(Properties.name)
        href = try row.get(Properties.href)
    }

    public func makeRow() throws -> Row {
        var row = Row()
        try row.set(Properties.name, name)
        try row.set(Properties.href, href)
        return row
    }
}

extension BlogLink: Parameterizable {}

extension BlogLink: NodeRepresentable {
    public func makeNode(in context: Context?) throws -> Node {

        var node = Node([:], in: context)
        try node.set(Properties.linkID, id)
        try node.set(Properties.name, name)
        try node.set(Properties.href, href)

        return node
    }
}
