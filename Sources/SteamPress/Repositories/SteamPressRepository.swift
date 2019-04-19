import Vapor

public protocol BlogTagRepository {
    func getAllTags(on req: Request) -> Future<[BlogTag]>
    func getTags(for post: BlogPost, on req: Request) -> Future<[BlogTag]>
    func getTag(_ name: String, on req: Request) -> Future<BlogTag?>
}

public protocol BlogPostRepository {
    #warning("On request should be last parameter for everything")
    func getAllPosts(on req: Request) -> Future<[BlogPost]>
    func getAllPostsSortedByPublishDate(on req: Request, includeDrafts: Bool) -> Future<[BlogPost]>
    func getAllPostsSortedByPublishDate(on req: Request, for user: BlogUser, includeDrafts: Bool) -> Future<[BlogPost]>
    func getPost(on req: Request, slug: String) -> Future<BlogPost?>
    func getPost(on req: Request, id: Int) -> Future<BlogPost?>
    func getSortedPublishedPosts(for tag: BlogTag, on req: Request) -> Future<[BlogPost]>
    func findPublishedPostsOrdered(for searchTerm: String, on req: Request) -> Future<[BlogPost]>
    #warning("rename to save(_ post)")
    func savePost(_ post: BlogPost, on req: Request) -> Future<BlogPost>
    func deletePost(_ post: BlogPost, on req: Request) -> Future<Void>
}

public protocol BlogUserRepository {
    func getAllUsers(on req: Request) -> Future<[BlogUser]>
    func getUser(_ id: Int, on req: Request) -> Future<BlogUser?>
    func getUser(_ name: String, on req: Request) -> Future<BlogUser?>
    func getUser(username: String, on req: Request) -> Future<BlogUser?>
    func save(_ user: BlogUser, on req: Request) -> Future<BlogUser>
    func delete(_ user: BlogUser, on req: Request) -> Future<Void>
    func getUsersCount(on req: Request) -> Future<Int>
}
