import Vapor

struct BlogRSSController {

    // MARK: - Properties
    fileprivate let drop: Droplet

    // MARK: - Initialiser
    init(drop: Droplet) {
        self.drop = drop
    }

    // MARK: - Route setup
    func addRoutes() {
        drop.get("feed", handler: rssXmlFeedHandler)
    }

    // MARK: - Route Handler

    private func rssXmlFeedHandler(_ request: Request) throws -> ResponseRepresentable {
        return "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>\n<rss version=\"2.0\">\n\n<channel>\n<title>SteamPress Blog</title>\n<link>https://www.steampress.io</link>\n<description>SteamPress is an open-source blogging engine written for Vapor in Swift</description>\n</channel>\n\n</rss>"
    }
}
