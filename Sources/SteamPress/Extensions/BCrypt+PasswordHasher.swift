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
        self.application.passwordHashers.makeHasher!(self)
    }
    
    internal var passwordVerifier: SteamPressPasswordVerifier {
        self.application.passwordVerifiers.makeVerifier!(self)
    }
}

private extension Application {
    var passwordHashers: PasswordHasherFactory {
        get {
            if let existing = self.userInfo["passwordHasher"] as? PasswordHasherFactory {
                return existing
            } else {
                let new = PasswordHasherFactory()
                self.userInfo["passwordHasher"] = new
                return new
            }
        }
        set {
            self.userInfo["passwordHasher"] = newValue
        }
    }
    
    var passwordVerifiers: PasswordVerifierFactory {
        get {
            if let existing = self.userInfo["passwordVerifier"] as? PasswordVerifierFactory {
                return existing
            } else {
                let new = PasswordVerifierFactory()
                self.userInfo["passwordVerifier"] = new
                return new
            }
        }
        set {
            self.userInfo["passwordVerifier"] = newValue
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
