import Vapor

struct SteamPressError: AbortError, DebuggableError {

    let identifier: String
    let reason: String

    init(identifier: String, _ reason: String) {
        self.identifier = identifier
        self.reason = reason
    }

    var status: HTTPResponseStatus {
        return .internalServerError
    }
}
