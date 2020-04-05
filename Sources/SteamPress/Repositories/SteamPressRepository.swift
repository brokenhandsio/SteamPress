import Vapor

public protocol SteamPressRepository {
    //    associatedtype ModelType
    //    func get(_ id: Int, on eventLoop: EventLoop) -> EventLoopFuture<ModelType>
}

public protocol BlogTagRepository: SteamPressRepository {
    func `for`(_ request: Request) -> BlogTagRepository
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
    func `for`(_ request: Request) -> BlogPostRepository
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
    func `for`(_ request: Request) -> BlogUserRepository
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
        self.application.blogRepositories.userRepository.for(self)
    }
    
    var blogPostRepository: BlogPostRepository {
        self.application.blogRepositories.postRepository.for(self)
    }
    
    var blogTagRepository: BlogTagRepository {
        self.application.blogRepositories.tagRepository.for(self)
    }
}

public extension Application {
    struct BlogRepositories {
        public struct Provider {
            let run: (Application) -> ()
            
            public init(_ run: @escaping (Application) -> ()) {
                self.run = run
            }
        }
        
        final class Storage {
            var makePostRepository: ((Application) -> BlogPostRepository)?
            var makeTagRepository: ((Application) -> BlogTagRepository)?
            var makeUserRepository: ((Application) -> BlogUserRepository)?
            init() { }
        }
        
        struct Key: StorageKey {
            typealias Value = Storage
        }
        
        let application: Application
        
        var userRepository: BlogUserRepository {
            guard let makeRepository = self.storage.makeUserRepository else {
                fatalError("No user repository configured. Configure with app.blogRepositories.use(...)")
            }
            return makeRepository(self.application)
        }
        
        var postRepository: BlogPostRepository {
            guard let makeRepository = self.storage.makePostRepository else {
                fatalError("No post repository configured. Configure with app.blogRepositories.use(...)")
            }
            return makeRepository(self.application)
        }
        
        var tagRepository: BlogTagRepository {
            guard let makeRepository = self.storage.makeTagRepository else {
                fatalError("No tag repository configured. Configure with app.blogRepositories.use(...)")
            }
            return makeRepository(self.application)
        }
        
        public func use(_ provider: Provider) {
            provider.run(self.application)
        }
        
        public func use(_ makeRespository: @escaping (Application) -> (BlogUserRepository & BlogTagRepository & BlogPostRepository)) {
            self.storage.makeUserRepository = makeRespository
            self.storage.makeTagRepository = makeRespository
            self.storage.makePostRepository = makeRespository
        }
        
        func initialize() {
            self.application.storage[Key.self] = .init()
        }
        
        private var storage: Storage {
            guard let storage = self.application.storage[Key.self] else {
                fatalError("Repositoroes not configured. Configure with app.blogRepositories.initialize()")
            }
            return storage
        }
    }
    
    var blogRepositories: BlogRepositories {
        .init(application: self)
    }
}
