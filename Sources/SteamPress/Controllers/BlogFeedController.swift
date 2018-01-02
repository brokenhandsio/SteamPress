//import Vapor
//import Foundation
//
//struct BlogFeedController {
//
//    // MARK: - Properties
//    fileprivate let drop: Droplet
//    fileprivate let pathCreator: BlogPathCreator
//    fileprivate let atomGenerator: AtomFeedGenerator
//    fileprivate let rssGenerator: RSSFeedGenerator
//    static let defaultTitle = "SteamPress Blog"
//    static let defaultDescription = "SteamPress is an open-source blogging engine written for Vapor in Swift"
//
//    // MARK: - Initialiser
//    init(drop: Droplet, pathCreator: BlogPathCreator, title: String?, description: String?, copyright: String?,
//         imageURL: String?) {
//        self.drop = drop
//        self.pathCreator = pathCreator
//        
//        let feedTitle = title ?? BlogFeedController.defaultTitle
//        let feedDescription = description ?? BlogFeedController.defaultDescription
//        
//        atomGenerator = AtomFeedGenerator(title: feedTitle, description: feedDescription,
//                                          copyright: copyright, imageURL: imageURL)
//        rssGenerator = RSSFeedGenerator(title: feedTitle, description: feedDescription,
//                                        copyright: copyright, imageURL: imageURL)
//    }
//
//    // MARK: - Route setup
//    func addRoutes() {
//        drop.group(pathCreator.blogPath ?? "") { index in
//            index.get("rss.xml", handler: rssGenerator.feedHandler)
//            index.get("atom.xml", handler: atomGenerator.feedHandler)
//        }
//    }
//}
//
//
