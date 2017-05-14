import Fluent

// MARK: - BlogPost

extension BlogPost: Preparation {
    
    public static func prepare(_ database: Database) throws {
        try database.create(self) { posts in
            posts.id()
            posts.string("title")
            posts.custom("contents", type: "TEXT")
            posts.parent(BlogUser.self)
            posts.double("created")
            posts.double("last_edited", optional: true)
            posts.string("slug_url", unique: true)
        }
    }
    
    public static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

struct BlogPostDraft: Preparation {
    static func prepare(_ database: Database) throws {
        try database.modify(BlogPost.self) { blogPost in
            blogPost.bool("published", optional: false, default: true)
        }
    }
    
    static func revert(_ database: Database) throws {}
}

// MARK: - BlogUser

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

struct BlogUserExtraInformation: Preparation {
    static func prepare(_ database: Database) throws {
        try database.modify(BlogUser.self) { users in
            users.string("profile_picture", optional: true, default: nil)
        }
        try database.modify(BlogUser.self) { users in
            users.string("twitter_handle", optional: true, default: nil)
        }
        try database.modify(BlogUser.self) { users in
            users.custom("biography", type: "TEXT", optional: true, default: nil)
        }
        try database.modify(BlogUser.self) { users in
            users.string("tagline", optional: true, default: nil)
        }
    }
    
    static func revert(_ database: Database) throws {}
}

// MARK: - BlogTag

extension BlogTag: Preparation {
    
    static func prepare(_ database: Database) throws {
        try database.create(self) { tag in
            tag.id()
            tag.string("name", unique: true)
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

