import HTTP

extension Response {
    convenience init(getRedirect path: String) {
        self.init(status: .seeOther, headers: [HeaderKey.location: path])
    }
}
