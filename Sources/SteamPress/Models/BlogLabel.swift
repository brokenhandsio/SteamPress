import Foundation
import Vapor
import Fluent

class BlogLabel: Model {
    
    static fileprivate let databaseTableName = "bloglabels"
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

extension BlogLabel: NodeRepresentable {
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "name": name
            ])
    }
}

extension BlogLabel {
    
    static func prepare(_ database: Database) throws {
        try database.create(databaseTableName) { posts in
            posts.id()
            posts.string("name")
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(databaseTableName)
    }
}

extension BlogLabel {
    func blogPosts() throws -> [BlogPost] {
        return try siblings().all()
    }
    
    func deletePivot(for post: BlogPost) throws {
        guard let labelId = id, let postId = post.id else {
            throw Abort.badRequest
        }
        let pivot = try Pivot<BlogPost, BlogLabel>.query().filter("bloglabel_id", labelId).filter("blogpost_id", postId).first()
        try pivot?.delete()
    }
    
    static func addLabel(name: String, to post: BlogPost) throws {
        var pivotLabel: BlogLabel
        let label = try BlogLabel.query().filter("name", name).first()
        
        if let existingLabel = label {
            pivotLabel = existingLabel
        }
        else {
            var newLabel = BlogLabel(name: name)
            try newLabel.save()
            pivotLabel = newLabel
        }
        
        // Check if a new label
        var pivot = Pivot<BlogPost, BlogLabel>(post, pivotLabel)
        try pivot.save()
    }
}
