import Vapor

extension Application {
    public struct SteamPress {
        let application: Application
        
        final class Storage {
//            let databases: Databases
//            let migrations: Migrations

            init(threadPool: NIOThreadPool, on eventLoopGroup: EventLoopGroup) {
//                self.databases = Databases(
//                    threadPool: threadPool,
//                    on: eventLoopGroup
//                )
//                self.migrations = .init()
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
            self.application.storage[Key.self] = .init(
                threadPool: self.application.threadPool,
                on: self.application.eventLoopGroup
            )
//            self.application.lifecycle.use(SteamPressRoutesLifecycleHandler())
        }
    }
    
    public var steampress: SteamPress {
        .init(application: self)
    }
    
//    public var configuration: SteamPressConfiguration {
//        get {
//            self.steampress.storage.configuration
//        }
//        set {
//
//        }
//    }
}

public struct SteamPressConfiguration {
    
}
