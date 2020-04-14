import Vapor
import SteamPress

struct ReversedPasswordHasher: PasswordHasher {
    
    func verify<Password, Digest>(_ password: Password, created digest: Digest) throws -> Bool where Password : DataProtocol, Digest : DataProtocol {
        return password.reversed() == Array(digest)
    }
    
    func hash<Password>(_ password: Password) throws -> [UInt8] where Password : DataProtocol {
        return password.reversed()
    }
}

extension Application.Passwords.Provider {
    public static var reversed: Self {
        .init {
            $0.passwords.use { _ in
                ReversedPasswordHasher()
            }
        }
    }
}
