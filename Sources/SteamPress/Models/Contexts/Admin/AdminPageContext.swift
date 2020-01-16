struct AdminPageContext: Encodable {
    let errors: [String]?
    let publishedPosts: [ViewBlogPost]
    let draftPosts: [ViewBlogPost]
    let users: [BlogUser]
    let pageInformation: BlogAdminPageInformation
    let blogAdminPage = true
    let title = "Blog Admin"
}
