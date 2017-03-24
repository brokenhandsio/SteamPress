import Fluent

struct BlogUserExtraInformation: Preparation {
    static func prepare(_ database: Database) throws {
        try database.modify(BlogPost.entity) { users in
            users.string("profile_picture", optional: true, default: nil)
            users.string("tagline", optional: true, default: nil)
            users.custom("biography", type: "TEXT", optional: true, default: nil)
            users.string("twitter_handle", optional: true, default: nil)
        }
    }
    
    static func revert(_ database: Database) throws {
        
    }
}
