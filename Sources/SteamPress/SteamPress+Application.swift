import Vapor

extension Application {
    public class SteamPress {
        let application: Application
        let lifecycleHandler: SteamPressRoutesLifecycleHandler
        
        init(application: Application, lifecycleHandler: SteamPressRoutesLifecycleHandler) {
            self.application = application
            self.lifecycleHandler = lifecycleHandler
        }
        
        final class Storage {
            var configuration: SteamPressConfiguration
            
            init() {
                configuration = SteamPressConfiguration()
            }
        }
        
        struct Key: StorageKey {
            typealias Value = Storage
        }
        
        var storage: Storage {
            if self.application.storage[Key.self] == nil {
                self.initialize()
            }
            return self.application.storage[Key.self]!
        }
        
        func initialize() {
            self.application.storage[Key.self] = .init()
            self.application.lifecycle.use(lifecycleHandler)
        }
        
        public var configuration: SteamPressConfiguration {
            get {
                self.storage.configuration
            }
            set {
                self.storage.configuration = newValue
                self.lifecycleHandler.configuration = newValue
            }
        }
    }
    
    public var steampress: SteamPress {
        .init(application: self, lifecycleHandler: SteamPressRoutesLifecycleHandler())
    }
}

public class SteamPressConfiguration {
    let blogPath: String?
    let feedInformation: FeedInformation
    let postsPerPage: Int
    let enableAuthorPages: Bool
    let enableTagPages: Bool
    
    public init(
        blogPath: String? = nil,
        feedInformation: FeedInformation = FeedInformation(),
        postsPerPage: Int = 10,
        enableAuthorPages: Bool = true,
        enableTagPages: Bool = true) {
        self.blogPath = blogPath
        self.feedInformation = feedInformation
        self.postsPerPage = postsPerPage
        self.enableAuthorPages = enableAuthorPages
        self.enableTagPages = enableTagPages
    }
}
