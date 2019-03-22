import SteamPress
import Foundation

extension TestWorld {
    func createPost(tags: [String]? = nil, createdDate: Date? = nil, title: String = "An Exciting Post!", contents: String = "This is a blog post", slugUrl: String = "an-exciting-post", author: BlogUser? = nil, published: Bool = true) throws -> TestData {
        return try TestDataBuilder.createPost(on: self.context.repository, tags: tags, createdDate: createdDate, title: title, contents:contents, slugUrl: slugUrl, author: author, published: published)
    }
    
    func createUser() -> BlogUser {
        let user = TestDataBuilder.anyUser()
        self.context.repository.addUser(user)
        return user
    }
}
