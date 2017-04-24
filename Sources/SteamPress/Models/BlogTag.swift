import Foundation
import Vapor
import FluentProvider

class BlogTag: Model {
    
    let storage = Storage()
    
    var name: String
    
    init(name: String) {
        self.id = nil
        self.name = name    }
    
    required init(row: Row) throws {
        name = try row.get("name")
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set("name", name)
        return row
    }
}

extension BlogTag: NodeRepresentable {
    func makeNode(in context: Context?) throws -> Node {
        
        var node: [String: Node] = [:]
        node["id"] = try id.makeNode(in: context)
        node["name"] = name.makeNode(in: context)
        
        guard let providedContext = context else {
            return try node.makeNode(in: context)
        }
        
        switch providedContext {
        case BlogTagContext.withPostCount:
            node["post_count"] = try sortedPosts().count.makeNode(in: context)
            fallthrough
        default:
            guard let urlEncodedName = name.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else {
                return try node.makeNode(in: context)
            }
            
            node["url_encoded_name"] = urlEncodedName.makeNode(in: context)
        }
        
        return try node.makeNode(in: context)
    }
}

public enum BlogTagContext: Context {
    case withPostCount
}

extension BlogTag: Preparation {
    
    static func prepare(_ database: Database) throws {
        try database.create(self) { tag in
            tag.id()
            tag.string("name", unique: true)
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

extension BlogTag {
    
    var posts: Siblings<BlogPost, BlogTag, Pivot<BlogPost, BlogTag>> {
        return siblings()
    }
    
    func sortedPosts() throws -> [BlogPost] {
        return try posts.filter("published", true).sort("created", .descending).all()
    }
    
    func deletePivot(for post: BlogPost) throws {
        try posts.remove(self)
    }
    
    static func addTag(_ name: String, to post: BlogPost) throws {
        var pivotTag: BlogTag
        let tag = try BlogTag.makeQuery().filter("name", name).first()
        
        if let existingTag = tag {
            pivotTag = existingTag
        }
        else {
            let newTag = BlogTag(name: name)
            try newTag.save()
            pivotTag = newTag
        }
        
        // Check if a new tag
        let pivot = try pivotTag.posts.add(post)
        try pivot.save()
    }
}
