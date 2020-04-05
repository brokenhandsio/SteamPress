import Vapor
import SteamPress

struct PlaintextHasher: PasswordHasher {

    func hash(_ plaintext: String) throws -> String {
        return plaintext
    }
    
    func `for`(_ request: Request) -> PasswordHasher {
        return PlaintextHasher()
    }
}

extension Application.PasswordHashers.Provider {
    public static var plaintext: Self {
        .init {
            $0.passwordHashers.use { $0.passwordHashers.plaintext }
        }
    }
}

extension Application.PasswordHashers {
    var plaintext: PlaintextHasher {
        return .init()
    }
}

extension PlaintextVerifier: SteamPressPasswordVerifier {
    public func `for`(_ request: Request) -> SteamPressPasswordVerifier {
        return PlaintextVerifier()
    }
    
    public func verify(_ plaintext: String, created hash: String) throws -> Bool {
        return plaintext == hash
    }
}

extension Application.PasswordVerifiers {
    var plaintext: PlaintextVerifier {
        return .init()
    }
}

extension Application.PasswordVerifiers.Provider {
    public static var plaintext: Self {
        .init {
            $0.passwordVerifiers.use { $0.passwordVerifiers.plaintext }
        }
    }
}
