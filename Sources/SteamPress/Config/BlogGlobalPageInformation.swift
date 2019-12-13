import Foundation

public struct BlogGlobalPageInformation: Encodable {
    public let disqusName: String?
    public let siteTwitterHandler: String?
    public let googleAnalyticsIdentifier: String?
    public let loggedInUser: BlogUser?
    public let websiteURL: URL
    public let currentPageURL: URL
}

#warning("Test this gets set correctly in route handler")
