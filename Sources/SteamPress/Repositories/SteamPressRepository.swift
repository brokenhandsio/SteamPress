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
    func getAllUsers(on container: Container) -> Future<[BlogUser]>
    func getUser(_ id: Int, on container: Container) -> Future<BlogUser?>
    func getUser(_ name: String, on container: Container) -> Future<BlogUser?>
    func getUser(username: String, on container: Container) -> Future<BlogUser?>
    func save(_ user: BlogUser, on container: Container) -> Future<BlogUser>
    func delete(_ user: BlogUser, on container: Container) -> Future<Void>
    func getUsersCount(on container: Container) -> Future<Int>
}

extension BlogUser: Parameter {
    public typealias ResolvedParameter = EventLoopFuture<BlogUser>
    
    public static func resolveParameter(_ parameter: String, on container: Container) throws -> BlogUser.ResolvedParameter {
        let userRepository = try container.make(BlogUserRepository.self)
        guard let userID = Int(parameter) else {
            throw SteamPressError(identifier: "Invalid-ID-Type", "Unable to convert \(parameter) to an Int")
        }
        return userRepository.getUser(userID, on: container).unwrap(or: Abort(.notFound))
    }
}
