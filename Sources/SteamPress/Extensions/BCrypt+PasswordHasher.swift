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


public extension Request {
    var passwordHasher: PasswordHasher {
        self.application.passwordHashers.makeHasher!(self)
    }
    
    var passwordVerifier: PasswordVerifier {
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
    var makeVerifier: ((Request) -> PasswordVerifier)?
    mutating func use(_ makeVerifier: @escaping (Request) -> PasswordVerifier) {
        self.makeVerifier = makeVerifier
    }
}
