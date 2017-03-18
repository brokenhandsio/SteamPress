import Fluent

struct BlogPostDraft: Preparation {
    static func prepare(_ database: Database) throws {
        try database.modify(BlogPost.entity, closure: { blogPost in
            blogPost.bool("published", optional: false, default: true)
        })
    }
    
    static func revert(_ database: Database) throws {
        
    }
}
