struct AdminPageContext: Encodable {
    let errors: [String]?
    let publishedPosts: [BlogPost]
    let draftPosts: [BlogPost]
    let users: [BlogUser]
    let pageInformation: BlogAdminPageInformation
    let blogAdminPage = true
    let title = "Blog Admin"
}
