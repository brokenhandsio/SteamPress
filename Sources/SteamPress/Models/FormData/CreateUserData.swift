import Vapor

struct CreateUserData: Content {
    let name: String?
    let username: String?
    let password: String?
    let confirmPassword: String?
    let profilePicture: String?
    let tagline: String?
    let biography: String?
    let twitterHandle: String?
    let resetPasswordOnLogin: Bool?
}

extension CreateUserData: Validatable {
//    static func validations() throws -> Validations<CreateUserData> {
//        var validations = Validations(CreateUserData.self)
//        let usernameCharacterSet = CharacterSet(charactersIn: "-_")
//        let usernameValidationCharacters = Validator<String>.characterSet(.alphanumerics + usernameCharacterSet)
//        try validations.add(\.username, usernameValidationCharacters || .nil)
//        return validations
//    }
    
    static func validations(_ validations: inout Validations) {
        #warning("TODO")
    }
}
