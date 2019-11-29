import Vapor
import SwiftSoup
import SwiftMarkdown

public struct ViewBlogPresenter: BlogPresenter {

    public func indexView(on container: Container, posts: [BlogPost], tags: [BlogTag], authors: [BlogUser], pageInformation: BlogGlobalPageInformation) -> EventLoopFuture<View> {
        fatalError()
    }

    public func postView(on container: Container, post: BlogPost, author: BlogUser, pageInformation: BlogGlobalPageInformation) -> EventLoopFuture<View> {
        do {
            let viewRenderer = try container.make(ViewRenderer.self)
            
            var postImage: String? = nil
            var postImageAlt: String? = nil
            if let image = try SwiftSoup.parse(markdownToHTML(post.contents)).select("img").first() {
                postImage = try image.attr("src")
                let imageAlt = try image.attr("alt")
                if imageAlt != "" {
                    postImageAlt = imageAlt
                }
            }
            let shortSnippet = post.shortSnippet()
            
            let context = BlogPostPageContext(title: post.title, post: post, author: author, pageInformation: pageInformation, postImage: postImage, postImageAlt: postImageAlt, shortSnippet: shortSnippet)
            return viewRenderer.render("blog/post", context)
        } catch {
            return container.future(error: error)
        }

    }

    public func allAuthorsView(on container: Container, authors: [BlogUser], pageInformation: BlogGlobalPageInformation) -> EventLoopFuture<View> {
        do {
            let viewRenderer = try container.make(ViewRenderer.self)
            let context = AllAuthorsPageContext(pageInformation: pageInformation)
            return viewRenderer.render("something", context)
        } catch {
            return container.future(error: error)
        }
    }

    public func authorView(on container: Container, author: BlogUser, posts: [BlogPost], pageInformation: BlogGlobalPageInformation) -> EventLoopFuture<View> {
        fatalError()
    }

    public func allTagsView(on container: Container, tags: [BlogTag], pageInformation: BlogGlobalPageInformation) -> EventLoopFuture<View> {
        let context = AllTagsPageContext(title: "All Tags", tags: tags, pageInformation: pageInformation)
        do {
            let viewRenderer = try container.make(ViewRenderer.self)
            return viewRenderer.render("blog/tags", context)
        } catch {
            return container.future(error: error)
        }
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
