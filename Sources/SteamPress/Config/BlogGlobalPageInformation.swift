import Foundation

public struct BlogGlobalPageInformation: Encodable {
    let disqusName: String?
    let siteTwitterHandler: String?
    let googleAnalyticsIdentifier: String?
    let loggedInUser: BlogUser?
    let websiteURL: URL
    let currentPageURL: URL
}

#warning("Test this gets set correctly in route handler")
