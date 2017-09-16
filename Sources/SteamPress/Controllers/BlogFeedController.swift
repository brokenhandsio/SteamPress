import Vapor
import Foundation

struct BlogFeedController {

    // MARK: - Properties
    fileprivate let drop: Droplet
    fileprivate let pathCreator: BlogPathCreator
    fileprivate let atomGenerator: AtomFeedGenerator
    fileprivate let rssGenerator: RSSFeedGenerator
    static let defaultTitle = "SteamPress Blog"
    static let defaultDescription = "SteamPress is an open-source blogging engine written for Vapor in Swift"

    // MARK: - Initialiser
    init(drop: Droplet, pathCreator: BlogPathCreator, title: String?, description: String?, copyright: String?, imageURL: String?) {
        self.drop = drop
        self.pathCreator = pathCreator
        
        let rfc822DateFormatter = DateFormatter()
        rfc822DateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss z"
        
        let feedTitle = title ?? BlogFeedController.defaultTitle
        let feedDescription = description ?? BlogFeedController.defaultDescription
        
        atomGenerator = AtomFeedGenerator()
        rssGenerator = RSSFeedGenerator(rfc822DateFormatter: rfc822DateFormatter, title: feedTitle,
                                        description: feedDescription, copyright: copyright,
                                        imageURL: imageURL)
    }

    // MARK: - Route setup
    func addRoutes() {
        drop.group(pathCreator.blogPath ?? "") { index in
            index.get("rss.xml", handler: rssGenerator.feedHandler)
            index.get("atom.xml", handler: atomGenerator.feedHandler)
        }
    }
}


