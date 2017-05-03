import Fluent

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
    
    static func revert(_ database: Database) throws {
        
    }
}
