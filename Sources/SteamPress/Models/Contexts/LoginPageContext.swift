struct LoginPageContext: Encodable {
    let title = "Log In"
    let errors: [String]?
    let loginWarning: Bool
    let username: String?
    let usernameError: Bool
    let passwordError: Bool
    let pageInformation: BlogGlobalPageInformation
}
