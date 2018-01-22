import Foundation
import Vapor
import Fluent

// MARK: - Model

public final class BlogPost<DatabaseType>: Model where DatabaseType: QuerySupporting & SchemaSupporting & JoinSupporting {

//    public struct Properties {
//        public static let blogPostID = "id"
//        public static let title = "title"
//        public static let contents = "contents"
//        public static let slugUrl = "slug_url"
//        public static let published = "published"
//        public static let created = "created"
//        public static let lastEdited = "last_edited"
//        public static let authorName = "author_name"
//        public static let authorUsername = "author_username"
//        public static let createdDate = "created_date"
//        public static let createdDateIso8601 = "created_date_iso8601"
//        public static let lastEditedDate = "last_edited_date"
//        public static let lastEditedDateIso8601 = "last_edited_date_iso8601"
//        public static let shortSnippet = "short_snippet"
//        public static let longSnippet = "long_snippet"
//        public static let tags = "tags"
//    }

//    static var postsPerPage = 10

    // TODO convert to UUID?
    public typealias ID = Int
    public static var idKey: ReferenceWritableKeyPath<BlogPost<DatabaseType>, Int?> {
        return \BlogPost.blogID
    }
    public typealias Database = DatabaseType

    public var blogID: Int?
    public var title: String
    public var contents: String
    public var author: BlogUser<DatabaseType>.ID
    public var created: Date
    public var lastEdited: Date?
    public var slugUrl: String
    public var published: Bool

    public init(title: String, contents: String, author: BlogUser<DatabaseType>, creationDate: Date, slugUrl: String,
         published: Bool/*, logger: LogProtocol? = nil*/) throws {
        self.title = title
        self.contents = contents
        self.author = try author.requireID()
        self.created = creationDate
//        self.slugUrl = BlogPost.generateUniqueSlugUrl(from: slugUrl, logger: logger)
        self.slugUrl = title
        self.lastEdited = nil
        self.published = published
    }
}

extension BlogPost: Migration {}

