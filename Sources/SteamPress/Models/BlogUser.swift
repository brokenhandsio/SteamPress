import Vapor
import FluentProvider
import AuthProvider
import BCrypt
import Foundation

final class BlogUser: Model {
    
    let storage = Storage()
    
    var name: String
    var username: String
    var password: String
    var resetPasswordRequired: Bool = false
    var profilePicture: String?
    var twitterHandle: String?
    var biography: String?
    var tagline: String?
    
    init(name: String, username: String, password: String, profilePicture: String?, twitterHandle: String?, biography: String?, tagline: String?) {
        self.name = name
        self.username = username.lowercased()
        self.password = password
        self.profilePicture = profilePicture
        self.twitterHandle = twitterHandle
        self.biography = biography
        self.tagline = tagline
    }
    
    init(row: Row) throws {
        name = try row.get("name")
        username = try row.get("username")
        password = try row.get("password")
        resetPasswordRequired = try row.get("reset_password_required")
        profilePicture = try? row.get("profile_picture")
        twitterHandle = try? row.get("twitter_handle")
        biography = try? row.get("biography")
        tagline = try? row.get("tagline")
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set("name", name)
        try row.set("username", username)
        try row.set("password", password)
        try row.set("reset_password_required", resetPasswordRequired)
        try row.set("profile_picture", profilePicture)
        try row.set("twitter_handle", twitterHandle)
        try row.set("biography", biography)
        try row.set("tagline", tagline)
        return row
    }
    
}

extension BlogUser: NodeRepresentable {

    func makeNode(in context: Context?) throws -> Node {
        var userNode: [String: NodeRepresentable] = [:]
        userNode["id"] = try id.makeNode(in: context)
        userNode["name"] = name.makeNode(in: context)
        userNode["username"] = username.makeNode(in: context)
        userNode["reset_password_required"] = resetPasswordRequired.makeNode(in: context)
        
        if let profilePicture = profilePicture {
            userNode["profile_picture"] = profilePicture.makeNode(in: context)
        }
        
        if let twitterHandle = twitterHandle {
            userNode["twitter_handle"] = twitterHandle.makeNode(in: context)
        }
        
        if let biography = biography {
            userNode["biography"] = biography.makeNode(in: context)
        }
        
        if let tagline = tagline {
            userNode["tagline"] = tagline.makeNode(in: context)
        }
        
        guard let providedContext = context else {
            return try userNode.makeNode(in: context)
        }
        
        switch providedContext {
        case BlogUserContext.withPostCount:
            userNode["post_count"] = try sortedPosts().count().makeNode(in: context)
        default:
            break
        }
        
        return try userNode.makeNode(in: context)
    }
    
}

extension BlogUser: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) { users in
            users.id()
            users.string("name")
            users.string("username", unique: true)
            users.string("password")
            users.bool("reset_password_required")
            users.string("profile_picture", optional: true, default: nil)
            users.string("twitter_handle", optional: true, default: nil)
            users.custom("biography", type: "TEXT", optional: true, default: nil)
            users.string("tagline", optional: true, default: nil)
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }

}

public enum BlogUserContext: Context {
    case withPostCount
}

extension BlogUser: SessionPersistable {}

extension Request {
    func user() throws -> BlogUser {
        return try auth.assertAuthenticated()
    }
}

extension BlogUser: PasswordAuthenticatable {
    public static let usernameKey = "username"
    public static let passwordVerifier: BCryptHasher? = BCryptHasher(cost: 10)
}

extension BCryptHasher: PasswordVerifier {
    public func verify(password: String, matchesHash: String) throws -> Bool {
        return try check(password.bytes, matchesHash: matchesHash.bytes)
    }
}

extension BlogUser {
    var posts: Children<BlogUser, BlogPost> {
        return children()
    }
    
    func sortedPosts() throws -> Query<BlogPost> {
        return try posts.filter("published", true).sort("created", .descending)
    }
}

