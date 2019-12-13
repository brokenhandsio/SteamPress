struct SearchPageContext: Encodable {
    let title = "Search Blog"
    let searchTerm: String?
    let posts: [BlogPost]
    let pageInformation: BlogGlobalPageInformation
}
