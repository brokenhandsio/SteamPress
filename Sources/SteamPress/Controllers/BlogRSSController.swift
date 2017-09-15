import Vapor

struct BlogRSSController {

    // MARK: - Properties
    fileprivate let drop: Droplet
    fileprivate let pathCreator: BlogPathCreator
    fileprivate let title: String?
    fileprivate let description: String?
    fileprivate let copyright: String?
    fileprivate let imageURL: String?

    let xmlEnd = "</channel>\n\n</rss>"

    // MARK: - Initialiser
    init(drop: Droplet, pathCreator: BlogPathCreator, title: String?, description: String?, copyright: String?, imageURL: String?) {
        self.drop = drop
        self.pathCreator = pathCreator
        self.title = title
        self.description = description
        self.copyright = copyright
        self.imageURL = imageURL
    }

    // MARK: - Route setup
    func addRoutes() {
        drop.group(pathCreator.blogPath ?? "") { index in
            index.get("rss.xml", handler: rssXmlFeedHandler)
        }
    }

    // MARK: - Route Handler

    private func rssXmlFeedHandler(_ request: Request) throws -> ResponseRepresentable {

        var xmlFeed = try getXMLStart(for: request)

        for post in try BlogPost.makeQuery().filter(BlogPost.Properties.published, true).all() {
            xmlFeed += try post.getPostRSSFeed(rootPath: getRootPath(for: request))
        }

        xmlFeed += xmlEnd

        return xmlFeed
    }

    private func getXMLStart(for request: Request) throws -> String {

        var title = "SteamPress Blog"
        var description = "SteamPress is an open-source blogging engine written for Vapor in Swift"

        if let providedTitle = self.title {
            title = providedTitle
        }

        if let providedDescription = self.description {
            description = providedDescription
        }
        
        let link = getLink(for: request)
        
        var start = "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>\n<rss version=\"2.0\">\n\n<channel>\n<title>\(title)</title>\n<link>\(link)</link>\n<description>\(description)</description>\n<generator>SteamPress</generator>\n<ttl>60</ttl>\n"
        
        if let copyright = copyright {
            start += "<copyright>\(copyright)</copyright>\n"
        }
        
        if let imageURL = imageURL {
            start += "<image>\n<url>\(imageURL)</url>\n<title>\(title)</title>\n<link>\(link)</link>\n</image>\n"
        }
        
        return start
    }
    
    private func getLink(for request: Request) -> String {
        return getRootPath(for: request) + "/"
    }
    
    private func getRootPath(for request: Request) -> String {
        return request.getURIWithHTTPSIfReverseProxy().descriptionWithoutPort.replacingOccurrences(of: "/rss.xml", with: "")
    }
}

extension BlogPost {
    func getPostRSSFeed(rootPath: String) throws -> String {
        let link = rootPath + "/posts/\(slugUrl)/"
        var postEntry = "<item>\n<title>\n\(title)\n</title>\n<description>\n\(shortSnippet())\n</description>\n<link>\n\(link)\n</link>\n"
        
        for tag in try tags.all() {
            postEntry += "<category>\(tag.name)</category>\n"
        }
        
        postEntry += "</item>\n"
        
        return postEntry
    }
}
