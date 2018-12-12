import Vapor

public protocol TagRepository {
    func getAllTags(on req: Request) -> Future<[BlogTag]>
}

public protocol BlogPostRepository {
    func getAllPosts(on req: Request) -> Future<[BlogPost]>
}

public protocol BlogUserRepository {
    func getUser(_ id: Int, on req: Request) -> Future<BlogUser?>
}