import Vapor

struct PasswordValidator: ValidationSuite {
    static func validate(input value: String) throws {
        
        // Check length
        if value.count < 8 {
            throw error(with: value, message: "Password not long enough")
        }
        
        // Check complexity
        let upperCasePattern = "^(?=.*[A-Z]).*$"
        let lowerCasePattern = "^(?=.*[a-z]).*$"
        let numberPattern = "^(?=.*[0-9]).*$"
        let symbolPattern = "^(?=.*[!@#%&-_=:;\"'<>,`~\\*\\?\\+\\[\\]\\(\\)\\{\\}\\^\\$\\|\\\\\\.\\/]).*$"
        
        let patterns = [upperCasePattern, lowerCasePattern, numberPattern, symbolPattern]
        
        var complexityStrength = 0
        
        for pattern in patterns {
            if value.range(of: pattern, options: .regularExpression) != nil {
                complexityStrength += 1
            }
        }
        
        if complexityStrength < 3 {
            throw error(with: value)
        }
    }
}
