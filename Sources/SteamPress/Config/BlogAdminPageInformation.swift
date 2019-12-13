import Foundation

public struct BlogAdminPageInformation: Codable {
    public let loggedInUser: BlogUser
    public let websiteURL: URL
    public let currentPageURL: URL
}

#warning("Test this gets set correctly in route handler")
