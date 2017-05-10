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

    init(title: String, contents: String, author: BlogUser, creationDate: Date, slugUrl: String, published: Bool, logger: LogProtocol? = nil) {
        self.title = title
        self.contents = contents
        self.author = author.id
        self.created = creationDate
        self.slugUrl = BlogPost.generateUniqueSlugUrl(from: slugUrl, logger: logger)
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
        try row.set("last_edited", lastEdited?.timeIntervalSince1970)
        return row
    }
}

extension BlogPost: NodeRepresentable {
    public func makeNode(in context: Context?) throws -> Node {
        let createdTime = created.timeIntervalSince1970
        
        var node = Node([:], in: context)
        try node.set("id", id)
        try node.set("title", title)
        try node.set("contents", contents)
        try node.set("blog_user_id", author)
        try node.set("created", createdTime)
        try node.set("slug_url", slugUrl)
        try node.set("published", published)

        if let lastEdited = lastEdited {
            try node.set("last_edited", lastEdited.timeIntervalSince1970)
        }
        
        guard let providedContext = context else {
            return node
        }
        
        if type(of: providedContext) != BlogPostContext.self {
            return node
        }

        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.dateStyle = .full
        dateFormatter.timeStyle = .none
        let createdDate = dateFormatter.string(from: created)
        
        try node.set("author_name", postAuthor.get()?.name)
        try node.set("author_username", postAuthor.get()?.username)
        try node.set("created_date", createdDate)
        
        switch providedContext {
        case BlogPostContext.shortSnippet:
            try node.set("short_snippet", shortSnippet())
            break
        case BlogPostContext.longSnippet:
            try node.set("long_snippet", longSnippet())

            let allTags = try tags.all()
            if allTags.count > 0 {
                try node.set("tags", allTags)
            }
            break
        case BlogPostContext.all:
            let allTags = try tags.all()

            if allTags.count > 0 {
                try node.set("tags", allTags)
            }
            
            let iso8601Formatter = DateFormatter()
            iso8601Formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            iso8601Formatter.locale = Locale(identifier: "en_US_POSIX")
            iso8601Formatter.timeZone = TimeZone(secondsFromGMT: 0)
            
            try node.set("created_date_iso8601", iso8601Formatter.string(from: created))

            if let lastEdited = lastEdited {
                let lastEditedDate = dateFormatter.string(from: lastEdited)
                try node.set("last_edited_date", lastEditedDate)
                try node.set("last_edited_date_iso8601", iso8601Formatter.string(from: lastEdited))
            }
            try node.set("short_snippet", shortSnippet())
            try node.set("long_snippet", longSnippet())
        default: break
        }

        return node
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
}

extension BlogPost {
    var tags: Siblings<BlogPost, BlogTag, Pivot<BlogPost, BlogTag>> {
        return siblings()
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
    public static func generateUniqueSlugUrl(from title: String, logger: LogProtocol?) -> String {
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
            logger?.debug("Error uniqueing the slug URL: \(error)")
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

extension Page {
    public func makeNode(for uri: URI, in context: Context?) throws -> Node {
        var node = Node([:], in: context)
        try node.set("data", data.makeNode(in: context))
        
        var paginationNode = Node([:], in: context)
        try paginationNode.set("total", total)
        try paginationNode.set("current_page", number)
        try paginationNode.set("per_page", size)

        var pages = total / size
        if total % size != 0 {
            pages += 1
        }
        
        try paginationNode.set("total_pages", pages)
        if number < pages {
            try paginationNode.set("next_page", "?page=\(number + 1)")
        }
        if number > 1 {
            try paginationNode.set("previous_page", "?page=\(number - 1)")
        }
        
        
        
        try node.set("pagination", paginationNode)
        return node
    }
}
