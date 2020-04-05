import Vapor
import Crypto

public protocol PasswordHasher {
    func `for`(_ request: Request) -> PasswordHasher
    func hash(_ plaintext: String) throws -> String
}

extension BCryptDigest: PasswordHasher {
    public func hash(_ plaintext: String) throws -> String {
        return try self.hash(plaintext)
    }
    
    public func `for`(_ request: Request) -> PasswordHasher {
        return BCryptDigest()
    }
}

public protocol SteamPressPasswordVerifier {
    func `for`(_ request: Request) -> SteamPressPasswordVerifier
    func verify(_ plaintext: String, created hash: String) throws -> Bool
}

extension BCryptDigest: SteamPressPasswordVerifier {
    public func verify(_ plaintext: String, created hash: String) throws -> Bool {
        return try self.verify(plaintext, created: hash)
    }
    
    public func `for`(_ request: Request) -> SteamPressPasswordVerifier {
        return BCryptDigest()
    }
}


public extension Request {
    var passwordHasher: PasswordHasher {
        self.application.passwordHashers.passwordHasher.for(self)
    }
    
    var passwordVerifier: SteamPressPasswordVerifier {
        self.application.passwordVerifiers.passwordVerifier.for(self)
    }
}

public extension Application {
    struct PasswordVerifiers {
        public struct Provider {
            public static var bcrypt: Self {
                .init {
                    $0.passwordVerifiers.use { $0.passwordVerifiers.bcrypt }
                }
            }

            let run: (Application) -> ()

            public init(_ run: @escaping (Application) -> ()) {
                self.run = run
            }
        }
        
        final class Storage {
            var makeVerifier: ((Application) -> SteamPressPasswordVerifier)?
            init() { }
        }

        struct Key: StorageKey {
            typealias Value = Storage
        }

        let application: Application

        var bcrypt: BCryptDigest {
            return .init()
        }

        var passwordVerifier: SteamPressPasswordVerifier {
            guard let makeVerifier = self.storage.makeVerifier else {
                fatalError("No password verifier configured. Configure with app.passwordVerifiers.use(...)")
            }
            return makeVerifier(self.application)
        }

        public func use(_ provider: Provider) {
            provider.run(self.application)
        }

        func use(_ makeVerifier: @escaping (Application) -> (SteamPressPasswordVerifier)) {
            self.storage.makeVerifier = makeVerifier
        }

        func initialize() {
            self.application.storage[Key.self] = .init()
            self.use(.bcrypt)
        }

        private var storage: Storage {
            guard let storage = self.application.storage[Key.self] else {
                fatalError("PasswordVerifiers not configured. Configure with app.passwordVerifiers.initialize()")
            }
            return storage
        }
    }
    
    var passwordVerifiers: PasswordVerifiers {
        .init(application: self)
    }
    
    struct PasswordHashers {
        public struct Provider {
            public static var bcrypt: Self {
                .init {
                    $0.passwordHashers.use { $0.passwordHashers.bcrypt }
                }
            }

            let run: (Application) -> ()

            public init(_ run: @escaping (Application) -> ()) {
                self.run = run
            }
        }
        
        final class Storage {
            var makeHasher: ((Application) -> PasswordHasher)?
            init() { }
        }

        struct Key: StorageKey {
            typealias Value = Storage
        }

        let application: Application

        var bcrypt: BCryptDigest {
            return .init()
        }

        var passwordHasher: PasswordHasher {
            guard let makeHasher = self.storage.makeHasher else {
                fatalError("No password hasher configured. Configure with app.passwordHashers.use(...)")
            }
            return makeHasher(self.application)
        }

        public func use(_ provider: Provider) {
            provider.run(self.application)
        }

        func use(_ makeHasher: @escaping (Application) -> (PasswordHasher)) {
            self.storage.makeHasher = makeHasher
        }

        func initialize() {
            self.application.storage[Key.self] = .init()
            self.use(.bcrypt)
        }

        private var storage: Storage {
            guard let storage = self.application.storage[Key.self] else {
                fatalError("PasswordHashers not configured. Configure with app.passwordHashers.initialize()")
            }
            return storage
        }
    }

    var passwordHashers: PasswordHashers {
        .init(application: self)
    }
}
