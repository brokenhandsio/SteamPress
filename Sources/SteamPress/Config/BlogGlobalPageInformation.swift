import Foundation

public struct BlogGlobalPageInformation: Encodable {
    public let disqusName: String?
    public let siteTwitterHandle: String?
    public let googleAnalyticsIdentifier: String?
    public let loggedInUser: BlogUser?
    public let websiteURL: URL
    public let currentPageURL: URL
}
