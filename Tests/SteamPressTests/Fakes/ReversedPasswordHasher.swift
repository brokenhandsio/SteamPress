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
