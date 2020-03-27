import Crypto

extension String {
    public static func random(length: Int = 24) throws  -> String {
        let randomString = [UInt8].random(count: length).base64
        return randomString
    }
}
