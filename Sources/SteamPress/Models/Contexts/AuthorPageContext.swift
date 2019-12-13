struct AuthorPageContext: Encodable {
    let author: BlogUser
    let posts: [ViewBlogPost]
    let pageInformation: BlogGlobalPageInformation
    let myProfile: Bool
    let profilePage = true
    let postCount: Int
}
