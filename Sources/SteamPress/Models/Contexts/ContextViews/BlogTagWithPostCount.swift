struct BlogTagWithPostCount: Encodable {
    let tagID: Int
    let name: String
    let postCount: Int
    let urlEncodedName: String
}

