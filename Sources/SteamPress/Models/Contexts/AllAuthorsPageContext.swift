struct AllAuthorsPageContext: Encodable {
    let pageInformation: BlogGlobalPageInformation
    let authors: [ViewBlogAuthor]
}

struct ViewBlogAuthor: Encodable {
    let userID: Int
    let name: String
    let username: String
    let resetPasswordRequired: Bool
    let profilePicture: String?
    let twitterHandle: String?
    let biography: String?
    let tagline: String?
    let postCount: Int
}
