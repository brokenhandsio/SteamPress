import Vapor

public protocol BlogTagRepository {
    func getAllTags(on container: Container) -> Future<[BlogTag]>
    func getTags(for post: BlogPost, on container: Container) -> Future<[BlogTag]>
    func getTag(_ name: String, on container: Container) -> Future<BlogTag?>
}

public protocol BlogPostRepository {
    func getAllPosts(on container: Container) -> Future<[BlogPost]>
    func getAllPostsSortedByPublishDate(includeDrafts: Bool, on container: Container) -> Future<[BlogPost]>
    func getAllPostsSortedByPublishDate(for user: BlogUser, includeDrafts: Bool, on container: Container) -> Future<[BlogPost]>
    func getPost(slug: String, on container: Container) -> Future<BlogPost?>
    func getPost(id: Int, on container: Container) -> Future<BlogPost?>
    func getSortedPublishedPosts(for tag: BlogTag, on container: Container) -> Future<[BlogPost]>
    func findPublishedPostsOrdered(for searchTerm: String, on container: Container) -> Future<[BlogPost]>
    func save(_ post: BlogPost, on container: Container) -> Future<BlogPost>
    func delete(_ post: BlogPost, on container: Container) -> Future<Void>
}

public protocol BlogUserRepository {
    func getAllUsers(on container: Container) -> Future<[BlogUser]>
    func getUser(id: Int, on container: Container) -> Future<BlogUser?>
    func getUser(name: String, on container: Container) -> Future<BlogUser?>
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
            throw SteamPressError(identifier: "Invalid-ID-Type", "Unable to convert \(parameter) to a User ID")
        }
        return userRepository.getUser(id: userID, on: container).unwrap(or: Abort(.notFound))
    }
}

extension BlogPost: Parameter {
    public typealias ResolvedParameter = EventLoopFuture<BlogPost>
    public static func resolveParameter(_ parameter: String, on container: Container) throws -> EventLoopFuture<BlogPost> {
        let postRepository = try container.make(BlogPostRepository.self)
        guard let postID = Int(parameter) else {
            throw SteamPressError(identifier: "Invalid-ID-Type", "Unable to convert \(parameter) to a Post ID")
        }
        return postRepository.getPost(id: postID, on: container).unwrap(or: Abort(.notFound))
    }
}
