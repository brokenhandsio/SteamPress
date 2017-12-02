import Vapor

extension Request {
    func getURIWithHTTPSIfReverseProxy() -> URI {
        if self.headers["X-Forwarded-Proto"] == "https" {
            return URI(scheme: "https", userInfo: self.uri.userInfo, hostname: self.uri.hostname, port: nil, path: self.uri.path, query: self.uri.query, fragment: self.uri.fragment)
        }

        return self.uri
    }
}
