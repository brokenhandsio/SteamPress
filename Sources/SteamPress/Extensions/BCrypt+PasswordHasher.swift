import Vapor
import Crypto

public protocol PasswordHasher {
    func hash(_ plaintext: String) throws -> String
}

extension BCryptDigest: PasswordHasher {
    public func hash(_ plaintext: String) throws -> String {
        return try self.hash(plaintext)
    }
}

protocol SteamPressPasswordVerifier {
    func verify(_ plaintext: String, created hash: String) throws -> Bool
}

extension BCryptDigest: SteamPressPasswordVerifier {
    func verify(_ plaintext: String, created hash: String) throws -> Bool {
        return try self.verify(plaintext, created: hash)
    }
}


public extension Request {
    var passwordHasher: PasswordHasher {
        self.application.passwordHasherFactory.makeHasher!(self)
    }
    
    internal var passwordVerifier: SteamPressPasswordVerifier {
        self.application.passwordVerifierFactory.makeVerifier!(self)
    }
}

private extension Application {
    private struct PasswordHasherKey: StorageKey {
        typealias Value = PasswordHasherFactory
    }
    var passwordHasherFactory: PasswordHasherFactory {
        get {
            self.storage[PasswordHasherKey.self] ?? .init()
        }
        set {
            self.storage[PasswordHasherKey.self] = newValue
        }
    }
    
    private struct PasswordVerifierKey: StorageKey {
        typealias Value = PasswordVerifierFactory
    }
    var passwordVerifierFactory: PasswordVerifierFactory {
        get {
            self.storage[PasswordVerifierKey.self] ?? .init()
        }
        set {
            self.storage[PasswordVerifierKey.self] = newValue
        }
    }
}

private struct PasswordHasherFactory {
    var makeHasher: ((Request) -> PasswordHasher)?
    mutating func use(_ makeHasher: @escaping (Request) -> PasswordHasher) {
        self.makeHasher = makeHasher
    }
}

private struct PasswordVerifierFactory {
    var makeVerifier: ((Request) -> SteamPressPasswordVerifier)?
    mutating func use(_ makeVerifier: @escaping (Request) -> SteamPressPasswordVerifier) {
        self.makeVerifier = makeVerifier
    }
}
