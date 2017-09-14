import Vapor

struct BlogRSSController {

    // MARK: - Properties
    fileprivate let drop: Droplet
    fileprivate let pathCreator: BlogPathCreator
    fileprivate let title: String?
    fileprivate let description: String?

    let xmlEnd = "</channel>\n\n</rss>"

    // MARK: - Initialiser
    init(drop: Droplet, pathCreator: BlogPathCreator, title: String?, description: String?) {
        self.drop = drop
        self.pathCreator = pathCreator
        self.title = title
        self.description = description
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
            xmlFeed += post.getPostRSSFeed(pathCreator: pathCreator)
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

        return "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>\n<rss version=\"2.0\">\n\n<channel>\n<title>\(title)</title>\n<link>\(link)</link>\n<description>\(description)</description>\n<generator>SteamPress</generator>\n"
    }
}

extension BlogPost {
    func getPostRSSFeed(pathCreator: BlogPathCreator) -> String {
        let link = pathCreator.createPath(for: "posts/\(slugUrl)")
        return "<item>\n<title>\n\(title)\n</title>\n<description>\n\(shortSnippet())\n</description>\n<link>\n\(link)\n</link>\n</item>\n"
    }
}
