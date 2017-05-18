import Fluent

// MARK: - BlogPost

extension BlogPost: Preparation {
    
    public static func prepare(_ database: Database) throws {
        try database.create(self) { posts in
            posts.id()
            posts.string(Properties.title)
            posts.custom(Properties.contents, type: "TEXT")
            posts.parent(BlogUser.self)
            posts.double(Properties.created)
            posts.double(Properties.lastEdited, optional: true)
            posts.string(Properties.slugUrl, unique: true)
        }
    }
    
    public static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

struct BlogPostDraft: Preparation {
    static func prepare(_ database: Database) throws {
        try database.modify(BlogPost.self) { blogPost in
            blogPost.bool(BlogPost.Properties.published, optional: false, default: true)
        }
    }
    
    static func revert(_ database: Database) throws {}
}

// MARK: - BlogUser

extension BlogUser: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) { users in
            users.id()
            users.string(Properties.name)
            users.string(Properties.username, unique: true)
            users.string(Properties.password)
            users.bool(Properties.resetPasswordRequired)
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
    
}

struct BlogUserExtraInformation: Preparation {
    static func prepare(_ database: Database) throws {
        try database.modify(BlogUser.self) { users in
            users.string(BlogUser.Properties.profilePicture, optional: true, default: nil)
        }
        try database.modify(BlogUser.self) { users in
            users.string(BlogUser.Properties.twitterHandle, optional: true, default: nil)
        }
        try database.modify(BlogUser.self) { users in
            users.custom(BlogUser.Properties.biography, type: "TEXT", optional: true, default: nil)
        }
        try database.modify(BlogUser.self) { users in
            users.string(BlogUser.Properties.tagline, optional: true, default: nil)
        }
    }
    
    static func revert(_ database: Database) throws {}
}

// MARK: - BlogTag

extension BlogTag: Preparation {
    
    static func prepare(_ database: Database) throws {
        try database.create(self) { tag in
            tag.id()
            tag.string(Properties.name, unique: true)
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

