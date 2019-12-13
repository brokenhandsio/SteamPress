import Foundation
import Vapor

extension URL {
    func getRootUrl() throws -> URL {
        var components = URLComponents()
        components.scheme = self.scheme
        components.host = self.host
        guard let url = components.url else {
            throw SteamPressError(identifier: "SteamPressError", "Unable to get root url from \(self.absoluteString)")
        }
        return url
    }

    var descriptionWithoutPort: String {
        get {
            if scheme == "https" {
                return self.absoluteString.replacingFirstOccurrence(of: ":443", with: "")
            } else {
                return self.absoluteString.replacingFirstOccurrence(of: ":80", with: "")
            }
        }
    }
}

extension Request {
    func urlWithHTTPSIfReverseProxy() throws -> URL {
        if self.http.headers["X-Forwarded-Proto"].first == "https" {
            guard var componets = URLComponents(url: self.http.url, resolvingAgainstBaseURL: false) else {
                throw SteamPressError(identifier: "SteamPressError", "Failed to get componets of url from \(self.http.url.absoluteString)")
            }
            componets.scheme = "https"
            guard let url = componets.url else {
                throw SteamPressError(identifier: "SteamPressError", "Failed to convert components to URL")
            }
            return url
        }
        return self.http.url
    }
}

private extension String {
    func replacingFirstOccurrence(of target: String, with replaceString: String) -> String {
        if let range = self.range(of: target) {
            return self.replacingCharacters(in: range, with: replaceString)
        }
        return self
    }
}
