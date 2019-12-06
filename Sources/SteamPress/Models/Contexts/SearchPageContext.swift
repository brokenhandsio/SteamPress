struct SearchPageContext: Encodable {
    let searchTerm: String?
    let posts: [BlogPost]
    let pageInformation: BlogGlobalPageInformation
}
