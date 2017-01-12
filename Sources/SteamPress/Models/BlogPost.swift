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
    
    init(title: String, contents: String, author: BlogUser, creationDate: Date) {
        self.id = nil
        self.title = title
        self.contents = contents
        self.author = author.id
        self.created = creationDate
        self.lastEdited = nil
    }
    
    required public init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        title = try node.extract("title")
        contents = try node.extract("contents")
        author = try node.extract("author")
        let createdTime: Double = try node.extract("created")
        let lastEditedTime: Double? = try? node.extract("lastEdited")
        
        created = Date(timeIntervalSince1970: createdTime)
        
        
        if let lastEditedTime = lastEditedTime {
            lastEdited = Date(timeIntervalSince1970: lastEditedTime)
        }
    }
}

extension BlogPost: NodeRepresentable {
    public func makeNode(context: Context) throws -> Node {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let createdDateTimestamp = dateFormatter.string(from: created)
        let createdTime = created.timeIntervalSince1970
        
        var node = try Node(node: [
            "id": id,
            "title": title,
            "contents": contents,
            "author": author,
            "created": createdTime,
            "createdTimestamp": createdDateTimestamp
            ])
        
        if let lastEdited = lastEdited {
            let lastEditedTimestamp = dateFormatter.string(from: lastEdited)
            node["lastEdited"] = lastEdited.timeIntervalSince1970.makeNode()
            node["lastEditedTimestamp"] = lastEditedTimestamp.makeNode()
        }
        
        return node
    }
}

extension BlogPost {
    
    public static func prepare(_ database: Database) throws {
        try database.create(databaseTableName) { posts in
            posts.id()
            posts.string("title")
            posts.string("contents")
            posts.parent(BlogUser.self, optional: false)
            posts.double("created")
            posts.double("lastEdited", optional: true)
        }
    }
    
    public static func revert(_ database: Database) throws {
        try database.delete(databaseTableName)
    }
}

extension BlogPost {
    public func makeNodeWithExtras() throws -> Node {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.dateStyle = .full
        dateFormatter.timeStyle = .none
        let createdDate = dateFormatter.string(from: created)
        
        var node = try makeNode()
        node["createdDate"] = createdDate.makeNode()
        
        if let lastEdited = lastEdited {
            let lastEditedDate = dateFormatter.string(from: lastEdited)
            node["lastEditedDate"] = lastEditedDate.makeNode()
            
        }
        
        node["authorName"] = try getAuthor()?.name.makeNode()
        
        let allLabels = try labels()
        
        if allLabels.count > 0 {
            node["labels"] = try allLabels.makeNode()
        }
        
        node["longSnippet"] = longSnippet().makeNode()
        node["shortSnippet"] = shortSnippet().makeNode()
        
        return node
    }

}

extension BlogPost {
    func getAuthor() throws -> BlogUser? {
        return try parent(author, nil, BlogUser.self).get()
    }
}

extension BlogPost {
    func labels() throws -> [BlogLabel] {
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
