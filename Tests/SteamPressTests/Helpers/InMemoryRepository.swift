import Vapor
import SteamPress

class InMemoryRepository: BlogTagRepository, BlogPostRepository, BlogUserRepository, Service {
    
    private(set) var tags: [BlogTag]
    private(set) var posts: [BlogPost]
    private(set) var users: [BlogUser]
    private var postTagLinks: [BlogPostTagLink]
    
    init() {
        tags = []
        posts = []
        users = []
        postTagLinks = []
    }
    
    // MARK: - BlogTagRepository
    
    func getAllTags(on req: Request) -> Future<[BlogTag]> {
        return req.future(tags)
    }
    
    func getTags(for post: BlogPost, on req: Request) -> EventLoopFuture<[BlogTag]> {
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
        return req.future(results)
    }
    
    func addTag(name: String) throws -> BlogTag {
        let newTag = try BlogTag(id: tags.count + 1, name: name)
        tags.append(newTag)
        return newTag
    }
    
    func addTag(name: String, for post: BlogPost) throws -> BlogTag{
        let newTag = try addTag(name: name)
        guard let postID = post.blogID else {
            fatalError("Blog doesn't exist when it should")
        }
        guard let tagID = newTag.tagID else {
            fatalError("Tag ID hasn't been set")
        }
        let newLink = BlogPostTagLink(postID: postID, tagID: tagID)
        postTagLinks.append(newLink)
        return newTag
    }
    
    func getTag(_ name: String, on req: Request) -> EventLoopFuture<BlogTag?> {
        return req.future(tags.first { $0.name == name })
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
    
    // MARK: - BlogPostRepository
    
    func getAllPosts(on req: Request) -> EventLoopFuture<[BlogPost]> {
        return req.future(posts)
    }
    
    func getAllPostsSortedByPublishDate(on req: Request, includeDrafts: Bool) -> EventLoopFuture<[BlogPost]> {
        var sortedPosts = posts.sorted { $0.created > $1.created }
        if !includeDrafts {
            sortedPosts = sortedPosts.filter { $0.published }
        }
        return req.future(sortedPosts)
    }
    
    func getAllPostsSortedByPublishDate(on req: Request, for user: BlogUser, includeDrafts: Bool) -> EventLoopFuture<[BlogPost]> {
        let authorsPosts = posts.filter { $0.author == user.userID }
        var sortedPosts = authorsPosts.sorted { $0.created > $1.created }
        if !includeDrafts {
            sortedPosts = sortedPosts.filter { $0.published }
        }
        return req.future(sortedPosts)
    }
    
    func getPost(on req: Request, slug: String) -> EventLoopFuture<BlogPost?> {
        return req.future(posts.first { $0.slugUrl == slug })
    }
    
    func getPost(on req: Request, id: Int) -> EventLoopFuture<BlogPost?> {
        return req.future(posts.first { $0.blogID == id })
    }
    
    func getSortedPublishedPosts(for tag: BlogTag, on req: Request) -> EventLoopFuture<[BlogPost]> {
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
        return req.future(sortedPosts)
    }
    
    func findPublishedPostsOrdered(for searchTerm: String, on req: Request) -> EventLoopFuture<[BlogPost]> {
        let titleResults = posts.filter { $0.title.contains(searchTerm) }
        let results = titleResults.sorted { $0.created > $1.created }.filter { $0.published }
        return req.future(results)
    }
    func savePost(_ post: BlogPost, on req: Request) -> EventLoopFuture<BlogPost> {
        self.addPost(post)
        return req.future(post)
    }
    
    func addPost(_ post: BlogPost) {
        if (posts.first { $0.blogID == post.blogID } == nil) {
            post.blogID = posts.count + 1
            posts.append(post)
        }
    }
    
    func deletePost(_ post: BlogPost, on req: Request) -> EventLoopFuture<Void> {
        posts.removeAll { $0.blogID == post.blogID }
        return req.future()
    }
    
    // MARK: - BlogUserRepository
    
    func addUser(_ user: BlogUser) {
        user.userID = users.count + 1
        users.append(user)
    }
    
    func getUser(_ id: Int, on req: Request) -> EventLoopFuture<BlogUser?> {
        return req.future(users.first { $0.userID == id })
    }
    
    func getUser(_ name: String, on req: Request) -> EventLoopFuture<BlogUser?> {
        return req.future(users.first { $0.name == name })
    }
    
    func getAllUsers(on req: Request) -> EventLoopFuture<[BlogUser]> {
        return req.future(users)
    }
    
    func getUser(username: String, on req: Request) -> EventLoopFuture<BlogUser?> {
        return req.future(users.first { $0.username == username })
    }
    
    func save(_ user: BlogUser, on req: Request) -> EventLoopFuture<BlogUser> {
        self.addUser(user)
        return req.future(user)
    }
    
}

private struct BlogPostTagLink: Codable {
    let postID: Int
    let tagID: Int
}
