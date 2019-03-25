import SteamPress
import Foundation

extension TestWorld {
    func createPost(tags: [String]? = nil, createdDate: Date? = nil, title: String = "An Exciting Post!", contents: String = "This is a blog post", slugUrl: String = "an-exciting-post", author: BlogUser? = nil, published: Bool = true) throws -> TestData {
        return try TestDataBuilder.createPost(on: self.context.repository, tags: tags, createdDate: createdDate, title: title, contents:contents, slugUrl: slugUrl, author: author, published: published)
    }
    
    func createUser(username: String = "luke") -> BlogUser {
        let user = TestDataBuilder.anyUser(username: username)
        self.context.repository.addUser(user)
        return user
    }
    
    func createTag(_ name: String = "Engineering") throws -> BlogTag {
        return try self.context.repository.addTag(name: name)
    }
    
    func createTag(_ name: String = "Engineering", on post: BlogPost) throws -> BlogTag {
        return try self.context.repository.addTag(name: name, for: post)
    }
}
