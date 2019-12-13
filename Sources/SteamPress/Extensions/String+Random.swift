import Crypto

extension String {
    static func random(length: Int = 12) throws  -> String {
        let randomData = try CryptoRandom().generateData(count: length)
        let randomString = randomData.base64EncodedString()
        return randomString
    }
}
