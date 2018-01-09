import Vapor
import Foundation
import Fluent

struct BlogFeedController<DatabaseType>: RouteCollection where DatabaseType: QuerySupporting, DatabaseType: SchemaSupporting {

    // MARK: - Properties
    fileprivate let pathCreator: BlogPathCreator
    fileprivate let atomGenerator: AtomFeedGenerator<DatabaseType>
//    fileprivate let rssGenerator: RSSFeedGenerator
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
//        rssGenerator = RSSFeedGenerator(title: feedTitle, description: feedDescription,
//                                        copyright: copyright, imageURL: imageURL)
    }

    // MARK: - Route Collection
//    func addRoutes() {
//        drop.group(pathCreator.blogPath ?? "") { index in
//            index.get("rss.xml", handler: rssGenerator.feedHandler)
//            index.get("atom.xml", handler: atomGenerator.feedHandler)
//        }
//    }

    func boot(router: Router) throws {
        router.get("atom.xml", use: atomGenerator.feedHandler)
//        router.group(pathCreator.blogPath ?? "", use: { index in
//            index.get("atom.xml", use: atomGenerator.feedHandler)
//        })
    }
}



