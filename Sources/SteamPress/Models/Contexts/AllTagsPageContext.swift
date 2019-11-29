struct AllTagsPageContext: Encodable {
    let title: String
    let tags: [ViewBlogTag]
    let pageInformation: BlogGlobalPageInformation
}

struct ViewBlogTag: Encodable {
    let tagID: Int
    let name: String
    let postCount: Int
}
