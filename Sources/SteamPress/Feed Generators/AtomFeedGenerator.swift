//import Vapor
//import Foundation
//
//struct AtomFeedGenerator {
//    
//    // MARK: - Properties
//    let title: String
//    let description: String
//    let copyright: String?
//    let imageURL: String?
//    
//    let xmlDeclaration = "<?xml version=\"1.0\" encoding=\"utf-8\"?>"
//    let feedStart = "<feed xmlns=\"http://www.w3.org/2005/Atom\">"
//    let feedEnd = "</feed>"
//    let iso8601Formatter = DateFormatter()
//   
//    // MARK: - Initialiser
//    init(title: String, description: String, copyright: String?, imageURL: String?) {
//        self.title = title
//        self.description = description
//        self.copyright = copyright
//        self.imageURL = imageURL
//        
//        iso8601Formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
//        iso8601Formatter.locale = Locale(identifier: "en_US_POSIX")
//        iso8601Formatter.timeZone = TimeZone(secondsFromGMT: 0)
//    }
//    
//    // MARK: - Route Handler
//    
//    func feedHandler(_ request: Request) throws -> Response {
//        
//        var feed = try getFeedStart(for: request)
//
//        let posts = try BlogPost.makeQuery().filter(BlogPost.Properties.published, true).sort(BlogPost.Properties.created, .descending).all()
//
//        if !posts.isEmpty {
//            let postDate = posts[0].lastEdited ?? posts[0].created
//            feed += "<updated>\(iso8601Formatter.string(from: postDate))</updated>\n"
//        } else {
//            feed += "<updated>\(iso8601Formatter.string(from: Date()))</updated>\n"
//        }
//        
//        if let copyright = copyright {
//            feed += "<rights>\(copyright)</rights>\n"
//        }
//        
//        if let imageURL = imageURL {
//            feed += "<logo>\(imageURL)</logo>\n"
//        }
//        
//        let blogPath = getRootPath(for: request) + "/"
//
//        for post in posts {
//            let updatedTime = post.lastEdited ?? post.created
//            guard let author = try post.postAuthor.get() else {
//                throw Abort.serverError
//            }
//            feed += "<entry>\n<id>\(blogPath)posts-id/\(post.id?.string ?? post.slugUrl)/</id>\n<title>\(post.title)</title>\n<updated>\(iso8601Formatter.string(from: updatedTime))</updated>\n<published>\(iso8601Formatter.string(from: post.created))</published>\n<author>\n<name>\(author.name)</name>\n<uri>\(blogPath)authors/\(author.username)/</uri>\n</author>\n<summary>\(try post.description())</summary>\n<link rel=\"alternate\" href=\"\(blogPath)posts/\(post.slugUrl)/\" />\n"
//
//            for tag in try post.tags.all() {
//                feed += "<category term=\"\(tag.name)\"/>\n"
//            }
//
//            feed += "</entry>\n"
//        }
//
//        feed += feedEnd
//
//        return Response(status: .ok, headers: [.contentType: "application/atom+xml"], body: feed.makeBytes())
//    }
//    
//    // MARK: - Private functions
//    
//    private func getFeedStart(for request: Request) throws -> String {
//        let blogLink = getRootPath(for: request) + "/"
//        let feedLink = blogLink + "atom.xml"
//        return "\(xmlDeclaration)\n\(feedStart)\n\n<title>\(title)</title>\n<subtitle>\(description)</subtitle>\n<id>\(blogLink)</id>\n<link rel=\"alternate\" type=\"text/html\" href=\"\(blogLink)\"/>\n<link rel=\"self\" type=\"application/atom+xml\" href=\"\(feedLink)\"/>\n<generator uri=\"https://www.steampress.io/\">SteamPress</generator>\n"
//    }
//    
//    private func getRootPath(for request: Request) -> String {
//        return request.getURIWithHTTPSIfReverseProxy().descriptionWithoutPort.replacingOccurrences(of: "/atom.xml", with: "")
//    }
//}

