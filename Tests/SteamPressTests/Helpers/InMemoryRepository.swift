import Vapor
import SteamPress

class InMemoryRepository: BlogTagRepository, BlogPostRepository, BlogUserRepository, Service {

    private(set) var tags: [BlogTag]
    private(set) var posts: [BlogPost]
    private(set) var users: [BlogUser]
    private(set) var postTagLinks: [BlogPostTagLink]

    init() {
        tags = []
        posts = []
        users = []
        postTagLinks = []
    }

    // MARK: - BlogTagRepository

    func getAllTags(on container: Container) -> EventLoopFuture<[BlogTag]> {
        return container.future(tags)
    }

    func getAllTagsWithPostCount(on container: Container) -> EventLoopFuture<[(BlogTag, Int)]> {
        let tagsWithCount = tags.map { tag -> (BlogTag, Int) in
            let postCount = postTagLinks.filter { $0.tagID == tag.tagID }.count
            return (tag, postCount)
        }
        return container.future(tagsWithCount)
    }
    
    func getTagsForAllPosts(on container: Container) -> EventLoopFuture<[Int : [BlogTag]]> {
        var dict = [Int: [BlogTag]]()
        for tag in tags {
            postTagLinks.filter { $0.tagID == tag.tagID }.forEach { link in
                dict[link.postID]?.append(tag)
            }
        }
        return container.future(dict)
    }

    func getTags(for post: BlogPost, on container: Container) -> EventLoopFuture<[BlogTag]> {
        var results = [BlogTag]()
        guard let postID = post.blogID else {
            fatalError("Post doesn't exist when it should")
        }
        for link in postTagLinks where link.postID == postID {
            let foundTag = tags.first { $0.tagID == link.tagID }
            guard let tag =  foundTag else {
                fatalError("Tag doesn't exist when it should")
            }
            results.append(tag)
        }
        return container.future(results)
    }

    func save(_ tag: BlogTag, on container: Container) -> EventLoopFuture<BlogTag> {
        if tag.tagID == nil {
            tag.tagID = tags.count + 1
        }
        tags.append(tag)
        return container.future(tag)
    }

    func addTag(name: String) throws -> BlogTag {
        let newTag = BlogTag(id: tags.count + 1, name: name)
        tags.append(newTag)
        return newTag
    }

    func add(_ tag: BlogTag, to post: BlogPost, on container: Container) -> EventLoopFuture<Void> {
        do {
            try add(tag, to: post)
            return container.future()
        } catch {
            return container.future(error: SteamPressTestError(name: "Failed to add tag to post"))
        }
    }

    func add(_ tag: BlogTag, to post: BlogPost) throws {
        guard let postID = post.blogID else {
            fatalError("Blog doesn't exist when it should")
        }
        guard let tagID = tag.tagID else {
            fatalError("Tag ID hasn't been set")
        }
        let newLink = BlogPostTagLink(postID: postID, tagID: tagID)
        postTagLinks.append(newLink)
    }

    func addTag(name: String, for post: BlogPost) throws -> BlogTag {
        let newTag = try addTag(name: name)
        try add(newTag, to: post)
        return newTag
    }

    func getTag(_ name: String, on container: Container) -> EventLoopFuture<BlogTag?> {
        return container.future(tags.first { $0.name == name })
    }

    func addTag(_ tag: BlogTag, to post: BlogPost) {
        guard let postID = post.blogID else {
            fatalError("Blog doesn't exist when it should")
        }
        guard let tagID = tag.tagID else {
            fatalError("Tag ID hasn't been set")
        }
        let newLink = BlogPostTagLink(postID: postID, tagID: tagID)
        postTagLinks.append(newLink)
    }

    func deleteTags(for post: BlogPost, on container: Container) -> EventLoopFuture<Void> {
        return getTags(for: post, on: container).map { tags in
            for tag in tags {
                self.postTagLinks.removeAll { $0.tagID == tag.tagID! && $0.postID == post.blogID! }
            }
        }
    }

    func remove(_ tag: BlogTag, from post: BlogPost, on container: Container) -> EventLoopFuture<Void> {
        self.postTagLinks.removeAll { $0.tagID == tag.tagID! && $0.postID == post.blogID! }
        return container.future()
    }

    // MARK: - BlogPostRepository

    func getAllPostsSortedByPublishDate(includeDrafts: Bool, on container: Container) -> EventLoopFuture<[BlogPost]> {
        var sortedPosts = posts.sorted { $0.created > $1.created }
        if !includeDrafts {
            sortedPosts = sortedPosts.filter { $0.published }
        }
        return container.future(sortedPosts)
    }

    func getAllPostsSortedByPublishDate(includeDrafts: Bool, on container: Container, count: Int, offset: Int) -> EventLoopFuture<[BlogPost]> {
        var sortedPosts = posts.sorted { $0.created > $1.created }
        if !includeDrafts {
            sortedPosts = sortedPosts.filter { $0.published }
        }
        let startIndex = min(offset, sortedPosts.count)
        let endIndex = min(offset + count, sortedPosts.count)
        return container.future(Array(sortedPosts[startIndex..<endIndex]))
    }
    
    func getAllPostsCount(includeDrafts: Bool, on container: Container) -> EventLoopFuture<Int> {
        var sortedPosts = posts.sorted { $0.created > $1.created }
        if !includeDrafts {
            sortedPosts = sortedPosts.filter { $0.published }
        }
        return container.future(sortedPosts.count)
    }

