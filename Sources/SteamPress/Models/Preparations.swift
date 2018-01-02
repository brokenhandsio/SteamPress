//import Fluent
//import Vapor
//
//// MARK: - BlogPost
//
//extension BlogPost: Preparation {
//
//    public static func prepare(_ database: Database) throws {
//        try database.create(self) { posts in
//            posts.id()
//            posts.string(Properties.title)
//            posts.custom(Properties.contents, type: "TEXT")
//            posts.parent(BlogUser.self)
//            posts.double(Properties.created)
//            posts.double(Properties.lastEdited, optional: true)
//            posts.string(Properties.slugUrl, unique: true)
//        }
//    }
//
//    public static func revert(_ database: Database) throws {
//        try database.delete(self)
//    }
//}
//
//struct BlogPostDraft: Preparation {
//    static func prepare(_ database: Database) throws {
//        try database.modify(BlogPost.self) { blogPost in
//            blogPost.bool(BlogPost.Properties.published, optional: false, default: true)
//        }
//    }
//
//    static func revert(_ database: Database) throws {}
//}
//
//// MARK: - BlogUser
//
//extension BlogUser: Preparation {
//    public static func prepare(_ database: Database) throws {
//        try database.create(self) { users in
//            users.id()
//            users.string(Properties.name)
//            users.string(Properties.username, unique: true)
//            users.string(Properties.password)
//            users.bool(Properties.resetPasswordRequired)
//        }
//    }
//
//    public static func revert(_ database: Database) throws {
//        try database.delete(self)
//    }
//
//}
//
//struct BlogUserExtraInformation: Preparation {
//    static func prepare(_ database: Database) throws {
//        try database.modify(BlogUser.self) { users in
//            users.string(BlogUser.Properties.profilePicture, optional: true, default: nil)
//        }
//        try database.modify(BlogUser.self) { users in
//            users.string(BlogUser.Properties.twitterHandle, optional: true, default: nil)
//        }
//        try database.modify(BlogUser.self) { users in
//            users.custom(BlogUser.Properties.biography, type: "TEXT", optional: true, default: nil)
//        }
//        try database.modify(BlogUser.self) { users in
//            users.string(BlogUser.Properties.tagline, optional: true, default: nil)
//        }
//    }
//
//    static func revert(_ database: Database) throws {}
//}
//
//struct BlogAdminUser: Preparation {
//
//    static var log: LogProtocol?
//
//    static func prepare(_ database: Database) throws {
//        do {
//            let password = String.random()
//
//            let hashedPassword = try BlogUser.passwordHasher.make(password)
//            let user = BlogUser(name: "Admin", username: "admin", password: hashedPassword, profilePicture: nil,
//                                twitterHandle: nil, biography: nil, tagline: "Admin for the blog")
//            user.resetPasswordRequired = true
//            try user.save()
//
//            log?.error("An Admin user been created for you - the username is admin and the password is \(password)")
//            log?.error("You will be asked to change your password once you have logged in, please do this immediately!")
//        } catch {
//            log?.error("There was an error creating a new admin user: \(error)")
//        }
//    }
//
//    static func revert(_ database: Database) throws {}
//}
//
//// MARK: - BlogTag
//
//extension BlogTag: Preparation {
//
//    public static func prepare(_ database: Database) throws {
//        try database.create(self) { tag in
//            tag.id()
//            tag.string(Properties.name, unique: true)
//        }
//    }
//
//    public static func revert(_ database: Database) throws {
//        try database.delete(self)
//    }
//}
//
//// MARK: - Blog Indexes
//
//struct BlogIndexes: Preparation {
//    static func prepare(_ database: Database) throws {
//        try database.index(BlogTag.Properties.name, for: BlogTag.self)
//        try database.index(BlogUser.Properties.username, for: BlogUser.self)
//        try database.index(BlogPost.Properties.slugUrl, for: BlogPost.self)
//    }
//    
//    static func revert(_ database: Database) throws {
//        try database.deleteIndex(BlogPost.Properties.slugUrl, for: BlogPost.self)
//        try database.deleteIndex(BlogUser.Properties.username, for: BlogUser.self)
//        try database.deleteIndex(BlogTag.Properties.name, for: BlogTag.self)
//    }
//}

