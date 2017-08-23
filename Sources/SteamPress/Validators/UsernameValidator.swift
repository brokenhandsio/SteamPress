import Validation

struct UsernameValidator: Validator {
    func validate(_ input: String) throws {
        try Count.containedIn(low: 1, high: 64).validate(input)

        let range = input.range(of: "^[a-z0-9 ,._'-]+$", options: [.regularExpression, .caseInsensitive])
        guard let _ = range else {
            throw error("Invalid characters in username")
        }
    }
}
