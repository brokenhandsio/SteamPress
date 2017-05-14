import Vapor
import FluentProvider
import AuthProvider
import BCrypt
import Foundation

// MARK: - Model

final class BlogUser: Model {
    
    enum Properties: String {
        case id = "id"
        case name = "name"
        case username = "username"
        case password = "password"
        case resetPasswordRequired = "reset_password_required"
        case profilePicture = "profile_picture"
        case twitterHandle = "twitter_handle"
        case biography = "biography"
        case tagline = "tagline"
        case postCount = "post_count"
    }
    
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
        name = try row.get(Properties.name.rawValue)
        username = try row.get(Properties.username.rawValue)
        let passwordAsString: String = try row.get(Properties.password.rawValue)
        password = passwordAsString.makeBytes()
        resetPasswordRequired = try row.get(Properties.resetPasswordRequired.rawValue)
        profilePicture = try? row.get(Properties.profilePicture.rawValue)
        twitterHandle = try? row.get(Properties.twitterHandle.rawValue)
        biography = try? row.get(Properties.biography.rawValue)
        tagline = try? row.get(Properties.tagline.rawValue)
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set(Properties.name.rawValue, name)
        try row.set(Properties.username.rawValue, username)
        try row.set(Properties.password.rawValue, password.makeString())
        try row.set(Properties.resetPasswordRequired.rawValue, resetPasswordRequired)
        try row.set(Properties.profilePicture.rawValue, profilePicture)
        try row.set(Properties.twitterHandle.rawValue, twitterHandle)
        try row.set(Properties.biography.rawValue, biography)
        try row.set(Properties.tagline.rawValue, tagline)
        return row
    }
    
}

extension BlogUser: Parameterizable {
    static var uniqueSlug: String = "bloguser"
    
    static func make(for parameter: String) throws -> BlogUser {
        guard let blogUser = try BlogUser.makeQuery().filter(BlogUser.idKey, parameter).first() else {
            throw Abort.notFound
        }
        return blogUser
    }
}

// MARK: - Node

enum BlogUserContext: Context {
    case withPostCount
}

extension BlogUser: NodeRepresentable {

    func makeNode(in context: Context?) throws -> Node {
        var node = Node([:], in: context)
        try node.set(Properties.id.rawValue, id)
        try node.set(Properties.name.rawValue, name)
        try node.set(Properties.username.rawValue, username)
        try node.set(Properties.resetPasswordRequired.rawValue, resetPasswordRequired)
        
        if let profilePicture = profilePicture {
            try node.set(Properties.profilePicture.rawValue, profilePicture)
        }
        
        if let twitterHandle = twitterHandle {
            try node.set(Properties.twitterHandle.rawValue, twitterHandle)
        }
        
        if let biography = biography {
            try node.set(Properties.biography.rawValue, biography)
        }
        
        if let tagline = tagline {
            try node.set(Properties.tagline.rawValue, tagline)
        }
        
        guard let providedContext = context else {
            return node
        }
        
        switch providedContext {
        case BlogUserContext.withPostCount:
            try node.set(Properties.postCount.rawValue, try sortedPosts().count())
        default:
            break
        }
        
        return node
    }
    
}

// MARK: - Authentication

extension BlogUser: SessionPersistable {}

extension Request {
    func user() throws -> BlogUser {
        return try auth.assertAuthenticated()
    }
}

extension BlogUser: PasswordAuthenticatable {
    public static let usernameKey = Properties.username.rawValue
    public static let passwordVerifier: PasswordVerifier? = BCryptHasher(cost: 10)
    public var hashedPassword: String? {
        return password.makeString()
    }
}

// MARK: - Relations

extension BlogUser {
    var posts: Children<BlogUser, BlogPost> {
        return children()
    }
    
    func sortedPosts() throws -> Query<BlogPost> {
        return try posts.filter(BlogPost.Properties.published.rawValue, true).sort(BlogPost.Properties.created.rawValue, .descending)
    }
}

