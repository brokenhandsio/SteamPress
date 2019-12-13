import Vapor

struct LoginData: Content {
    let username: String?
    let password: String?
    let rememberMe: Bool?

    init(username: String?, password: String?, rememberMe: Bool? = nil) {
        self.username = username
        self.password = password
        self.rememberMe = rememberMe
    }
}
