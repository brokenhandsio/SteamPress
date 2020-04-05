import Vapor
import SteamPress

struct ReversedPasswordHasher: PasswordHasher, SteamPressPasswordVerifier {
    func `for`(_ request: Request) -> PasswordHasher {
        return ReversedPasswordHasher()
    }
    
    func `for`(_ request: Request) -> SteamPressPasswordVerifier {
        return ReversedPasswordHasher()
    }
    
    func hash(_ plaintext: String) throws -> String {
        return String(plaintext.reversed())
    }
    
    func verify(_ plaintext: String, created hash: String) throws -> Bool {
        return plaintext == String(hash.reversed())
    }
}

extension Application.PasswordHashers.Provider {
    public static var reversed: Self {
        .init {
            $0.passwordHashers.use { $0.passwordHashers.reversed }
        }
    }
}

extension Application.PasswordHashers {
    var reversed: ReversedPasswordHasher {
        return .init()
    }
}

extension Application.PasswordVerifiers {
    var reversed: ReversedPasswordHasher {
        return .init()
    }
}

extension Application.PasswordVerifiers.Provider {
    public static var reversed: Self {
        .init {
            $0.passwordVerifiers.use { $0.passwordVerifiers.reversed }
        }
    }
}
