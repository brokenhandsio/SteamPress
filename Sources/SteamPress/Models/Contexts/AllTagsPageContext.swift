struct AllTagsPageContext: Encodable {
    let title: String
    let tags: [ViewBlogTag]
    let pageInformation: BlogGlobalPageInformation
}
