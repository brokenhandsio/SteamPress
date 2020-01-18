struct ViewBlogTag: Encodable {
    let tagID: Int
    let name: String
    let urlEncodedName: String
}

extension BlogTag {
    func toViewBlogTag() throws -> ViewBlogTag {
        guard let urlEncodedName = self.name.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {
            throw SteamPressError(identifier: "ViewBlogPost", "Failed to URL encode tag name")
        }
        guard let tagID = self.tagID else {
            throw SteamPressError(identifier: "ViewBlogPost", "Tag has no ID")
        }
        return ViewBlogTag(tagID: tagID, name: self.name, urlEncodedName: urlEncodedName)
    }
}

extension ViewBlogTag {
    
    static func percentEncodedTagName(from name: String) throws -> String {
        guard let percentEncodedName = name.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {
            throw SteamPressError(identifier: "BlogTag", "Unable to create tag from name \(name)")
        }
        return percentEncodedName
    }
}
