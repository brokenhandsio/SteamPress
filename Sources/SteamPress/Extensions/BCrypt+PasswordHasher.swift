import Vapor
import Crypto

public protocol PasswordHasher: Service {
    func hash(_ plaintext: LosslessDataConvertible) throws -> String
}

extension BCryptDigest: PasswordHasher {
    public func hash(_ plaintext: LosslessDataConvertible) throws -> String {
        return try self.hash(plaintext, salt: nil)
    }
}
