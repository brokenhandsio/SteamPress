import Validation

struct PasswordValidator: Validator {
    
    func validate(_ input: String) throws {
        // Check length
        if input.count < 8 {
            throw error("Password not long enough")
        }
        
        // Check complexity
        let upperCasePattern = "^(?=.*[A-Z]).*$"
        let lowerCasePattern = "^(?=.*[a-z]).*$"
        let numberPattern = "^(?=.*[0-9]).*$"
        let symbolPattern = "^(?=.*[!@#%&-_=:;\"'<>,`~\\*\\?\\+\\[\\]\\(\\)\\{\\}\\^\\$\\|\\\\\\.\\/]).*$"
        
        let patterns = [upperCasePattern, lowerCasePattern, numberPattern, symbolPattern]
        
        var complexityStrength = 0
        
        for pattern in patterns {
            if input.range(of: pattern, options: .regularExpression) != nil {
                complexityStrength += 1
            }
        }
        
        if complexityStrength < 3 {
            throw error("Password is not complex enough")
        }
    }
}
