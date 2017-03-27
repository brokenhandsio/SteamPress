import Vapor
import Fluent
import Auth
import BCrypt
import Foundation

final class BlogUser: Model {
    
    fileprivate static let databaseTableName = "blogusers"
    
    var id: Node?
    var exists: Bool = false
    var name: String
    var username: String
    var password: String
    var resetPasswordRequired: Bool = false
    var profilePicture: URL?
    var twitterHandle: String?
    var biography: String?
    var tagline: String?
    
    init(name: String, username: String, password: String, profilePicture: URL?, twitterHandle: String?, biography: String?, tagline: String?) {
        self.name = name
        self.username = username.lowercased()
        self.password = password
        self.profilePicture = profilePicture
        self.twitterHandle = twitterHandle
        self.biography = biography
        self.tagline = tagline
    }
    
    init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        name = try node.extract("name")
        username = try node.extract("username")
        password = try node.extract("password")
        resetPasswordRequired = try node.extract("reset_password_required")
        let rawProfilePictureString: String? = try? node.extract("profile_picture")
        if let profilePictureString = rawProfilePictureString {
            guard let profilePictureURL = URL(string: profilePictureString) else {
                throw Abort.custom(status: .internalServerError, message: "Profile Picture was not a valid string")
            }
            profilePicture = profilePictureURL
        }
        twitterHandle = try? node.extract("twitter_handle")
        biography = try? node.extract("biography")
        tagline = try? node.extract("tagline")
    }
    
    func makeNode(context: Context) throws -> Node {
        var userNode: [String: NodeRepresentable] = [:]
        userNode["id"] = id
        userNode["name"] = name.makeNode()
        userNode["username"] = username.makeNode()
        userNode["reset_password_required"] = resetPasswordRequired.makeNode()
        
        if let profilePicture = profilePicture {
            userNode["profile_picture"] = profilePicture.description.makeNode()
        }
        
        if let twitterHandle = twitterHandle {
            userNode["twitter_handle"] = twitterHandle.makeNode()
        }
        
        if let biography = biography {
            userNode["biography"] = biography.makeNode()
        }
        
        if let tagline = tagline {
            userNode["tagline"] = tagline.makeNode()
        }
        
        switch context {
        case is DatabaseContext:
            userNode["password"] = password.makeNode()
        case BlogUserContext.withPostCount:
            userNode["post_count"] = try posts().count.makeNode()
        default:
            break
        }
        
        return try userNode.makeNode()
    }
    
    static func prepare(_ database: Database) throws {
        try database.create(databaseTableName) { users in
            users.id()
            users.string("name")
            users.string("username", unique: true)
            users.string("password")
            users.bool("reset_password_required")
            users.string("profile_picture", optional: true)
            users.string("twitter_handle", optional: true)
            users.custom("biography", type: "TEXT", optional: true)
            users.string("tagline", optional: true)
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(databaseTableName)
    }
}

public enum BlogUserContext: Context {
    case withPostCount
}

extension BlogUser: Auth.User {
    
    convenience init(credentials: BlogUserCredentials) throws {
        self.init(name: credentials.name ?? "", username: credentials.username, password: try BCrypt.digest(password: credentials.password), profilePicture: credentials.profilePicture, twitterHandle: credentials.twitterHandle, biography: credentials.biography, tagline: credentials.tagline)
    }
    
    static func register(credentials: Credentials) throws -> Auth.User {
        guard let usernamePassword = credentials as? BlogUserCredentials else {
            throw Abort.custom(status: .forbidden, message: "Unsupported credentials type \(type(of: credentials))")
        }
        
        let user = try BlogUser(credentials: usernamePassword)
        return user
    }
    
    static func authenticate(credentials: Credentials) throws -> Auth.User {
        switch credentials {
        case let usernamePassword as BlogUserCredentials:
            guard let user = try BlogUser.query().filter("username", usernamePassword.username).first() else {
                throw Abort.custom(status: .networkAuthenticationRequired, message: "Invalid username or password")
            }
            if try BCrypt.verify(password: usernamePassword.password, matchesHash: user.password) {
                return user
            }
            else {
                throw Abort.custom(status: .networkAuthenticationRequired, message: "Invalid username or password")
            }
        case let id as Identifier:
            guard let user = try BlogUser.find(id.id) else {
                throw Abort.custom(status: .forbidden, message: "Invalid user identifier")
            }
            return user
        default:
            throw Abort.custom(status: .forbidden, message: "Unsupported credentials type \(type(of: credentials))")
        }
    }
}

extension BlogUser {
    func posts() throws -> [BlogPost] {
        return try children("bloguser_id", BlogPost.self).sort("created", .descending).filter("published", true).all()
    }
}

struct BlogUserCredentials: Credentials {
    
    let username: String
    let password: String
    let name: String?
    let profilePicture: URL?
    let twitterHandle: String?
    let biography: String?
    let tagline: String?
    
    public init(username: String, password: String, name: String?, profilePicture: URL?, twitterHandle: String?, biography: String?, tagline: String?) {
        self.username = username.lowercased()
        self.password = password
        self.name = name
        self.profilePicture = profilePicture
        self.twitterHandle = twitterHandle
        self.biography = biography
        self.tagline = tagline
    }
}