    func getAllPostsSortedByPublishDate(for user: BlogUser, includeDrafts: Bool, on container: Container, count: Int, offset: Int) -> EventLoopFuture<[BlogPost]> {
        let authorsPosts = posts.filter { $0.author == user.userID }
        var sortedPosts = authorsPosts.sorted { $0.created > $1.created }
        if !includeDrafts {
            sortedPosts = sortedPosts.filter { $0.published }
        }
        let startIndex = min(offset, sortedPosts.count)
        let endIndex = min(offset + count, sortedPosts.count)
        return container.future(Array(sortedPosts[startIndex..<endIndex]))
    }

    func getPostCount(for user: BlogUser, on container: Container) -> EventLoopFuture<Int> {
        return container.future(posts.filter { $0.author == user.userID }.count)
    }

    func getPost(slug: String, on container: Container) -> EventLoopFuture<BlogPost?> {
        return container.future(posts.first { $0.slugUrl == slug })
    }

    func getPost(id: Int, on container: Container) -> EventLoopFuture<BlogPost?> {
        return container.future(posts.first { $0.blogID == id })
    }

    func getSortedPublishedPosts(for tag: BlogTag, on container: Container, count: Int, offset: Int) -> EventLoopFuture<[BlogPost]> {
        var results = [BlogPost]()
        guard let tagID = tag.tagID else {
            fatalError("Tag doesn't exist when it should")
        }
        for link in postTagLinks where link.tagID == tagID {
            let foundPost = posts.first { $0.blogID == link.postID }
            guard let post =  foundPost else {
                fatalError("Post doesn't exist when it should")
            }
            results.append(post)
        }
        let sortedPosts = results.sorted { $0.created > $1.created }.filter { $0.published }
        let startIndex = min(offset, sortedPosts.count)
        let endIndex = min(offset + count, sortedPosts.count)
        return container.future(Array(sortedPosts[startIndex..<endIndex]))
    }
    
    func getPublishedPostCount(for tag: BlogTag, on container: Container) -> EventLoopFuture<Int> {
        var results = [BlogPost]()
        guard let tagID = tag.tagID else {
            fatalError("Tag doesn't exist when it should")
        }
        for link in postTagLinks where link.tagID == tagID {
            let foundPost = posts.first { $0.blogID == link.postID }
            guard let post =  foundPost else {
                fatalError("Post doesn't exist when it should")
            }
            results.append(post)
        }
        let sortedPosts = results.sorted { $0.created > $1.created }.filter { $0.published }
        return container.future(sortedPosts.count)
    }
    
    func getPublishedPostCount(for searchTerm: String, on container: Container) -> EventLoopFuture<Int> {
        let titleResults = posts.filter { $0.title.contains(searchTerm) }
        let results = titleResults.sorted { $0.created > $1.created }.filter { $0.published }
        return container.future(results.count)
    }
    
    func findPublishedPostsOrdered(for searchTerm: String, on container: Container, count: Int, offset: Int) -> EventLoopFuture<[BlogPost]> {
        let titleResults = posts.filter { $0.title.contains(searchTerm) }
        let results = titleResults.sorted { $0.created > $1.created }.filter { $0.published }
        let startIndex = min(offset, results.count)
        let endIndex = min(offset + count, results.count)
        return container.future(Array(results[startIndex..<endIndex]))
    }

    func save(_ post: BlogPost, on container: Container) -> EventLoopFuture<BlogPost> {
        self.add(post)
        return container.future(post)
    }

    func add(_ post: BlogPost) {
        if (posts.first { $0.blogID == post.blogID } == nil) {
            post.blogID = posts.count + 1
            posts.append(post)
        }
    }

    func delete(_ post: BlogPost, on container: Container) -> EventLoopFuture<Void> {
        posts.removeAll { $0.blogID == post.blogID }
        return container.future()
    }

    // MARK: - BlogUserRepository

    func add(_ user: BlogUser) {
        if (users.first { $0.userID == user.userID } == nil) {
            if (users.first { $0.username == user.username} != nil) {
                fatalError("Duplicate users added with username \(user.username)")
            }
            user.userID = users.count + 1
            users.append(user)
        }
    }

    func getUser(id: Int, on container: Container) -> EventLoopFuture<BlogUser?> {
        return container.future(users.first { $0.userID == id })
    }

    func getAllUsers(on container: Container) -> EventLoopFuture<[BlogUser]> {
        return container.future(users)
    }

    func getAllUsersWithPostCount(on container: Container) -> EventLoopFuture<[(BlogUser, Int)]> {
        let usersWithCount = users.map { user -> (BlogUser, Int) in
            let postCount = posts.filter { $0.author == user.userID }.count
            return (user, postCount)
        }
        return container.future(usersWithCount)
    }

    func getUser(username: String, on container: Container) -> EventLoopFuture<BlogUser?> {
        return container.future(users.first { $0.username == username })
    }

    private(set) var userUpdated = false
    func save(_ user: BlogUser, on container: Container) -> EventLoopFuture<BlogUser> {
        self.add(user)
        userUpdated = true
        return container.future(user)
    }

    func delete(_ user: BlogUser, on container: Container) -> EventLoopFuture<Void> {
        users.removeAll { $0.userID == user.userID }
        return container.future()
    }

    func getUsersCount(on container: Container) -> EventLoopFuture<Int> {
        return container.future(users.count)
    }

}

struct BlogPostTagLink: Codable {
    let postID: Int
    let tagID: Int
}
