import Foundation
import Vapor

extension Request {
    func url() throws -> URL {
        let path = self.url.path.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? ""
        let rootURL = try self.rootUrl()
        return rootURL.appendingPathComponent(path)
    }
    
    func rootUrl() throws -> URL {
        guard let hostname = Environment.get("WEBSITE_URL") else {
            throw SteamPressError(identifier: "SteamPressError", "WEBSITE_URL not set")
        }
        
        guard let url = URL(string: hostname) else {
            throw SteamPressError(identifier: "SteamPressError", "Failed to convert url hostname to URL")
        }
        return url
    }
}
