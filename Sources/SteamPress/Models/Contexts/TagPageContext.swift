struct TagPageContext: Encodable {
    let tag: BlogTag
    let pageInformation: BlogGlobalPageInformation
    let posts: [ViewBlogPost]
    let tagPage = true
    let postCount: Int
    let paginationTagInformation: PaginationTagInformation
}
