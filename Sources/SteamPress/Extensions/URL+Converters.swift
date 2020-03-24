import Foundation
import Vapor

extension Request {
    func url() throws -> URL {
        let path = self.http.url.path.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? ""
        
        let hostname: String
        if let envURL = Environment.get("WEBSITE_URL") {
            hostname = envURL
        } else {
            hostname = self.http.remotePeer.description
        }
        
        let urlString  = "\(hostname)\(path)"
        guard let url = URL(string: urlString) else {
            throw SteamPressError(identifier: "SteamPressError", "Failed to convert url path to URL")
        }
        return url
    }
    
    func rootUrl() throws -> URL {
        if let envURL = Environment.get("WEBSITE_URL") {
            guard let url = URL(string: envURL) else {
                throw SteamPressError(identifier: "SteamPressError", "Failed to convert url hostname to URL")
            }
            return url
        }
        
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
