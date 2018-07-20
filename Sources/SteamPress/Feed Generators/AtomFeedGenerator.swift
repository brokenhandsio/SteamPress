import Vapor
import Foundation

struct AtomFeedGenerator {
    
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
    
    func feedHandler(_ request: Request) throws -> Future<Response> {

        return request.future(request.makeResponse())
//        var feed = try getFeedStart(for: request)

//        return try BlogPost<DatabaseType>.query(on: request).filter(\.published == true).sort(\.created, .descending).all().flatMap(to: Response.self) { posts in
//
//            if !posts.isEmpty {
//                let postDate = posts[0].lastEdited ?? posts[0].created
//                    feed += "<updated>\(self.iso8601Formatter.string(from: postDate))</updated>\n"
//                } else {
//                feed += "<updated>\(self.iso8601Formatter.string(from: Date()))</updated>\n"
//            }
//
//            if let copyright = self.copyright {
//                feed += "<rights>\(copyright)</rights>\n"
//            }
//
//            if let imageURL = self.imageURL {
//                feed += "<logo>\(imageURL)</logo>\n"
//            }
//
//            let blogPath = self.getRootPath(for: request) + "/"
//            var postData: [Future<String>] = []
//
//            for post in posts {
//                try postData.append(post.getPostAtomFeed(blogPath: blogPath, dateFormatter: self.iso8601Formatter, for: request))
//            }
//
//            return postData.flatten(on: request).map(to: Response.self) { postInformation in
//                for post in postInformation {
//                    feed += post
//                }
//                feed += self.feedEnd
//                var httpResponse = HTTPResponse(status: .ok, body: feed)
//                httpResponse.headers.add(name: .contentType, value: "application/atom+xml")
//                return Response(http: httpResponse, using: request)
//            }
//        }

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

fileprivate extension BlogPost {
    fileprivate func getPostAtomFeed(blogPath: String, dateFormatter: DateFormatter, for request: Request) throws -> Future<String> {
//        let updatedTime = lastEdited ?? created
//        return try postAuthor.get(on: request).flatMap(to: String.self) { author in
//
//            var postEntry = try "<entry>\n<id>\(blogPath)posts-id/\(self.requireID())/</id>\n<title>\(self.title)</title>\n<updated>\(dateFormatter.string(from: updatedTime))</updated>\n<published>\(dateFormatter.string(from: self.created))</published>\n<author>\n<name>\(author.name)</name>\n<uri>\(blogPath)authors/\(author.username)/</uri>\n</author>\n<summary>\(try self.description())</summary>\n<link rel=\"alternate\" href=\"\(blogPath)posts/\(self.slugUrl)/\" />\n"
//
//            return try self.tags.query(on: request).all().map(to: String.self) { tags in
//                for tag in tags {
//                    postEntry += "<category term=\"\(tag.name)\"/>\n"
//                }
//
//                postEntry += "</entry>\n"
//
//                return postEntry
//            }
//        }
      return request.future("")
    }
}

