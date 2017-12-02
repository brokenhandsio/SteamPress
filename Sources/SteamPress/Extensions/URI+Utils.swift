import URI

extension URI {
    func getRootUri() -> URI {
        return URI(scheme: self.scheme, userInfo: nil, hostname: self.hostname, port: self.port, path: "", query: nil, fragment: nil).removingPath()
    }

    var descriptionWithoutPort: String {
        get {
            if scheme.isSecure {
                return self.description.replacingFirstOccurrence(of: ":443", with: "")
            }
            else {
                return self.description.replacingFirstOccurrence(of: ":80", with: "")
            }
        }
    }
}
