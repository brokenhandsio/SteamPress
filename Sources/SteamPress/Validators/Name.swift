import Vapor

struct NameValidator: ValidationSuite {
    static func validate(input value: String) throws {
        try Count.containedIn(low: 1, high: 64).validate(input: value)
        
        let range = value.range(of: "^[a-z ,.'-]+$", options: [.regularExpression, .caseInsensitive])
        guard let _ = range else {
            throw error(with: value)
        }
    }
}
