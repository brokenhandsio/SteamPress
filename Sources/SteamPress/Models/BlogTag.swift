//import Foundation
//import Vapor
//import Fluent
//
//// MARK: - Model
//
//public final class BlogTag: Model {
//
//    public struct Properties {
//        public static let tagID = "id"
//        public static let name = "name"
//        public static let urlEncodedName = "url_encoded_name"
//        public static let postCount = "post_count"
//    }
//
//    public let storage = Storage()
//
//    var name: String
//
//    public init(name: String) {
//        self.name = name    }
//
//    required public init(row: Row) throws {
//        name = try row.get(Properties.name)
//    }
//
//    public func makeRow() throws -> Row {
//        var row = Row()
//        try row.set(Properties.name, name)
//        return row
//    }
//}
//
//extension BlogTag: Parameterizable {}
//
//// MARK: - Node
//
//public enum BlogTagContext: Context {
//    case withPostCount
//}
//
//extension BlogTag: NodeRepresentable {
//    public func makeNode(in context: Context?) throws -> Node {
//
//        var node = Node([:], in: context)
//        try node.set(Properties.tagID, id)
//        try node.set(Properties.name, name)
//
//        guard let urlEncodedName = name.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else {
//            return node
//        }
//
//        try node.set(Properties.urlEncodedName, urlEncodedName)
//
//        guard let providedContext = context else {
//            return node
//        }
//
//        switch providedContext {
//        case BlogTagContext.withPostCount:
//            try node.set(Properties.postCount, sortedPosts().count())
//        default: break
//        }
//
//        return node
//    }
//}
//
//// MARK: - Relations
//
//public extension BlogTag {
//
//    public var posts: Siblings<BlogTag, BlogPost, Pivot<BlogTag, BlogPost>> {
//        return siblings()
//    }
//
//    public func sortedPosts() throws -> Query<BlogPost> {
//        return try posts.filter(BlogPost.Properties.published, true).sort(BlogPost.Properties.created, .descending)
//    }
//
//    func deletePivot(for post: BlogPost) throws {
//        try posts.remove(post)
//    }
//
//    static func addTag(_ name: String, to post: BlogPost) throws {
//        var pivotTag: BlogTag
//        let foundTag = try BlogTag.makeQuery().filter(Properties.name, name).first()
//
//        if let existingTag = foundTag {
//            pivotTag = existingTag
//        } else {
//            pivotTag = BlogTag(name: name)
//            try pivotTag.save()
//        }
//        try pivotTag.posts.add(post)
//    }
//}

