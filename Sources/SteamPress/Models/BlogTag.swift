//import Foundation
import Vapor

// MARK: - Model

public final class BlogTag: Codable {

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
//    public typealias ID = Int
//    public static var idKey: IDKey {
//        return \BlogTag.tagID
//    }
//    public typealias Database = DatabaseType

    public var tagID: Int?
    public var name: String

    public init(id: Int? = nil, name: String) {
        self.tagID = id
        self.name = name
    }
}

//extension BlogTag: Migration {}
extension BlogTag: Content {}

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

//    public var posts: Siblings<BlogTag, BlogPost<Database>, BlogPostTagPivot<DatabaseType>> {
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

//    static func addTag(_ name: String, to post: BlogPost<Database>, on conn: DatabaseConnectable) throws -> Future<Void> {
//        return try BlogTag.query(on: conn).filter(\.name == name).first().flatMap(to: Void.self) { foundTag in
//            if let exisitingTag = foundTag {
//                return exisitingTag.posts.attach(post, on: conn).transform(to: Future.void)
//            } else {
//                return BlogTag(name: name).save(on: conn).flatMap(to: Void.self) { tag in
//                    return tag.posts.attach(post, on: conn).transform(to: Future.void)
//                }
//            }
//        }
//    }
}


