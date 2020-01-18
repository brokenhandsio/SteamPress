struct BlogIndexPageContext: Encodable {
    let posts: [ViewBlogPost]
    let tags: [ViewBlogTag]
    let authors: [BlogUser]
    let pageInformation: BlogGlobalPageInformation
    let title = "Blog"
    let blogIndexPage = true
    let paginationTagInformation: PaginationTagInformation
}
