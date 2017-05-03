import Foundation
import Vapor
import FluentProvider

public class BlogPost: Model {

    public let storage = Storage()

    public var title: String
    public var contents: String
    public var author: Identifier?
    public var created: Date
    public var lastEdited: Date?
    public var slugUrl: String
    public var published: Bool

    init(title: String, contents: String, author: BlogUser, creationDate: Date, slugUrl: String, published: Bool) {
        self.title = title
        self.contents = contents
        self.author = author.id
        self.created = creationDate
        self.slugUrl = BlogPost.generateUniqueSlugUrl(from: slugUrl)
        self.lastEdited = nil
        self.published = published
    }
    
    public required init(row: Row) throws {
        title = try row.get("title")
        contents = try row.get("contents")
        author = try row.get("blog_user_id")
        slugUrl = try row.get("slug_url")
        published = try row.get("published")
        let createdTime: Double = try row.get("created")
        let lastEditedTime: Double? = try? row.get("last_edited")
        
        created = Date(timeIntervalSince1970: createdTime)
        
        if let lastEditedTime = lastEditedTime {
            lastEdited = Date(timeIntervalSince1970: lastEditedTime)
        }
    }
    
    public func makeRow() throws -> Row {
        let createdTime = created.timeIntervalSince1970
        
        var row = Row()
        try row.set("title", title)
        try row.set("contents", contents)
        try row.set(BlogUser.foreignIdKey, author)
        try row.set("created", createdTime)
        try row.set("slug_url", slugUrl)
        try row.set("published", published)
        try row.set("last_edited", lastEdited)
        return row
    }
}

extension BlogPost: NodeRepresentable {
    public func makeNode(in context: Context?) throws -> Node {
        let createdTime = created.timeIntervalSince1970
        
        var node: [String: Node]  = [:]
        node["id"] = try id.makeNode(in: context)
        node["title"] = title.makeNode(in: context)
        node["contents"] = contents.makeNode(in: context)
        node["blog_user_id"] = author?.makeNode(in: context)
        node["created"] = createdTime.makeNode(in: context)
        node["slug_url"] = slugUrl.makeNode(in: context)
        node["published"] = published.makeNode(in: context)

        if let lastEdited = lastEdited {
            node["last_edited"] = lastEdited.timeIntervalSince1970.makeNode(in: context)
        }
        
        guard let providedContext = context else {
            return try node.makeNode(in: context)
        }
        
        if type(of: providedContext) != BlogPostContext.self {
            return try node.makeNode(in: context)
        }

        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.dateStyle = .full
        dateFormatter.timeStyle = .none
        let createdDate = dateFormatter.string(from: created)
        
        node["author_name"] = try postAuthor.get()?.name.makeNode(in: context)
        node["author_username"] = try postAuthor.get()?.username.makeNode(in: context)
        node["created_date"] = createdDate.makeNode(in: context)
        
        switch providedContext {
        case BlogPostContext.shortSnippet:
            node["short_snippet"] = shortSnippet().makeNode(in: context)
            break
        case BlogPostContext.longSnippet:
            node["long_snippet"] = longSnippet().makeNode(in: context)

            let allTags = try tags.all()
            if allTags.count > 0 {
                node["tags"] = try allTags.makeNode(in: context)
            }
            break
        case BlogPostContext.all:
            let allTags = try tags.all()

            if allTags.count > 0 {
                node["tags"] = try allTags.makeNode(in: context)
            }
            
            let iso8601Formatter = DateFormatter()
            iso8601Formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            iso8601Formatter.locale = Locale(identifier: "en_US_POSIX")
            iso8601Formatter.timeZone = TimeZone(secondsFromGMT: 0)
            
            node["created_date_iso8601"] = iso8601Formatter.string(from: created).makeNode(in: context)

            if let lastEdited = lastEdited {
                let lastEditedDate = dateFormatter.string(from: lastEdited)
                node["last_edited_date"] = lastEditedDate.makeNode(in: context)
                node["last_edited_date_iso8601"] = iso8601Formatter.string(from: lastEdited).makeNode(in: context)
            }
            node["short_snippet"] = shortSnippet().makeNode(in: context)
            node["long_snippet"] = longSnippet().makeNode(in: context)
        default: break
        }

        return try node.makeNode(in: context)
    }
}

extension BlogPost: Preparation {

    public static func prepare(_ database: Database) throws {
        try database.create(self) { posts in
            posts.id()
            posts.string("title")
            posts.custom("contents", type: "TEXT")
            posts.parent(BlogUser.self)
            posts.double("created")
            posts.double("last_edited", optional: true)
            posts.string("slug_url", unique: true)
        }
    }

    public static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

public enum BlogPostContext: Context {
    case all
    case shortSnippet
    case longSnippet
}

extension BlogPost {
    var postAuthor: Parent<BlogPost, BlogUser> {
        return parent(id: author)
    }
    
//    func getAuthor() throws -> BlogUser? {
//        return try parent(author, nil, BlogUser.self).get()
//    }
}

extension BlogPost {
    var tags: Siblings<BlogPost, BlogTag, Pivot<BlogPost, BlogTag>> {
        return siblings()
    }
    
//    func tags() throws -> [BlogTag] {
//        return try siblings().all()
//    }
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
    public static func generateUniqueSlugUrl(from title: String) -> String {
        let alphanumericsWithHyphenAndSpace = CharacterSet(charactersIn: " -0123456789abcdefghijklmnopqrstuvwxyz")

        let slugUrl = title.lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .components(separatedBy: alphanumericsWithHyphenAndSpace.inverted).joined()
            .components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }.joined(separator: " ")
            .replacingOccurrences(of: " ", with: "-", options: .regularExpression)

        var newSlugUrl = slugUrl
        var count = 2

        do {
            while try BlogPost.makeQuery().filter("slug_url", newSlugUrl).first() != nil {
              newSlugUrl = "\(slugUrl)-\(count)"
              count += 1
            }
        } catch {
            print("Error uniqueing the slug URL: \(error)")
            // Swallow error - this will propragate the error up to the DB driver which should fail if it is not unique
        }
        
        return newSlugUrl
    }
}

extension BlogPost: Paginatable {
    public static var defaultPageSorts: [Sort] {
        return []
    }
}
