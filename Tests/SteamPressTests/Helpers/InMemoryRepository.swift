import Vapor
import SteamPress

class InMemoryRepository: TagRepository, BlogPostRepository, BlogUserRepository, Service {
    
    private var tags: [BlogTag]
    private var posts: [BlogPost]
    private var users: [BlogUser]
    
    init() {
        tags = []
        posts = []
        users = []
    }
    
    func getAllTags(on req: Request) -> Future<[BlogTag]> {
        return req.future(tags)
    }
    
    func addTag(name: String) {
        let newTag = BlogTag(id: tags.count + 1, name: name)
        tags.append(newTag)
    }
    
    func getAllPosts(on req: Request) -> EventLoopFuture<[BlogPost]> {
        return req.future(posts)
    }
    
    func getAllPostsSortedByPublishDate(on req: Request) -> EventLoopFuture<[BlogPost]> {
        let sortedPosts = posts.sorted { $0.created > $1.created }
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
    
}
