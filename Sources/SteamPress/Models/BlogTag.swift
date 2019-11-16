import Vapor

// MARK: - Model

public final class BlogTag: Codable {

    public var tagID: Int?
    public var name: String

    public init(id: Int? = nil, name: String) throws {
        self.tagID = id
        self.name = try BlogTag.percentEncodedTagName(from: name)
    }
}

extension BlogTag: Content {}

extension BlogTag {
    static func percentEncodedTagName(from name: String) throws -> String {
        guard let percentEncodedName = name.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {
            throw SteamPressError(identifier: "BlogTag", "Unable to create tag from name \(name)")
        }
        return percentEncodedName
    }
}