//
//extension BlogPost: Parameterizable {}
//
//// MARK: - Node
//
//public enum BlogPostContext: Context {
//    case all
//    case shortSnippet
//    case longSnippet
//}
//
//extension BlogPost: NodeRepresentable {
//    public func makeNode(in context: Context?) throws -> Node {
//        let createdTime = created.timeIntervalSince1970
//
//        var node = Node([:], in: context)
//        try node.set(Properties.blogPostID, id)
//        try node.set(Properties.title, title)
//        try node.set(Properties.contents, contents)
//        try node.set(BlogUser.foreignIdKey, author)
//        try node.set(Properties.created, createdTime)
//        try node.set(Properties.slugUrl, slugUrl)
//        try node.set(Properties.published, published)
//
//        if let lastEdited = lastEdited {
//            try node.set(Properties.lastEdited, lastEdited.timeIntervalSince1970)
//        }
//
//        guard let providedContext = context else {
//            return node
//        }
//
//        if type(of: providedContext) != BlogPostContext.self {
//            return node
//        }
//
//        let dateFormatter = DateFormatter()
//        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
//        dateFormatter.dateStyle = .full
//        dateFormatter.timeStyle = .none
//        let createdDate = dateFormatter.string(from: created)
//
//        try node.set(Properties.authorName, postAuthor.get()?.name)
//        try node.set(Properties.authorUsername, postAuthor.get()?.username)
//        try node.set(Properties.createdDate, createdDate)
//
//        switch providedContext {
//        case BlogPostContext.shortSnippet:
//            try node.set(Properties.shortSnippet, shortSnippet())
//            break
//        case BlogPostContext.longSnippet:
//            try node.set(Properties.longSnippet, longSnippet())
//
//            let allTags = try tags.all()
//            if !allTags.isEmpty {
//                try node.set(Properties.tags, allTags)
//            }
//            break
//        case BlogPostContext.all:
//            let allTags = try tags.all()
//
//            if !allTags.isEmpty {
//                try node.set(Properties.tags, allTags)
//            }
//
//            let iso8601Formatter = DateFormatter()
//            iso8601Formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
//            iso8601Formatter.locale = Locale(identifier: "en_US_POSIX")
//            iso8601Formatter.timeZone = TimeZone(secondsFromGMT: 0)
//
//            try node.set(Properties.createdDateIso8601, iso8601Formatter.string(from: created))
//
//            if let lastEdited = lastEdited {
//                let lastEditedDate = dateFormatter.string(from: lastEdited)
//                try node.set(Properties.lastEditedDate, lastEditedDate)
//                try node.set(Properties.lastEditedDateIso8601, iso8601Formatter.string(from: lastEdited))
//            }
//            try node.set(Properties.shortSnippet, shortSnippet())
//            try node.set(Properties.longSnippet, longSnippet())
//        default: break
//        }
//
//        return node
//    }
//}
//
//// MARK: - BlogPost Utilities
//
//extension BlogPost {
//
//    public func shortSnippet() -> String {
//        return getLines(characterLimit: 150)
//    }
//
//    public func longSnippet() -> String {
//        return getLines(characterLimit: 900)
//    }
//
//    private func getLines(characterLimit: Int) -> String {
//        contents = contents.replacingOccurrences(of: "\r\n", with: "\n", options: .regularExpression)
//        let lines = contents.components(separatedBy: "\n")
//        var snippet = ""
//        for line in lines {
//            snippet += "\(line)\n"
//            if snippet.count > characterLimit {
//                return snippet
//            }
//        }
//        return snippet
//    }
//
//    static func generateUniqueSlugUrl(from title: String, logger: LogProtocol?) -> String {
//        let alphanumericsWithHyphenAndSpace = CharacterSet(charactersIn: " -0123456789abcdefghijklmnopqrstuvwxyz")
//
//        let slugUrl = title.lowercased()
//            .trimmingCharacters(in: .whitespacesAndNewlines)
//            .components(separatedBy: alphanumericsWithHyphenAndSpace.inverted).joined()
//            .components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }.joined(separator: " ")
//            .replacingOccurrences(of: " ", with: "-", options: .regularExpression)
//
//        var newSlugUrl = slugUrl
//        var count = 2
//
//        do {
//            while try BlogPost.makeQuery().filter(Properties.slugUrl, newSlugUrl).first() != nil {
//              newSlugUrl = "\(slugUrl)-\(count)"
//              count += 1
//            }
//        } catch {
//            logger?.debug("Error uniqueing the slug URL: \(error)")
//            // Swallow error - this will propragate the error up to the DB driver which should fail if it is not unique
//        }
//
//        return newSlugUrl
//    }
//}

// MARK: - Relations

extension BlogPost {
    var postAuthor: Parent<BlogPost, BlogUser<DatabaseType>> {
        return parent(\.author)
    }

    var tags: Siblings<BlogPost, BlogTag<DatabaseType>, BlogPostTagPivot<DatabaseType>> {
        return siblings()
    }
}

//// MARK: - Pagination
//
//extension BlogPost: Paginatable {
//    public static var defaultPageSorts: [Sort] {
//        return []
//    }
//
//    public static var defaultPageSize: Int {
//        return postsPerPage
//    }
//}
//
//extension Page {
//    public func makeNode(for uri: URI, in context: Context?) throws -> Node {
//        var node = Node([:], in: context)
//        try node.set("data", data.makeNode(in: context))
//
//        var paginationNode = Node([:], in: context)
//        try paginationNode.set("total", total)
//        try paginationNode.set("current_page", number)
//        try paginationNode.set("per_page", size)
//
//        var pages = total / size
//        if total % size != 0 {
//            pages += 1
//        }
//
//        try paginationNode.set("total_pages", pages)
//        if number < pages {
//            try paginationNode.set("next_page", "?page=\(number + 1)")
//        }
//        if number > 1 {
//            try paginationNode.set("previous_page", "?page=\(number - 1)")
//        }
//
//        try node.set("pagination", paginationNode)
//        return node
//    }
//}

