//import Vapor
//import Fluent
////import AuthProvider
////import BCrypt
//import Foundation
//
//// MARK: - Model
//
//public final class BlogUser: Model {
//
//    public struct Properties {
//        public static let userID = "id"
//        public static let name = "name"
//        public static let username = "username"
//        public static let password = "password"
//        public static let resetPasswordRequired = "reset_password_required"
//        public static let profilePicture = "profile_picture"
//        public static let twitterHandle = "twitter_handle"
//        public static let biography = "biography"
//        public static let tagline = "tagline"
//        public static let postCount = "post_count"
//    }
//
//    public let storage = Storage()
//
//    public var name: String
//    public var username: String
//    var password: Bytes
//    var resetPasswordRequired: Bool = false
//    public var profilePicture: String?
//    public var twitterHandle: String?
//    public var biography: String?
//    public var tagline: String?
//
//    public init(name: String, username: String, password: Bytes, profilePicture: String?, twitterHandle: String?, biography: String?, tagline: String?) {
//        self.name = name
//        self.username = username.lowercased()
//        self.password = password
//        self.profilePicture = profilePicture
//        self.twitterHandle = twitterHandle
//        self.biography = biography
//        self.tagline = tagline
//    }
//
//    public init(row: Row) throws {
//        name = try row.get(Properties.name)
//        username = try row.get(Properties.username)
//        let passwordAsString: String = try row.get(Properties.password)
//        password = passwordAsString.makeBytes()
//        resetPasswordRequired = try row.get(Properties.resetPasswordRequired)
//        profilePicture = try? row.get(Properties.profilePicture)
//        twitterHandle = try? row.get(Properties.twitterHandle)
//        biography = try? row.get(Properties.biography)
//        tagline = try? row.get(Properties.tagline)
//    }
//
//    public func makeRow() throws -> Row {
//        var row = Row()
//        try row.set(Properties.name, name)
//        try row.set(Properties.username, username)
//        try row.set(Properties.password, password.makeString())
//        try row.set(Properties.resetPasswordRequired, resetPasswordRequired)
//        try row.set(Properties.profilePicture, profilePicture)
//        try row.set(Properties.twitterHandle, twitterHandle)
//        try row.set(Properties.biography, biography)
//        try row.set(Properties.tagline, tagline)
//        return row
//    }
//
//}
//
//extension BlogUser: Parameterizable {}
//
//// MARK: - Node
//
//public enum BlogUserContext: Context {
//    case withPostCount
//}
//
//extension BlogUser: NodeRepresentable {
//
//    public func makeNode(in context: Context?) throws -> Node {
//        var node = Node([:], in: context)
//        try node.set(Properties.userID, id)
//        try node.set(Properties.name, name)
//        try node.set(Properties.username, username)
//        try node.set(Properties.resetPasswordRequired, resetPasswordRequired)
//
//        if let profilePicture = profilePicture {
//            try node.set(Properties.profilePicture, profilePicture)
//        }
//
//        if let twitterHandle = twitterHandle {
//            try node.set(Properties.twitterHandle, twitterHandle)
//        }
//
//        if let biography = biography {
//            try node.set(Properties.biography, biography)
//        }
//
//        if let tagline = tagline {
//            try node.set(Properties.tagline, tagline)
//        }
//
//        guard let providedContext = context else {
//            return node
//        }
//
//        switch providedContext {
//        case BlogUserContext.withPostCount:
//            try node.set(Properties.postCount, try sortedPosts().count())
//        default:
//            break
//        }
//
//        return node
//    }
//
//}
//
//// MARK: - Authentication
//
//extension BlogUser: SessionPersistable {}
//
//extension Request {
//    func user() throws -> BlogUser {
//        return try auth.assertAuthenticated()
//    }
//}
//
//extension BlogUser: PasswordAuthenticatable {
//    public static let usernameKey = Properties.username
//    public static let passwordVerifier: PasswordVerifier? = BlogUser.passwordHasher
//    public var hashedPassword: String? {
//        return password.makeString()
//    }
//    internal(set) static var passwordHasher: PasswordHasherVerifier = BCryptHasher(cost: 10)
//}
//
//protocol PasswordHasherVerifier: PasswordVerifier, HashProtocol {}
//
//extension BCryptHasher: PasswordHasherVerifier {}
//
//// MARK: - Relations
//
//extension BlogUser {
//    public var posts: Children<BlogUser, BlogPost> {
//        return children()
//    }
//
//    public func sortedPosts() throws -> Query<BlogPost> {
//        return try posts.filter(BlogPost.Properties.published, true).sort(BlogPost.Properties.created, .descending)
//    }
//}

