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
        self.application.steampress.randomNumberGenerators.generator.for(self)
    }
}

public extension Application.SteamPress {
    struct RandomNumberGenerators {
        public struct Provider {
            static var real: Self {
                .init {
                    $0.steampress.randomNumberGenerators.use { $0.steampress.randomNumberGenerators.real }
                }
            }

            let run: (Application) -> ()

            init(_ run: @escaping (Application) -> ()) {
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

        var real: RealRandomNumberGenerator {
            return .init()
        }

        var generator: SteamPressRandomNumberGenerator {
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
            if self.application.storage[Key.self] == nil {
                self.initialize()
            }
            return self.application.storage[Key.self]!
        }
    }

    var randomNumberGenerators: RandomNumberGenerators {
        .init(application: self.application)
    }
}
