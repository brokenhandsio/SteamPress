import Fluent
import Vapor

final class BlogPostTagPivot<DatabaseType>: ModifiablePivot where DatabaseType: QuerySupporting & SchemaSupporting & JoinSupporting {

    typealias Database = DatabaseType

    // TODO change to UUID
    var pivotID: Int?
    var postID: Int
    var tagID: Int

    typealias ID = Int
    static var idKey: IDKey {
        return \.pivotID
    }

    typealias Left = BlogPost<Database>
    typealias Right = BlogTag<Database>
    static var leftIDKey: LeftIDKey {
        return \.postID
    }
    static var rightIDKey: RightIDKey {
        return \.tagID
    }

    init(_ post: BlogPost<Database>, _ tag: BlogTag<Database>) throws {
        self.postID = try post.requireID()
        self.tagID = try tag.requireID()
    }

}

extension BlogPostTagPivot: Migration {}

