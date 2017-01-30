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
        author = try node.extract("bloguser_id")
        let createdTime: Double = try node.extract("created")
        let lastEditedTime: Double? = try? node.extract("lastedited")
        
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
            "created": createdTime
            ])
        
        if let lastEdited = lastEdited {
            node["lastedited"] = lastEdited.timeIntervalSince1970.makeNode()
        }
        
        if type(of: context) == BlogPostAllInfo.self || type(of: context) == BlogPostShortSnippet.self {
        
            let dateFormatter = DateFormatter()
            dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
            dateFormatter.dateStyle = .full
            dateFormatter.timeStyle = .none
            let createdDate = dateFormatter.string(from: created)
            
            node["createddate"] = createdDate.makeNode()
            
            if let lastEdited = lastEdited {
                let lastEditedDate = dateFormatter.string(from: lastEdited)
                node["lastediteddate"] = lastEditedDate.makeNode()
                
            }
            
            node["authorname"] = try getAuthor()?.name.makeNode()
            node["shortsnippet"] = shortSnippet().makeNode()
            
            if type(of: context) != BlogPostShortSnippet.self {
                let allLabels = try labels()
                
                if allLabels.count > 0 {
                    node["labels"] = try allLabels.makeNode()
                }
                
                node["longsnippet"] = longSnippet().makeNode()
            }
        
        }
        
        return node
    }
}

extension BlogPost {
    
    public static func prepare(_ database: Database) throws {
        try database.create(databaseTableName) { posts in
            posts.id()
            posts.string("title")
            posts.string("contents", length: 10000000, optional: false)
            posts.parent(BlogUser.self, optional: false)
            posts.double("created")
            posts.double("lastedited", optional: true)
        }
    }
    
    public static func revert(_ database: Database) throws {
        try database.delete(databaseTableName)
    }
}

public struct BlogPostShortSnippet: Context {
    public init(){}
}
public struct BlogPostAllInfo: Context {
    public init(){}
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
