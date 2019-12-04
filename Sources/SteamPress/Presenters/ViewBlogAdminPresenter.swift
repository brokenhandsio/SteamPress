import Vapor

public struct ViewBlogAdminPresenter: BlogAdminPresenter {
    public func createIndexView(on container: Container, errors: [String]?) -> EventLoopFuture<View> {
        do {
            let viewRenderer = try container.make(ViewRenderer.self)
            return viewRenderer.render("something")
        } catch {
            return container.future(error: error)
        }
    }
    
    public func createPostView(on container: Container, errors: [String]?, title: String?, contents: String?, slugURL: String?, tags: [String]?, isEditing: Bool, post: BlogPost?, isDraft: Bool?) -> EventLoopFuture<View> {
        do {
            let viewRenderer = try container.make(ViewRenderer.self)
            return viewRenderer.render("something")
        } catch {
            return container.future(error: error)
        }
    }
    
    public func createUserView(on container: Container, errors: [String]?, name: String?, username: String?, passwordError: Bool, confirmPasswordError: Bool, userID: Int?, profilePicture: String?, twitterHandle: String?, biography: String?, tagline: String?) -> EventLoopFuture<View> {
        do {
            let viewRenderer = try container.make(ViewRenderer.self)
            return viewRenderer.render("something")
        } catch {
            return container.future(error: error)
        }
    }
    
    public func createResetPasswordView(on container: Container, errors: [String]?, passwordError: Bool?, confirmPasswordError: Bool?) -> EventLoopFuture<View> {
        do {
            let viewRenderer = try container.make(ViewRenderer.self)
            return viewRenderer.render("something")
        } catch {
            return container.future(error: error)
        }
    }
    
    
}
