import Foundation

struct ViewBlogPost: Encodable {
    var blogID: Int?
    var title: String
    var contents: String
    var author: Int
    var created: Date
    var lastEdited: Date?
    var slugUrl: String
    var published: Bool
    var longSnippet: String
    var createdDateLong: String
    #warning("Need authorUsername")
    #warning("Need createdDate")
    #warning("Need authorName")
}

extension BlogPost {
    func toViewPost(formatter: DateFormatter) -> ViewBlogPost {
        ViewBlogPost(blogID: self.blogID, title: self.title, contents: self.contents, author: self.author, created: self.created, lastEdited: self.lastEdited, slugUrl: self.slugUrl, published: self.published, longSnippet: self.longSnippet(), createdDateLong: formatter.string(from: self.created))
    }
}
