import Vapor
import Authentication

// MARK: - Model

public final class BlogUser: Codable {

    public var userID: Int?
    public var name: String
    public var username: String
    var password: String
    public var resetPasswordRequired: Bool = false
    public var profilePicture: String?
    public var twitterHandle: String?
    public var biography: String?
    public var tagline: String?

    public init(userID: Int? = nil, name: String, username: String, password: String, profilePicture: String?, twitterHandle: String?, biography: String?, tagline: String?) {
        self.userID = userID
        self.name = name
        self.username = username.lowercased()
        self.password = password
        self.profilePicture = profilePicture
        self.twitterHandle = twitterHandle
        self.biography = biography
        self.tagline = tagline
    }

}

// MARK: - Authentication

extension BlogUser: Authenticatable {
    func authenticateSession(on req: Request) throws {
        try req.session()["_BlogUserSession"] = self.userID?.description
        try req.authenticate(self)
    }
}

extension Request {
    func unauthenticateBlogUserSession() throws {
        guard try self.hasSession() else {
            return
        }
        try session()["_BlogUserSession"] = nil
        try unauthenticate(BlogUser.self)
    }
}
