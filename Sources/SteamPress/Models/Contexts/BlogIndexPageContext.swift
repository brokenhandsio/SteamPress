struct BlogIndexPageContext: Encodable {
    let posts: [BlogPost]
    let tags: [BlogTag]
    let authors: [BlogUser]
    let pageInformation: BlogGlobalPageInformation
    let title = "Blog"
    let blogIndexPage = true
    let paginationInformation: PaginationTagInformation
}
