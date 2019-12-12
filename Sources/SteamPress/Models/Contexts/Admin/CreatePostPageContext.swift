struct CreatePostPageContext: Encodable {
    let title: String
    let editing: Bool
    let post: BlogPost?
    let draft: Bool
    let errors: [String]?
    let titleSupplied: String?
    let contentsSupplied: String?
    let tagsSupplied: [String]?
    let slugURLSupplied: String?
    let titleError: Bool
    let contentsError: Bool
    let postPathPrefix: String
    let pageInformation: BlogAdminPageInformation
}
