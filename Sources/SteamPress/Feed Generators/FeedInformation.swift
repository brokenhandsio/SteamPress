public struct FeedInformation {
    let title: String?
    let description: String?
    let copyright: String?
    let imageURL: String?
    
    public init(title: String? = nil, description: String? = nil, copyright: String? = nil, imageURL: String? = nil) {
        self.title = title
        self.description = description
        self.copyright = copyright
        self.imageURL = imageURL
    }
}
