struct AuthorPageContext: Encodable {
    let author: BlogUser
    let posts: [BlogPost]
    let pageInformation: BlogGlobalPageInformation
    let myProfile: Bool
    let profilePage = true
}
