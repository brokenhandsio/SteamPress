import Vapor

public protocol SteamPressRandomNumberGenerator {
    func getNumber() -> Int
}

private struct RandomNumberGeneratorFactory {
    var makeRNG: ((Request) -> SteamPressRandomNumberGenerator)?
    mutating func use(_ makeRNG: @escaping (Request) -> SteamPressRandomNumberGenerator) {
        self.makeRNG = makeRNG
    }
}

private extension Application {
    private struct RandomNumberGeneratorKey: StorageKey {
        typealias Value = RandomNumberGeneratorFactory
    }
    var randomNumberGenerators: RandomNumberGeneratorFactory {
        get {
            self.storage[RandomNumberGeneratorKey.self] ?? .init()
        }
        set {
            self.storage[RandomNumberGeneratorKey.self] = newValue
        }
    }
}

public extension Request {
    var randomNumberGenerator: SteamPressRandomNumberGenerator {
        self.application.randomNumberGenerators.makeRNG!(self)
    }
}
