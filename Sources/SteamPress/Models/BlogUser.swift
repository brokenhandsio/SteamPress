import Vapor
import FluentProvider
import AuthProvider
import BCrypt
import Foundation

final class BlogUser: Model {
    
    let storage = Storage()
    
    var name: String
    var username: String
    var password: Bytes
    var resetPasswordRequired: Bool = false
    var profilePicture: String?
    var twitterHandle: String?
    var biography: String?
    var tagline: String?
    
    init(name: String, username: String, password: Bytes, profilePicture: String?, twitterHandle: String?, biography: String?, tagline: String?) {
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
        let passwordAsString: String = try row.get("password")
        password = passwordAsString.makeBytes()
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
        try row.set("password", password.makeString())
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
        var node = Node([:], in: context)
        try node.set("id", id)
        try node.set("name", name)
        try node.set("username", username)
        try node.set("reset_password_required", resetPasswordRequired)
        
        if let profilePicture = profilePicture {
            try node.set("profile_picture", profilePicture)
        }
        
        if let twitterHandle = twitterHandle {
            try node.set("twitter_handle", twitterHandle)
        }
        
        if let biography = biography {
            try node.set("biography", biography)
        }
        
        if let tagline = tagline {
            try node.set("tagline", tagline)
        }
        
        guard let providedContext = context else {
            return node
        }
        
        switch providedContext {
        case BlogUserContext.withPostCount:
            try node.set("post_count", try sortedPosts().count())
        default:
            break
        }
        
        return node
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
    public static let passwordVerifier: PasswordVerifier? = BCryptHasher(cost: 10)
    public var hashedPassword: String? {
        return password.makeString()
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

