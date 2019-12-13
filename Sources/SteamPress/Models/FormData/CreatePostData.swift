import Vapor

struct CreatePostData: Content {
    let title: String?
    let contents: String?
    let publish: Bool?
    let draft: Bool?
    let tags: [String]
    let updateSlugURL: Bool?
}
