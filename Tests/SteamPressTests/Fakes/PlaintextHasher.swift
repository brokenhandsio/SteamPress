import Vapor
import SteamPress

struct PlaintextHasher: PasswordHasher {
    func hash(_ plaintext: LosslessDataConvertible) throws -> String {
        return String.convertFromData(plaintext.convertToData())
    }
}
