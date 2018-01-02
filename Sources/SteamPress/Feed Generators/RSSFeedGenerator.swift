//import Vapor
//import Foundation
//
//struct RSSFeedGenerator {
//    
//    // MARK: - Properties
//    
//    let rfc822DateFormatter: DateFormatter
//    let title: String
//    let description: String
//    let copyright: String?
//    let imageURL: String?
//    let xmlEnd = "</channel>\n\n</rss>"
//    
//    // MARK: - Initialiser
//    
//    init(title: String, description: String, copyright: String?, imageURL: String?) {
//        self.title = title
//        self.description = description
//        self.copyright = copyright
//        self.imageURL = imageURL
//        
//        rfc822DateFormatter = DateFormatter()
//        rfc822DateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss z"
//        rfc822DateFormatter.locale = Locale(identifier: "en_US_POSIX")
//        rfc822DateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
//    }
//    
//    // MARK: - Route Handler
//    
//    func feedHandler(_ request: Request) throws -> Response {
//        
//        var xmlFeed = try getXMLStart(for: request)
//        
//        let posts = try BlogPost.makeQuery().filter(BlogPost.Properties.published, true).sort(BlogPost.Properties.created, .descending).all()
//        
//        if !posts.isEmpty {
//            let postDate = posts[0].lastEdited ?? posts[0].created
//            xmlFeed += "<pubDate>\(rfc822DateFormatter.string(from: postDate))</pubDate>\n"
//        }
//        
//        xmlFeed += "<textinput>\n<description>Search \(title)</description>\n<title>Search</title>\n<link>\(getRootPath(for: request))/search?</link>\n<name>term</name>\n</textinput>\n"
//        
//        for post in posts {
//            xmlFeed += try post.getPostRSSFeed(rootPath: getRootPath(for: request), dateFormatter: rfc822DateFormatter)
//        }
//        
//        xmlFeed += xmlEnd
//
//        return Response(status: .ok, headers: [.contentType: "application/rss+xml"], body: xmlFeed.makeBytes())
//    }
//    
//    // MARK: - Private functions
//    
//    private func getXMLStart(for request: Request) throws -> String {
//        
//        let link = getRootPath(for: request) + "/"
//        
//        var start = "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>\n<rss version=\"2.0\">\n\n<channel>\n<title>\(title)</title>\n<link>\(link)</link>\n<description>\(description)</description>\n<generator>SteamPress</generator>\n<ttl>60</ttl>\n"
//        
//        if let copyright = copyright {
//            start += "<copyright>\(copyright)</copyright>\n"
//        }
//        
//        if let imageURL = imageURL {
//            start += "<image>\n<url>\(imageURL)</url>\n<title>\(title)</title>\n<link>\(link)</link>\n</image>\n"
//        }
//        
//        return start
//    }
//    
//    private func getRootPath(for request: Request) -> String {
//        return request.getURIWithHTTPSIfReverseProxy().descriptionWithoutPort.replacingOccurrences(of: "/rss.xml", with: "")
//    }
//}
//
//extension BlogPost {
//    func getPostRSSFeed(rootPath: String, dateFormatter: DateFormatter) throws -> String {
//        let link = rootPath + "/posts/\(slugUrl)/"
//        var postEntry = "<item>\n<title>\n\(title)\n</title>\n<description>\n\(try description())\n</description>\n<link>\n\(link)\n</link>\n"
//        
//        for tag in try tags.all() {
//            postEntry += "<category>\(tag.name)</category>\n"
//        }
//        
//        postEntry += "<pubDate>\(dateFormatter.string(from: lastEdited ?? created))</pubDate>\n</item>\n"
//        
//        return postEntry
//    }
//}

