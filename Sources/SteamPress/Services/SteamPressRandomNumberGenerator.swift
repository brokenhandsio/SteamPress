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
    var randomNumberGenerators: RandomNumberGeneratorFactory {
        get {
            if let existing = self.userInfo["randomNumberGenerator"] as? RandomNumberGeneratorFactory {
                return existing
            } else {
                let new = RandomNumberGeneratorFactory()
                self.userInfo["randomNumberGenerator"] = new
                return new
            }
        }
        set {
            self.userInfo["randomNumberGenerator"] = newValue
        }
    }
}

public extension Request {
    var randomNumberGenerator: SteamPressRandomNumberGenerator {
        self.application.randomNumberGenerators.makeRNG!(self)
    }
}
