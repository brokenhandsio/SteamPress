import SteamPress
import Foundation

extension TestWorld {
    func createPost(tags: [String]? = nil, createdDate: Date? = nil, title: String = "An Exciting Post!", contents: String = "This is a blog post", slugUrl: String = "an-exciting-post", author: BlogUser? = nil, published: Bool = true) throws -> TestData {
        return try TestDataBuilder.createPost(on: self.context.repository, tags: tags, createdDate: createdDate, title: title, contents:contents, slugUrl: slugUrl, author: author, published: published)
    }
    
    func createPosts(count: Int, author: BlogUser) throws {
        for index in 1...count {
            _ = try createPost(title: "Post \(index)", slugUrl: "post-\(index)", author: author)
        }
    }
    
    func createUser(name: String = "Luke", username: String = "luke", password: String = "password", resetPasswordRequired: Bool = false) -> BlogUser {
        let user = TestDataBuilder.anyUser(name: name, username: username, password: password)
        self.context.repository.add(user)
        if resetPasswordRequired {
            user.resetPasswordRequired = true
        }
        return user
    }
    
    func createTag(_ name: String = "Engineering") throws -> BlogTag {
        return try self.context.repository.addTag(name: name)
    }
    
    func createTag(_ name: String = "Engineering", on post: BlogPost) throws -> BlogTag {
        return try self.context.repository.addTag(name: name, for: post)
    }
}
