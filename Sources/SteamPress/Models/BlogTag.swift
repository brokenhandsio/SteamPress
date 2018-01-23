//import Foundation
import Vapor
import Fluent

// MARK: - Model

public final class BlogTag<DatabaseType>: Model where DatabaseType: QuerySupporting & SchemaSupporting & JoinSupporting {

//    public struct Properties {
//        public static let tagID = "id"
//        public static let name = "name"
//        public static let urlEncodedName = "url_encoded_name"
//        public static let postCount = "post_count"
//    }
//
//    public let storage = Storage()
//
    // TODO change to UUID
    public typealias ID = Int
    public static var idKey: ReferenceWritableKeyPath<BlogTag<DatabaseType>, Int?> {
        return \BlogTag.tagID
    }
    public typealias Database = DatabaseType

    var tagID: Int?
    var name: String

    public init(name: String) {
        self.name = name
    }
}

extension BlogTag: Migration {}

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
// MARK: - Relations

public extension BlogTag {

    public var posts: Siblings<BlogTag, BlogPost<Database>, BlogPostTagPivot<DatabaseType>> {
        return siblings()
    }
//
//    public func sortedPosts() throws -> Query<BlogPost> {
//        return try posts.filter(BlogPost.Properties.published, true).sort(BlogPost.Properties.created, .descending)
//    }
//
//    func deletePivot(for post: BlogPost) throws {
//        try posts.remove(post)
//    }

    static func addTag(_ name: String, to post: BlogPost<Database>, on conn: DatabaseConnectable) throws -> Future<Void> {
        return BlogTag.query(on: conn).filter(\.name == name).first().flatMap(to: Void.self) { foundTag in
            var pivotTag: BlogTag
            if let exisitingTag = foundTag {
                pivotTag = exisitingTag
            } else {
                pivotTag = BlogTag(name: name)
            }
            return pivotTag.posts.attach(post, on: conn).map(to: Void.self) { _ in

            }
        }
    }
}

