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
        
        iso8601Formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
    }
    
    // MARK: - Route Handler
    
    func feedHandler(_ request: Request) throws -> ResponseRepresentable {
        
        var feed = try getFeedStart(for: request)

        let posts = try BlogPost.makeQuery().filter(BlogPost.Properties.published, true).sort(BlogPost.Properties.created, .descending).all()

        if !posts.isEmpty {
            let postDate = posts[0].lastEdited ?? posts[0].created
            feed += "<updated>\(iso8601Formatter.string(from: postDate))</updated>\n"
        } else {
            feed += "<updated>\(iso8601Formatter.string(from: Date()))</updated>\n"
        }
        
        if let copyright = copyright {
            feed += "<rights>\(copyright)</rights>\n"
        }
        
        if let imageURL = imageURL {
            feed += "<logo>\(imageURL)</logo>\n"
        }

        for post in posts {
//            xmlFeed += try post.getPostRSSFeed(rootPath: getRootPath(for: request), dateFormatter: rfc822DateFormatter)
        }

        feed += feedEnd

        return feed
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
