import Vapor

public protocol BlogTagRepository {
    func getAllTags(on req: Request) -> Future<[BlogTag]>
    func getTags(for post: BlogPost, on req: Request) -> Future<[BlogTag]>
    func getTag(_ name: String, on req: Request) -> Future<BlogTag?>
}

public protocol BlogPostRepository {
    func getAllPosts(on req: Request) -> Future<[BlogPost]>
    func getAllPostsSortedByPublishDate(on req: Request, includeDrafts: Bool) -> Future<[BlogPost]>
    func getAllPostsSortedByPublishDate(on req: Request, for user: BlogUser, includeDrafts: Bool) -> Future<[BlogPost]>
    func getPost(on req: Request, slug: String) -> Future<BlogPost?>
    func getSortedPublishedPosts(for tag: BlogTag, on req: Request) -> Future<[BlogPost]>
}

public protocol BlogUserRepository {
    func getAllUsers(on req: Request) -> Future<[BlogUser]>
    func getUser(_ id: Int, on req: Request) -> Future<BlogUser?>
    func getUser(_ name: String, on req: Request) -> Future<BlogUser?>
}
