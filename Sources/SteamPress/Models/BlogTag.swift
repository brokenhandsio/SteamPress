
import Foundation
import Vapor
import FluentProvider

final class BlogTag: Model {
    
    let storage = Storage()
    
    var name: String
    
    init(name: String) {
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
        
        var node = Node([:], in: context)
        try node.set("id", id)
        try node.set("name", name)
        
        guard let urlEncodedName = name.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else {
            return node
        }
        
        try node.set("url_encoded_name", urlEncodedName)
        
        guard let providedContext = context else {
            return node
        }
        
        switch providedContext {
        case BlogTagContext.withPostCount:
            try node.set("post_count", sortedPosts().count())
        default: break
        }
        
        return node
    }
}

public enum BlogTagContext: Context {
    case withPostCount
}

extension BlogTag: Parameterizable {
    static var uniqueSlug: String = "blogtag"
    
    static func make(for parameter: String) throws -> BlogTag {
        guard let blogTag = try BlogTag.makeQuery().filter("id", parameter).first() else {
            throw Abort.notFound
        }
        return blogTag
    }
}

extension BlogTag {
    
    var posts: Siblings<BlogTag, BlogPost, Pivot<BlogTag, BlogPost>> {
        return siblings()
    }
    
    func sortedPosts() throws -> Query<BlogPost> {
        return try posts.filter("published", true).sort("created", .descending)
    }
    
    func deletePivot(for post: BlogPost) throws {
        try posts.remove(post)
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
