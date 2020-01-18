import Vapor

// MARK: - Model

public final class BlogTag: Codable {

    public var tagID: Int?
    public var name: String

    public init(id: Int? = nil, name: String) {
        self.tagID = id
        self.name = name
    }
}

extension BlogTag: Content {}
