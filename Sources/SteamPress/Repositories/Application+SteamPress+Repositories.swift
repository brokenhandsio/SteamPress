import Vapor

public extension Application.SteamPress {
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
        
        public func initialize() {
            self.application.storage[Key.self] = .init()
        }
        
        private var storage: Storage {
            if self.application.storage[Key.self] == nil {
                self.initialize()
            }
            return self.application.storage[Key.self]!
        }
    }
    
    var blogRepositories: BlogRepositories {
        .init(application: self.application)
    }
}
