import Vapor

struct LoginData: Content {
    let username: String?
    let password: String?
    let rememberMe: Bool?
}
