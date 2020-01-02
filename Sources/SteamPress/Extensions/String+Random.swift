import Crypto

extension String {
    public static func random(length: Int = 12) throws  -> String {
        let randomData = try CryptoRandom().generateData(count: length)
        let randomString = randomData.base64EncodedString()
        return randomString
    }
}
