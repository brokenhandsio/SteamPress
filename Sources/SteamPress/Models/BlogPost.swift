import Foundation
import Vapor
import Fluent

public class BlogPost: Model {
    
    static fileprivate let databaseTableName = "blogposts"
    public var id: Node?
    public var exists: Bool = false
    
    public var title: String
    public var contents: String
    public var author: Node?
    public var created: Date
    public var lastEdited: Date?
    public var slugUrl: String?
    
    init(title: String, contents: String, author: BlogUser, creationDate: Date, slugUrl: String) {
        self.id = nil
        self.title = title
        self.contents = contents
        self.author = author.id
        self.created = creationDate
        self.slugUrl = BlogPost.generateSlugUrl(from: slugUrl)
        self.lastEdited = nil
    }
    
    required public init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        title = try node.extract("title")
        contents = try node.extract("contents")
        author = try node.extract("bloguser_id")
        slugUrl = try node.extract("slug_url")
        let createdTime: Double = try node.extract("created")
        let lastEditedTime: Double? = try? node.extract("last_edited")
        
        created = Date(timeIntervalSince1970: createdTime)
        
        if let lastEditedTime = lastEditedTime {
            lastEdited = Date(timeIntervalSince1970: lastEditedTime)
        }
    }
}

extension BlogPost: NodeRepresentable {
    public func makeNode(context: Context) throws -> Node {
        let createdTime = created.timeIntervalSince1970
        
        var node = try Node(node: [
            "id": id,
            "title": title,
            "contents": contents,
            "bloguser_id": author,
            "created": createdTime,
            "slug_url": slugUrl
            ])
        
        if let lastEdited = lastEdited {
            node["last_edited"] = lastEdited.timeIntervalSince1970.makeNode()
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.dateStyle = .full
        dateFormatter.timeStyle = .none
        let createdDate = dateFormatter.string(from: created)
        
        switch context {
        case BlogPostContext.shortSnippet:
            node = try Node(node: [
                "id": id,
                "title": title,
                "author_name": try getAuthor()?.name.makeNode(),
                "author_username": try getAuthor()?.username.makeNode(),
                "short_snippet": shortSnippet().makeNode(),
                "created_date": createdDate.makeNode(),
                "slug_url": slugUrl
                ])
        case BlogPostContext.longSnippet:
            node = try Node(node: [
                "id": id,
                "title": title,
                "author_name": try getAuthor()?.name.makeNode(),
                "author_username": try getAuthor()?.username.makeNode(),
                "long_snippet": longSnippet().makeNode(),
                "created_date": createdDate.makeNode(),
                "slug_url": slugUrl
                ])
            
            let allTags = try tags()
            
            if allTags.count > 0 {
                node["tags"] = try allTags.makeNode()
            }
            
        case BlogPostContext.all:
            let allTags = try tags()
            
            if allTags.count > 0 {
                node["tags"] = try allTags.makeNode()
            }
            
            node["long_snippet"] = longSnippet().makeNode()
            node["created_date"] = createdDate.makeNode()
            
            if let lastEdited = lastEdited {
                let lastEditedDate = dateFormatter.string(from: lastEdited)
                node["last_edited_date"] = lastEditedDate.makeNode()
            }
            
            node["author_name"] = try getAuthor()?.name.makeNode()
            node["author_username"] = try getAuthor()?.username.makeNode()
            node["short_snippet"] = shortSnippet().makeNode()
            node["long_snippet"] = longSnippet().makeNode()
        default: break
        }
        
        return node
    }
}

extension BlogPost {
    
    public static func prepare(_ database: Database) throws {
        try database.create(databaseTableName) { posts in
            posts.id()
            posts.string("title")
            posts.custom("contents", type: "TEXT")
            posts.parent(BlogUser.self, optional: false)
            posts.double("created")
            posts.double("last_edited", optional: true)
            posts.string("slug_url", unique: true)
        }
    }
    
    public static func revert(_ database: Database) throws {
        try database.delete(databaseTableName)
    }
}

public enum BlogPostContext: Context {
    case all
    case shortSnippet
    case longSnippet
}

extension BlogPost {
    func getAuthor() throws -> BlogUser? {
        return try parent(author, nil, BlogUser.self).get()
    }
}

extension BlogPost {
    func tags() throws -> [BlogTag] {
        return try siblings().all()
    }
}

extension BlogPost {
    
    public func shortSnippet() -> String {
        return getLines(characterLimit: 150)
    }
    
    public func longSnippet() -> String {
        return getLines(characterLimit: 900)
    }
    
    private func getLines(characterLimit: Int) -> String {
        contents = contents.replacingOccurrences(of: "\r\n", with: "\n", options: .regularExpression)
        let lines = contents.components(separatedBy: "\n")
        var snippet = ""
        for line in lines {
            snippet += "\(line)\n"
            if snippet.count > characterLimit {
                return snippet
            }
        }
        return snippet
    }
    
}

extension BlogPost {
    public static func generateSlugUrl(from title: String) -> String {
        let alphanumericsWithHyphenAndSpace = NSCharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890- ")
        
        return title.lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .components(separatedBy: alphanumericsWithHyphenAndSpace.inverted).joined()
            .components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }.joined(separator: " ")
            .replacingOccurrences(of: " ", with: "-", options: .regularExpression)
    }
}
