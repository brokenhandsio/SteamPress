import Foundation
import Vapor

extension Request {
    func url() throws -> URL {
        let hostname = self.http.remotePeer.description
        let path = self.http.url.path.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? ""
        let urlString  = "\(hostname)\(path)"
        guard let url = URL(string: urlString) else {
            throw SteamPressError(identifier: "SteamPressError", "Failed to convert url path to URL")
        }
        return url
    }
    
    func rootUrl() throws -> URL {
        var hostname = self.http.remotePeer.description
        if hostname == "" {
            hostname = "/"
        }
        guard let url = URL(string: hostname) else {
            throw SteamPressError(identifier: "SteamPressError", "Failed to convert url hostname to URL")
        }
        return url
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
