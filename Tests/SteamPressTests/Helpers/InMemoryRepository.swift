import Vapor
import SteamPress

class InMemoryRepository: BlogTagRepository, BlogPostRepository, BlogUserRepository, Service {
    
    private var tags: [BlogTag]
    private var posts: [BlogPost]
    private var users: [BlogUser]
    private var postTagLinks: [BlogPostTagLink]
    
    init() {
        tags = []
        posts = []
        users = []
        postTagLinks = []
    }
    
    func getAllTags(on req: Request) -> Future<[BlogTag]> {
        return req.future(tags)
    }
    
    func getTagsFor(post: BlogPost, on req: Request) -> EventLoopFuture<[BlogTag]> {
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
    
    func addTag(name: String) throws {
        let newTag = try BlogTag(id: tags.count + 1, name: name)
        tags.append(newTag)
    }
    
    func addTag(name: String, for post: BlogPost) throws {
        try addTag(name: name)
        guard let postID = post.blogID else {
            fatalError("Blog doesn't exist when it should")
        }
        let newLink = BlogPostTagLink(postID: postID, tagID: tags.count)
        postTagLinks.append(newLink)
    }
    
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
    
    func addPost(_ post: BlogPost) {
        post.blogID = posts.count + 1
        posts.append(post)
    }
    
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
    
}

private struct BlogPostTagLink: Codable {
    let postID: Int
    let tagID: Int
}
