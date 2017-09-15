import Vapor

struct BlogRSSController {

    // MARK: - Properties
    fileprivate let drop: Droplet
    fileprivate let pathCreator: BlogPathCreator
    fileprivate let title: String?
    fileprivate let description: String?
    fileprivate let copyright: String?

    let xmlEnd = "</channel>\n\n</rss>"

    // MARK: - Initialiser
    init(drop: Droplet, pathCreator: BlogPathCreator, title: String?, description: String?, copyright: String?) {
        self.drop = drop
        self.pathCreator = pathCreator
        self.title = title
        self.description = description
        self.copyright = copyright
    }

    // MARK: - Route setup
    func addRoutes() {
        drop.group(pathCreator.blogPath ?? "") { index in
            index.get("rss.xml", handler: rssXmlFeedHandler)
        }
    }

    // MARK: - Route Handler

    private func rssXmlFeedHandler(_ request: Request) throws -> ResponseRepresentable {

        var xmlFeed = getXMLStart()

        for post in try BlogPost.makeQuery().filter(BlogPost.Properties.published, true).all() {
            xmlFeed += try post.getPostRSSFeed(pathCreator: pathCreator)
        }

        xmlFeed += xmlEnd

        return xmlFeed
    }

    private func getXMLStart() -> String {

        var title = "SteamPress Blog"
        var description = "SteamPress is an open-source blogging engine written for Vapor in Swift"

        if let providedTitle = self.title {
            title = providedTitle
        }

        if let providedDescription = self.description {
            description = providedDescription
        }
        
        let link = pathCreator.createPath(for: nil)
        
        var start = "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>\n<rss version=\"2.0\">\n\n<channel>\n<title>\(title)</title>\n<link>\(link)</link>\n<description>\(description)</description>\n<generator>SteamPress</generator>\n"
        
        if let copyright = copyright {
            start += "<copyright>\(copyright)</copyright>\n"
        }
        
        return start
    }
}

extension BlogPost {
    func getPostRSSFeed(pathCreator: BlogPathCreator) throws -> String {
        let link = pathCreator.createPath(for: "posts/\(slugUrl)")
        var postEntry = "<item>\n<title>\n\(title)\n</title>\n<description>\n\(shortSnippet())\n</description>\n<link>\n\(link)\n</link>\n"
        
        for tag in try tags.all() {
            postEntry += "<category>\(tag.name)</category>\n"
        }
        
        postEntry += "</item>\n"
        
        return postEntry
    }
}
