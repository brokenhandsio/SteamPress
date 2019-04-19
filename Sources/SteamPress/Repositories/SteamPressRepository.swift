import Vapor

public protocol BlogTagRepository {
    func getAllTags(on req: Request) -> Future<[BlogTag]>
    func getTags(for post: BlogPost, on req: Request) -> Future<[BlogTag]>
    func getTag(_ name: String, on req: Request) -> Future<BlogTag?>
}

public protocol BlogPostRepository {
    func getAllPosts(on req: Request) -> Future<[BlogPost]>
    func getAllPostsSortedByPublishDate(includeDrafts: Bool, on req: Request) -> Future<[BlogPost]>
    func getAllPostsSortedByPublishDate(for user: BlogUser, includeDrafts: Bool, on req: Request) -> Future<[BlogPost]>
    func getPost(slug: String, on req: Request) -> Future<BlogPost?>
    func getPost(id: Int, on req: Request) -> Future<BlogPost?>
    func getSortedPublishedPosts(for tag: BlogTag, on req: Request) -> Future<[BlogPost]>
    func findPublishedPostsOrdered(for searchTerm: String, on req: Request) -> Future<[BlogPost]>
    func save(_ post: BlogPost, on req: Request) -> Future<BlogPost>
    func delete(_ post: BlogPost, on req: Request) -> Future<Void>
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
