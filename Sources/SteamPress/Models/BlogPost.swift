import Foundation
import Vapor
import FluentProvider

// MARK: - Model

public final class BlogPost: Model {
    
    enum Properties: String {
        case id = "id"
        case title = "title"
        case contents = "contents"
        case slugUrl = "slug_url"
        case published = "published"
        case created = "created"
        case lastEdited = "last_edited"
        case authorName = "author_name"
        case authorUsername = "author_username"
        case createdDate = "created_date"
        case createdDateIso8601 = "created_date_iso8601"
        case lastEditedDate = "last_edited_date"
        case lastEditedDateIso8601 = "last_edited_date_iso8601"
        case shortSnippet = "short_snippet"
        case longSnippet = "long_snippet"
        case tags = "tags"
    }
    
    static var postsPerPage = 10

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
        title = try row.get(Properties.title.rawValue)
        contents = try row.get(Properties.contents.rawValue)
        author = try row.get(BlogUser.foreignIdKey)
        slugUrl = try row.get(Properties.slugUrl.rawValue)
        published = try row.get(Properties.published.rawValue)
        let createdTime: Double = try row.get(Properties.created.rawValue)
        let lastEditedTime: Double? = try? row.get(Properties.lastEdited.rawValue)
        
        created = Date(timeIntervalSince1970: createdTime)
        
        if let lastEditedTime = lastEditedTime {
            lastEdited = Date(timeIntervalSince1970: lastEditedTime)
        }
    }
    
    public func makeRow() throws -> Row {
        let createdTime = created.timeIntervalSince1970
        
        var row = Row()
        try row.set(Properties.title.rawValue, title)
        try row.set(Properties.contents.rawValue, contents)
        try row.set(BlogUser.foreignIdKey, author)
        try row.set(Properties.created.rawValue, createdTime)
        try row.set(Properties.slugUrl.rawValue, slugUrl)
        try row.set(Properties.published.rawValue, published)
        try row.set(Properties.lastEdited.rawValue, lastEdited?.timeIntervalSince1970)
        return row
    }
}

extension BlogPost: Parameterizable {
    public static var uniqueSlug: String = "blogpost"
    
    public static func make(for parameter: String) throws -> BlogPost {
        guard let post = try BlogPost.makeQuery().filter(BlogPost.idKey, parameter).first() else {
            throw Abort.notFound
        }
        return post
    }
}

// MARK: - Node

public enum BlogPostContext: Context {
    case all
    case shortSnippet
    case longSnippet
}

extension BlogPost: NodeRepresentable {
    public func makeNode(in context: Context?) throws -> Node {
        let createdTime = created.timeIntervalSince1970
        
        var node = Node([:], in: context)
        try node.set(Properties.id.rawValue, id)
        try node.set(Properties.title.rawValue, title)
        try node.set(Properties.contents.rawValue, contents)
        try node.set(BlogUser.foreignIdKey, author)
        try node.set(Properties.created.rawValue, createdTime)
        try node.set(Properties.slugUrl.rawValue, slugUrl)
        try node.set(Properties.published.rawValue, published)

        if let lastEdited = lastEdited {
            try node.set(Properties.lastEdited.rawValue, lastEdited.timeIntervalSince1970)
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
        
        try node.set(Properties.authorName.rawValue, postAuthor.get()?.name)
        try node.set(Properties.authorUsername.rawValue, postAuthor.get()?.username)
        try node.set(Properties.createdDate.rawValue, createdDate)
        
        switch providedContext {
        case BlogPostContext.shortSnippet:
            try node.set(Properties.shortSnippet.rawValue, shortSnippet())
            break
        case BlogPostContext.longSnippet:
            try node.set(Properties.longSnippet.rawValue, longSnippet())

            let allTags = try tags.all()
            if allTags.count > 0 {
                try node.set(Properties.tags.rawValue, allTags)
            }
            break
        case BlogPostContext.all:
            let allTags = try tags.all()

            if allTags.count > 0 {
                try node.set(Properties.tags.rawValue, allTags)
            }
            
            let iso8601Formatter = DateFormatter()
            iso8601Formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            iso8601Formatter.locale = Locale(identifier: "en_US_POSIX")
            iso8601Formatter.timeZone = TimeZone(secondsFromGMT: 0)
            
            try node.set(Properties.createdDateIso8601.rawValue, iso8601Formatter.string(from: created))

            if let lastEdited = lastEdited {
                let lastEditedDate = dateFormatter.string(from: lastEdited)
                try node.set(Properties.lastEditedDate.rawValue, lastEditedDate)
                try node.set(Properties.lastEditedDateIso8601.rawValue, iso8601Formatter.string(from: lastEdited))
            }
            try node.set(Properties.shortSnippet.rawValue, shortSnippet())
            try node.set(Properties.longSnippet.rawValue, longSnippet())
        default: break
        }

        return node
    }
}

// MARK: - BlogPost Utilities

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

    static func generateUniqueSlugUrl(from title: String, logger: LogProtocol?) -> String {
        let alphanumericsWithHyphenAndSpace = CharacterSet(charactersIn: " -0123456789abcdefghijklmnopqrstuvwxyz")

        let slugUrl = title.lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .components(separatedBy: alphanumericsWithHyphenAndSpace.inverted).joined()
            .components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }.joined(separator: " ")
            .replacingOccurrences(of: " ", with: "-", options: .regularExpression)

        var newSlugUrl = slugUrl
        var count = 2

        do {
            while try BlogPost.makeQuery().filter(Properties.slugUrl.rawValue, newSlugUrl).first() != nil {
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

// MARK: - Relations

extension BlogPost {
    var postAuthor: Parent<BlogPost, BlogUser> {
        return parent(id: author)
    }
    
    var tags: Siblings<BlogPost, BlogTag, Pivot<BlogPost, BlogTag>> {
        return siblings()
    }
}

// MARK: - Pagination

extension BlogPost: Paginatable {
    public static var defaultPageSorts: [Sort] {
        return []
    }
    
    public static var defaultPageSize: Int {
        return postsPerPage
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
