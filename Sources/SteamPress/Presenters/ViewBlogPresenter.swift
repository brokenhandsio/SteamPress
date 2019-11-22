import Vapor

public struct ViewBlogPresenter: BlogPresenter {

    public func indexView(on container: Container, posts: [BlogPost], tags: [BlogTag], authors: [BlogUser], pageInformation: BlogGlobalPageInformation) -> EventLoopFuture<View> {
        fatalError()
    }

    public func postView(on container: Container, post: BlogPost, author: BlogUser, pageInformation: BlogGlobalPageInformation) -> EventLoopFuture<View> {
        do {
            let viewRenderer = try container.make(ViewRenderer.self)
            let context = BlogPostPageContext(title: post.title, post: post, author: author, pageInformation: pageInformation)
            return viewRenderer.render("blog/post", context)
        } catch {
            return container.eventLoop.newFailedFuture(error: error)
        }

    }

    public func allAuthorsView(on container: Container, authors: [BlogUser], pageInformation: BlogGlobalPageInformation) -> EventLoopFuture<View> {
        fatalError()
    }

    public func authorView(on container: Container, author: BlogUser, posts: [BlogPost], pageInformation: BlogGlobalPageInformation) -> EventLoopFuture<View> {
        fatalError()
    }

    public func allTagsView(on container: Container, tags: [BlogTag], pageInformation: BlogGlobalPageInformation) -> EventLoopFuture<View> {
        fatalError()
    }

    public func tagView(on container: Container, tag: BlogTag, posts: [BlogPost], pageInformation: BlogGlobalPageInformation) -> EventLoopFuture<View> {
        fatalError()
    }

    public func searchView(on container: Container, posts: [BlogPost]?, searchTerm: String?, pageInformation: BlogGlobalPageInformation) -> EventLoopFuture<View> {
        fatalError()
    }

    public func loginView(on container: Container, loginWarning: Bool, errors: [String]?, username: String?, usernameError: Bool, passwordError: Bool, pageInformation: BlogGlobalPageInformation) throws -> EventLoopFuture<View> {
        fatalError()
    }
}

struct BlogPostPageContext: Encodable {
    let title: String
    let post: BlogPost
    let author: BlogUser
    let blogPostPage = true
    let pageInformation: BlogGlobalPageInformation
}
