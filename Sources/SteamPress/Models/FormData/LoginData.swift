import Vapor

struct LoginData: Content {
    let username: String?
    let password: String?
    #warning("Remember me")
}
