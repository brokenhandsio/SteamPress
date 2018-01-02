//import Validation
//
//struct NameValidator: Validator {
//    func validate(_ input: String) throws {
//        try Count.containedIn(low: 1, high: 64).validate(input)
//
//        let range = input.range(of: "^[a-z ,.'-]+$", options: [.regularExpression, .caseInsensitive])
//        guard range != nil else {
//            throw error("Name contains invalid characters")
//        }
//    }
//}

