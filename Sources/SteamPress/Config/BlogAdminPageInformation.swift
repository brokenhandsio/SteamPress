import Foundation

public struct BlogAdminPageInformation: Codable {
    let loggedInUser: BlogUser
    let websiteURL: URL
    let currentPageURL: URL
}

#warning("Test this gets set correctly in route handler")
