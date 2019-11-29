struct AllTagsPageContext: Encodable {
    let title: String
    let tags: [BlogTag]
    let pageInformation: BlogGlobalPageInformation
}
