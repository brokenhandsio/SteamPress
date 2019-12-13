import Vapor

struct ResetPasswordData: Content {
    let password: String?
    let confirmPassword: String?
}
