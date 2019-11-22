import Foundation
import Vapor
import SwiftSoup
import SwiftMarkdown

// MARK: - Model

public final class BlogPost: Codable {

    public var blogID: Int?
    public var title: String
    public var contents: String
    public var author: Int
    public var created: Date
    public var lastEdited: Date?
    public var slugUrl: String
    public var published: Bool

    public init(title: String, contents: String, author: BlogUser, creationDate: Date, slugUrl: String,
         published: Bool) throws {
        self.title = title
        self.contents = contents
        guard let authorID = author.userID else {
            throw SteamPressError(identifier: "ID-required", "Author ID not set")
        }
        self.author = authorID
        self.created = creationDate
        self.slugUrl = slugUrl
        self.lastEdited = nil
        self.published = published
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

    func description() throws -> String {
        return try SwiftSoup.parse(markdownToHTML(shortSnippet())).text()
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

    static func generateUniqueSlugURL(from title: String, on req: Request) throws -> EventLoopFuture<String> {
        let postRepository = try req.make(BlogPostRepository.self)
        let alphanumericsWithHyphenAndSpace = CharacterSet(charactersIn: " -0123456789abcdefghijklmnopqrstuvwxyz")
        let initialSlug = title.lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .components(separatedBy: alphanumericsWithHyphenAndSpace.inverted).joined()
            .components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }.joined(separator: " ")
            .replacingOccurrences(of: " ", with: "-", options: .regularExpression)
        return postRepository.getPost(slug: initialSlug, on: req).map { postWithSameSlug in
            if postWithSameSlug != nil {
                let randomNumberGenerator = try req.make(SteamPressRandomNumberGenerator.self)
                let randomNumber = randomNumberGenerator.getNumber()
                return "\(initialSlug)-\(randomNumber)"
            } else {
                return initialSlug
            }
        }
    }
}
