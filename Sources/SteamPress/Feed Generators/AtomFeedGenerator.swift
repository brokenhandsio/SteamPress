import Vapor

struct AtomFeedGenerator {
   
    // MARK: - Route Handler
    
    public func feedHandler(_ request: Request) throws -> ResponseRepresentable {
        
        return ""
        
//        var xmlFeed = try getXMLStart(for: request)
//
//        let posts = try BlogPost.makeQuery().filter(BlogPost.Properties.published, true).sort(BlogPost.Properties.created, .descending).all()
//
//        if !posts.isEmpty {
//            let postDate = posts[0].lastEdited ?? posts[0].created
//            xmlFeed += "<pubDate>\(rfc822DateFormatter.string(from: postDate))</pubDate>\n"
//        }
//
//        for post in posts {
//            xmlFeed += try post.getPostRSSFeed(rootPath: getRootPath(for: request), dateFormatter: rfc822DateFormatter)
//        }
//
//        xmlFeed += xmlEnd
//
//        return xmlFeed
    }
}
