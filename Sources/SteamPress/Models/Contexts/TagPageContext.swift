struct TagPageContext: Encodable {
    let tag: BlogTag
    let pageInformation: BlogGlobalPageInformation
    let posts: [BlogPost]
    let tagPage = true
}
