struct CreateUserPageContext: Encodable {
    let title = "Create User"
    let editing: Bool
    let errors: [String]?
    let nameSupplied: String?
    let nameError: Bool
    let usernameSupplied: String?
    let usernameError: Bool
    let passwordError: Bool
    let confirmPasswordError: Bool
    let resetPasswordOnLoginSupplied: Bool
    let userID: Int?
    let twitterHandleSupplied: String?
    let profilePictureSupplied: String?
    let biographySupplied: String?
    let taglineSupplied: String?
    let pageInformation: BlogAdminPageInformation
}
