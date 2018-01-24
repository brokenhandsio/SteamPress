import Vapor
import Foundation
import Fluent

struct BlogFeedController<DatabaseType>: RouteCollection where DatabaseType: QuerySupporting & SchemaSupporting & JoinSupporting {

    // MARK: - Properties
    fileprivate let pathCreator: BlogPathCreator
    fileprivate let atomGenerator: AtomFeedGenerator<DatabaseType>
    fileprivate let rssGenerator: RSSFeedGenerator<DatabaseType>
    static var defaultTitle: String {
        return "SteamPress Blog"
    }
    static var defaultDescription: String {
        return "SteamPress is an open-source blogging engine written for Vapor in Swift"
    }

    // MARK: - Initialiser
    init(pathCreator: BlogPathCreator, title: String?, description: String?, copyright: String?,
         imageURL: String?) {
        self.pathCreator = pathCreator

        let feedTitle = title ?? BlogFeedController.defaultTitle
        let feedDescription = description ?? BlogFeedController.defaultDescription

        atomGenerator = AtomFeedGenerator(title: feedTitle, description: feedDescription,
                                          copyright: copyright, imageURL: imageURL)
        rssGenerator = RSSFeedGenerator(title: feedTitle, description: feedDescription,
                                        copyright: copyright, imageURL: imageURL)
    }

    // MARK: - Route Collection
    func boot(router: Router) throws {
        router.group(PathComponent(stringLiteral: "\(pathCreator.blogPath ?? "")"), use: { index in
            index.get("atom.xml", use: atomGenerator.feedHandler)
            index.get("rss.xml", use: rssGenerator.feedHandler)
        })
    }
}



