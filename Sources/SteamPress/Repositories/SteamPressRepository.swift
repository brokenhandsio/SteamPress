import Vapor

public protocol SteamPressRepository {
//    associatedtype ModelType
//    func get(_ id: Int, on eventLoop: EventLoop) -> EventLoopFuture<ModelType>
}

public protocol BlogTagRepository: SteamPressRepository {
    func getAllTags() -> EventLoopFuture<[BlogTag]>
    func getAllTagsWithPostCount() -> EventLoopFuture<[(BlogTag, Int)]>
    func getTags(for post: BlogPost) -> EventLoopFuture<[BlogTag]>
    func getTagsForAllPosts() -> EventLoopFuture<[Int: [BlogTag]]>
    func getTag(_ name: String) -> EventLoopFuture<BlogTag?>
    func save(_ tag: BlogTag) -> EventLoopFuture<BlogTag>
    // Delete all the pivots between a post and collection of tags - you should probably delete the
    // tags that have no posts associated with a tag
    func deleteTags(for post: BlogPost) -> EventLoopFuture<Void>
    func remove(_ tag: BlogTag, from post: BlogPost) -> EventLoopFuture<Void>
    func add(_ tag: BlogTag, to post: BlogPost) -> EventLoopFuture<Void>
}

public protocol BlogPostRepository: SteamPressRepository {
    func getAllPostsSortedByPublishDate(includeDrafts: Bool) -> EventLoopFuture<[BlogPost]>
    func getAllPostsCount(includeDrafts: Bool) -> EventLoopFuture<Int>
    func getAllPostsSortedByPublishDate(includeDrafts: Bool, count: Int, offset: Int) -> EventLoopFuture<[BlogPost]>
    func getAllPostsSortedByPublishDate(for user: BlogUser, includeDrafts: Bool, count: Int, offset: Int) -> EventLoopFuture<[BlogPost]>
    func getPostCount(for user: BlogUser) -> EventLoopFuture<Int>
    func getPost(slug: String) -> EventLoopFuture<BlogPost?>
    func getPost(id: Int) -> EventLoopFuture<BlogPost?>
    func getSortedPublishedPosts(for tag: BlogTag, count: Int, offset: Int) -> EventLoopFuture<[BlogPost]>
    func getPublishedPostCount(for tag: BlogTag) -> EventLoopFuture<Int>
    func findPublishedPostsOrdered(for searchTerm: String, count: Int, offset: Int) -> EventLoopFuture<[BlogPost]>
    func getPublishedPostCount(for searchTerm: String) -> EventLoopFuture<Int>
    func save(_ post: BlogPost) -> EventLoopFuture<BlogPost>
    func delete(_ post: BlogPost) -> EventLoopFuture<Void>
}

public protocol BlogUserRepository: SteamPressRepository {
    func getAllUsers() -> EventLoopFuture<[BlogUser]>
    func getAllUsersWithPostCount() -> EventLoopFuture<[(BlogUser, Int)]>
    func getUser(id: Int) -> EventLoopFuture<BlogUser?>
    func getUser(username: String) -> EventLoopFuture<BlogUser?>
    func save(_ user: BlogUser) -> EventLoopFuture<BlogUser>
    func delete(_ user: BlogUser) -> EventLoopFuture<Void>
    func getUsersCount() -> EventLoopFuture<Int>
}

public extension Request {
    var blogUserRepository: BlogUserRepository {
        self.application.blogUserRepositoryFactory.makeRepository!(self)
    }
    
    var blogPostRepository: BlogPostRepository {
        self.application.blogPostRepositoryFactory.makeRepository!(self)
    }
    
    var blogTagRepository: BlogTagRepository {
        self.application.blogTagRepositoryFactory.makeRepository!(self)
    }
}

private extension Application {
    private struct BlogUserRepositoryKey: StorageKey {
        typealias Value = BlogUserRepositoryFactory
    }
    var blogUserRepositoryFactory: BlogUserRepositoryFactory {
        get {
            self.storage[BlogUserRepositoryKey.self] ?? .init()
        }
        set {
            self.storage[BlogUserRepositoryKey.self] = newValue
        }
    }
    
    private struct BlogPostRepositoryKey: StorageKey {
        typealias Value = BlogPostRepositoryFactory
    }
    var blogPostRepositoryFactory: BlogPostRepositoryFactory {
        get {
            self.storage[BlogPostRepositoryKey.self] ?? .init()
        }
        set {
            self.storage[BlogPostRepositoryKey.self] = newValue
        }
    }
    
    private struct BlogTagRepositoryKey: StorageKey {
        typealias Value = BlogTagRepositoryFactory
    }
    var blogTagRepositoryFactory: BlogTagRepositoryFactory {
        get {
            self.storage[BlogTagRepositoryKey.self] ?? .init()
        }
        set {
            self.storage[BlogTagRepositoryKey.self] = newValue
        }
    }
}

private struct BlogUserRepositoryFactory {
    var makeRepository: ((Request) -> BlogUserRepository)?
    mutating func use(_ makeRepository: @escaping (Request) -> BlogUserRepository) {
        self.makeRepository = makeRepository
    }
}

private struct BlogPostRepositoryFactory {
    var makeRepository: ((Request) -> BlogPostRepository)?
    mutating func use(_ makeRepository: @escaping (Request) -> BlogPostRepository) {
        self.makeRepository = makeRepository
    }
}

private struct BlogTagRepositoryFactory {
    var makeRepository: ((Request) -> BlogTagRepository)?
    mutating func use(_ makeRepository: @escaping (Request) -> BlogTagRepository) {
        self.makeRepository = makeRepository
    }
}
