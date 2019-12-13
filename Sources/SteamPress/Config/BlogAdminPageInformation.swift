import Foundation

public struct BlogAdminPageInformation: Codable {
    public let loggedInUser: BlogUser
    public let websiteURL: URL
    public let currentPageURL: URL
}
