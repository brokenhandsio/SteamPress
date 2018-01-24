import Vapor
import Foundation
import Fluent

struct AtomFeedGenerator<DatabaseType> where DatabaseType: QuerySupporting, DatabaseType: SchemaSupporting, DatabaseType: JoinSupporting {
    
    // MARK: - Properties
    let title: String
    let description: String
    let copyright: String?
    let imageURL: String?
    
    let xmlDeclaration = "<?xml version=\"1.0\" encoding=\"utf-8\"?>"
    let feedStart = "<feed xmlns=\"http://www.w3.org/2005/Atom\">"
    let feedEnd = "</feed>"
    let iso8601Formatter = DateFormatter()
   
    // MARK: - Initialiser
    init(title: String, description: String, copyright: String?, imageURL: String?) {
        self.title = title
        self.description = description
        self.copyright = copyright
        self.imageURL = imageURL
        
        iso8601Formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        iso8601Formatter.locale = Locale(identifier: "en_US_POSIX")
        iso8601Formatter.timeZone = TimeZone(secondsFromGMT: 0)
    }
    
    // MARK: - Route Handler
    
    func feedHandler(_ request: Request) throws -> Future<HTTPResponse> {
        
        var feed = try getFeedStart(for: request)

        return BlogPost<DatabaseType>.query(on: request).filter(\.published == true).sort(\.created, .descending).all().flatMap(to: HTTPResponse.self) { posts in

            if !posts.isEmpty {
                let postDate = posts[0].lastEdited ?? posts[0].created
                    feed += "<updated>\(self.iso8601Formatter.string(from: postDate))</updated>\n"
                } else {
                feed += "<updated>\(self.iso8601Formatter.string(from: Date()))</updated>\n"
            }

            if let copyright = self.copyright {
                feed += "<rights>\(copyright)</rights>\n"
            }

            if let imageURL = self.imageURL {
                feed += "<logo>\(imageURL)</logo>\n"
            }

            let blogPath = self.getRootPath(for: request) + "/"

            for post in posts {
                let updatedTime = post.lastEdited ?? post.created
                let author = try post.postAuthor.get(on: request).await(on: request)
                feed += try "<entry>\n<id>\(blogPath)posts-id/\(post.requireID())/</id>\n<title>\(post.title)</title>\n<updated>\(self.iso8601Formatter.string(from: updatedTime))</updated>\n<published>\(self.iso8601Formatter.string(from: post.created))</published>\n<author>\n<name>\(author.name)</name>\n<uri>\(blogPath)authors/\(author.username)/</uri>\n</author>\n<summary>\(try post.description())</summary>\n<link rel=\"alternate\" href=\"\(blogPath)posts/\(post.slugUrl)/\" />\n"

                // TODO remove await
                for tag in try post.tags.query(on: request).all().await(on: request) {
                    feed += "<category term=\"\(tag.name)\"/>\n"
                }

                feed += "</entry>\n"
            }

            feed += self.feedEnd

            return try Future(HTTPResponse(status: .ok, headers: [.contentType: "application/atom+xml"], body: feed.makeBody()))
        }

    }
    
    // MARK: - Private functions
    
    private func getFeedStart(for request: Request) throws -> String {
        let blogLink = getRootPath(for: request) + "/"
        let feedLink = blogLink + "atom.xml"
        return "\(xmlDeclaration)\n\(feedStart)\n\n<title>\(title)</title>\n<subtitle>\(description)</subtitle>\n<id>\(blogLink)</id>\n<link rel=\"alternate\" type=\"text/html\" href=\"\(blogLink)\"/>\n<link rel=\"self\" type=\"application/atom+xml\" href=\"\(feedLink)\"/>\n<generator uri=\"https://www.steampress.io/\">SteamPress</generator>\n"
    }
    
    private func getRootPath(for request: Request) -> String {
        return request.getURIWithHTTPSIfReverseProxy().descriptionWithoutPort.replacingOccurrences(of: "/atom.xml", with: "")
    }
}

