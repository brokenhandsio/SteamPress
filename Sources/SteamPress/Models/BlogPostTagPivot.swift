import Fluent
import Vapor

public final class BlogPostTagPivot<DatabaseType>: ModifiablePivot where DatabaseType: QuerySupporting & SchemaSupporting & JoinSupporting {

    public typealias Database = DatabaseType

    // TODO change to UUID
    var pivotID: Int?
    var postID: Int
    var tagID: Int

    public typealias ID = Int
    public static var idKey: IDKey {
        return \.pivotID
    }

    public typealias Left = BlogPost<Database>
    public typealias Right = BlogTag<Database>
    public static var leftIDKey: LeftIDKey {
        return \.postID
    }
    public static var rightIDKey: RightIDKey {
        return \.tagID
    }

    public init(_ post: BlogPost<Database>, _ tag: BlogTag<Database>) throws {
        self.postID = try post.requireID()
        self.tagID = try tag.requireID()
    }

}

extension BlogPostTagPivot: Migration {}

