import Fluent

// MARK: - BlogPost

extension BlogPost: Preparation {
    
    public static func prepare(_ database: Database) throws {
        try database.create(self) { posts in
            posts.id()
            posts.string(Properties.title.rawValue)
            posts.custom(Properties.contents.rawValue, type: "TEXT")
            posts.parent(BlogUser.self)
            posts.double(Properties.created.rawValue)
            posts.double(Properties.lastEdited.rawValue, optional: true)
            posts.string(Properties.slugUrl.rawValue, unique: true)
        }
    }
    
    public static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

struct BlogPostDraft: Preparation {
    static func prepare(_ database: Database) throws {
        try database.modify(BlogPost.self) { blogPost in
            blogPost.bool(BlogPost.Properties.published.rawValue, optional: false, default: true)
        }
    }
    
    static func revert(_ database: Database) throws {}
}

// MARK: - BlogUser

extension BlogUser: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) { users in
            users.id()
            users.string(Properties.name.rawValue)
            users.string(Properties.username.rawValue, unique: true)
            users.string(Properties.password.rawValue)
            users.bool(Properties.resetPasswordRequired.rawValue)
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
    
}

struct BlogUserExtraInformation: Preparation {
    static func prepare(_ database: Database) throws {
        try database.modify(BlogUser.self) { users in
            users.string(BlogUser.Properties.profilePicture.rawValue, optional: true, default: nil)
        }
        try database.modify(BlogUser.self) { users in
            users.string(BlogUser.Properties.twitterHandle.rawValue, optional: true, default: nil)
        }
        try database.modify(BlogUser.self) { users in
            users.custom(BlogUser.Properties.biography.rawValue, type: "TEXT", optional: true, default: nil)
        }
        try database.modify(BlogUser.self) { users in
            users.string(BlogUser.Properties.tagline.rawValue, optional: true, default: nil)
        }
    }
    
    static func revert(_ database: Database) throws {}
}

// MARK: - BlogTag

extension BlogTag: Preparation {
    
    static func prepare(_ database: Database) throws {
        try database.create(self) { tag in
            tag.id()
            tag.string(Properties.name.rawValue, unique: true)
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

