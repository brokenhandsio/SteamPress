import Vapor
import Fluent
import Auth
import BCrypt

final class BlogUser: Model {
    
    fileprivate static let databaseTableName = "blogusers"
    
    var id: Node?
    var exists: Bool = false
    var name: String
    var username: String
    var password: String
    var resetPasswordRequired: Bool = false
    
    init(name: String, username: String, password: String) {
        self.name = name
        self.username = username.lowercased()
        self.password = password
    }
    
    init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        name = try node.extract("name")
        username = try node.extract("username")
        password = try node.extract("password")
        resetPasswordRequired = try node.extract("reset_password_required")
    }
    
    func makeNode(context: Context) throws -> Node {
        var userNode = try Node(node: [
            "id": id,
            "name": name,
            "username": username,
            "reset_password_required": resetPasswordRequired,
            ])
        
        switch context {
        case is DatabaseContext:
            userNode["password"] = password.makeNode()
        case BlogUserContext.withPostCount:
            userNode["post_count"] = try posts().count.makeNode()
        default:
            break
        }
        
        return userNode
    }
    
    static func prepare(_ database: Database) throws {
        try database.create(databaseTableName) { users in
            users.id()
            users.string("name")
            users.string("username", unique: true)
            users.string("password")
            users.bool("reset_password_required")
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
        self.init(name: credentials.name ?? "", username: credentials.username, password: try BCrypt.digest(password: credentials.password))
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
    let name: String?
    let password: String
    
    public init(username: String, password: String, name: String? = nil) {
        self.username = username.lowercased()
        self.password = password
        self.name = name
    }
}

