struct ResetPasswordPageContext: Encodable {
    let errors: [String]?
    let passwordError: Bool?
    let confirmPasswordError: Bool?
    let pageInformation: BlogAdminPageInformation
}
