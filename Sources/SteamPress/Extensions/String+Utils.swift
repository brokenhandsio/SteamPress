import Foundation

extension String {

    // TODO Could probably improve this
    static func random(length: Int = 8) -> String {
        let base = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        var randomString: String = ""

        for _ in 0..<length {
            #if swift(>=4)
                let randomValue = Int.random(min: 0, max: base.count-1)
            #else
                let randomValue = Int.random(min: 0, max: base.characters.count-1)
            #endif
            randomString += "\(base[base.index(base.startIndex, offsetBy: Int(randomValue))])"
        }
        return randomString
    }

    func isWhitespace() -> Bool {
        let whitespaceSet = CharacterSet.whitespacesAndNewlines
        if isEmpty || self.trimmingCharacters(in: whitespaceSet).isEmpty {
            return true
        } else {
            return false
        }
    }

    func replacingFirstOccurrence(of target: String, with replaceString: String) -> String
    {
        if let range = self.range(of: target) {
            return self.replacingCharacters(in: range, with: replaceString)
        }
        return self
    }
}
