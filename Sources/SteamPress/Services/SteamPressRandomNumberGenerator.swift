import Vapor

public protocol SteamPressRandomNumberGenerator {
    func `for`(_ request: Request) -> SteamPressRandomNumberGenerator
    func getNumber() -> Int
}

extension RealRandomNumberGenerator {
    public func `for`(_ request: Request) -> SteamPressRandomNumberGenerator {
        RealRandomNumberGenerator()
    }
}

public extension Request {
    var randomNumberGenerator: SteamPressRandomNumberGenerator {
        self.application.randomNumberGenerators.generator.for(self)
    }
}

extension Application {
    public struct RandomNumberGenerators {
        public struct Provider {
            public static var real: Self {
                .init {
                    $0.randomNumberGenerators.use { $0.randomNumberGenerators.real }
                }
            }

            let run: (Application) -> ()

            public init(_ run: @escaping (Application) -> ()) {
                self.run = run
            }
        }
        
        final class Storage {
            var makeGenerator: ((Application) -> SteamPressRandomNumberGenerator)?
            init() { }
        }

        struct Key: StorageKey {
            typealias Value = Storage
        }

        let application: Application

        public var real: RealRandomNumberGenerator {
            return .init()
        }

        public var generator: SteamPressRandomNumberGenerator {
            guard let makeGenerator = self.storage.makeGenerator else {
                fatalError("No random number generator configured. Configure with app.randomNumberGenerators.use(...)")
            }
            return makeGenerator(self.application)
        }

        public func use(_ provider: Provider) {
            provider.run(self.application)
        }

        public func use(_ makeGenerator: @escaping (Application) -> (SteamPressRandomNumberGenerator)) {
            self.storage.makeGenerator = makeGenerator
        }

        func initialize() {
            self.application.storage[Key.self] = .init()
            self.use(.real)
        }

        private var storage: Storage {
            guard let storage = self.application.storage[Key.self] else {
                fatalError("RandomNumberGenerators not configured. Configure with app.randomNumberGenerators.initialize()")
            }
            return storage
        }
    }

    public var randomNumberGenerators: RandomNumberGenerators {
        .init(application: self)
    }
}
