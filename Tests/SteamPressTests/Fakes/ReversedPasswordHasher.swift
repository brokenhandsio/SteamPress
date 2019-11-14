import Vapor
import Authentication
import SteamPress

struct ReversedPasswordHasher: PasswordHasher, PasswordVerifier {
    func hash(_ plaintext: LosslessDataConvertible) throws -> String {
        return String(String.convertFromData(plaintext.convertToData()).reversed())
    }
    
    func verify(_ password: LosslessDataConvertible, created hash: LosslessDataConvertible) throws -> Bool {
        let passwordString = String.convertFromData(password.convertToData())
        let passwordHash = String.convertFromData(hash.convertToData())
        return passwordString == String(passwordHash.reversed())
    }
}
