import Vapor

// MARK: - Model

public final class BlogTag: Codable {

    public var tagID: Int?
    public var name: String

    public init(id: Int? = nil, name: String) throws {
        self.tagID = id
        self.name = try BlogTag.percentEncodedTagName(from: name)
    }
}

extension BlogTag: Content {}

//
//extension BlogTag: Parameterizable {}
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

extension BlogTag {
    static func percentEncodedTagName(from name: String) throws -> String {
        guard let percentEncodedName = name.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {
            throw SteamPressError(identifier: "BlogTag", "Unable to create tag from name \(name)")
        }
        return percentEncodedName
    }
}

