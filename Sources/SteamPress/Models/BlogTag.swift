import Foundation
import Vapor
import Fluent

class BlogTag: Model {
    
    static fileprivate let databaseTableName = "blogtags"
    var id: Node?
    var exists: Bool = false
    
    var name: String
    
    init(name: String) {
        self.id = nil
        self.name = name    }
    
    required init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        name = try node.extract("name")
    }
}

extension BlogTag: NodeRepresentable {
    func makeNode(context: Context) throws -> Node {
        
        var node = try Node(node: [
            "id": id,
            "name": name
            ])
        
        if context is DatabaseContext {
            return node
        }
        
        guard let urlEncodedName = name.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else {
            return node
        }
        
        node["url_encoded_name"] = urlEncodedName.makeNode()
        
        return node
    }
}

extension BlogTag {
    
    static func prepare(_ database: Database) throws {
        try database.create(databaseTableName) { posts in
            posts.id()
            posts.string("name", unique: true)
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(databaseTableName)
    }
}

extension BlogTag {
    func blogPosts() throws -> [BlogPost] {
        return try siblings().all()
    }
    
    func deletePivot(for post: BlogPost) throws {
        guard let tagId = id, let postId = post.id else {
            throw Abort.badRequest
        }
        let pivot = try Pivot<BlogPost, BlogTag>.query().filter("blogtag_id", tagId).filter("blogpost_id", postId).first()
        try pivot?.delete()
    }
    
    static func addTag(_ name: String, to post: BlogPost) throws {
        var pivotTag: BlogTag
        let tag = try BlogTag.query().filter("name", name).first()
        
        if let existingTag = tag {
            pivotTag = existingTag
        }
        else {
            var newTag = BlogTag(name: name)
            try newTag.save()
            pivotTag = newTag
        }
        
        // Check if a new tag
        var pivot = Pivot<BlogPost, BlogTag>(post, pivotTag)
        try pivot.save()
    }
}
