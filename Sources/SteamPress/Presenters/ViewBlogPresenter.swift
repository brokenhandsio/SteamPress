import Vapor

public struct ViewBlogPresenter: BlogPresenter {
    
    public func indexView(on container: Container, posts: [BlogPost], tags: [BlogTag], authors: [BlogUser]) -> EventLoopFuture<View> {
        fatalError()
    }
    
    public func postView(on container: Container, post: BlogPost, author: BlogUser) -> EventLoopFuture<View> {
        do {
            let viewRenderer = try container.make(ViewRenderer.self)
            return viewRenderer.render("blog/post")
        } catch {
            return container.eventLoop.newFailedFuture(error: SteamPressError(identifier: "ViewBlogPresenterError", "Failed to get a view renderer"))
        }
        
    }
    
    public func allAuthorsView(on container: Container, authors: [BlogUser]) -> EventLoopFuture<View> {
        fatalError()
    }
    
    public func authorView(on container: Container, author: BlogUser, posts: [BlogPost]) -> EventLoopFuture<View> {
        fatalError()
    }
    
    public func allTagsView(on container: Container, tags: [BlogTag]) -> EventLoopFuture<View> {
        fatalError()
    }
    
    public func tagView(on container: Container, tag: BlogTag, posts: [BlogPost]) -> EventLoopFuture<View> {
        fatalError()
    }
    
    public func searchView(on container: Container, posts: [BlogPost]?, searchTerm: String?) -> EventLoopFuture<View> {
        fatalError()
    }
    
    public func loginView(on container: Container, loginWarning: Bool, errors: [String]?, username: String?, usernameError: Bool, passwordError: Bool) throws -> EventLoopFuture<View> {
        fatalError()
    }
}
