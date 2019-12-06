import Vapor

public struct ViewBlogAdminPresenter: BlogAdminPresenter {
    public func createIndexView(on container: Container, posts: [BlogPost], users: [BlogUser], errors: [String]?, pageInformation: BlogAdminPageInformation) -> EventLoopFuture<View> {
        do {
            let viewRenderer = try container.make(ViewRenderer.self)
            let publishedPosts = posts.filter { $0.published }
            let draftPosts = posts.filter { !$0.published }
            let context = AdminPageContext(errors: errors, publishedPosts: publishedPosts, draftPosts: draftPosts, users: users, pageInformation: pageInformation)
            return viewRenderer.render("blog/admin/index", context)
        } catch {
            return container.future(error: error)
        }
    }
    
    public func createPostView(on container: Container, errors: [String]?, title: String?, contents: String?, slugURL: String?, tags: [String]?, isEditing: Bool, post: BlogPost?, isDraft: Bool?, pageInformation: BlogAdminPageInformation) -> EventLoopFuture<View> {
        do {
            let viewRenderer = try container.make(ViewRenderer.self)
            return viewRenderer.render("something")
        } catch {
            return container.future(error: error)
        }
    }
    
    public func createUserView(on container: Container, editing: Bool, errors: [String]?, name: String?, nameError: Bool, username: String?, usernameErorr: Bool, passwordError: Bool, confirmPasswordError: Bool, resetPasswordOnLogin: Bool, userID: Int?, profilePicture: String?, twitterHandle: String?, biography: String?, tagline: String?, pageInformation: BlogAdminPageInformation) -> EventLoopFuture<View> {
        do {
            if editing {
                guard userID != nil else {
                    return container.future(error: SteamPressError(identifier: "ViewBlogAdminPresenter", "User ID is nil whilst editing"))
                }
            }
            
            let viewRenderer = try container.make(ViewRenderer.self)
            let context = CreateUserPageContext(editing: editing, errors: errors, nameSupplied: name, nameError: nameError, usernameSupplied: username, usernameError: usernameErorr, passwordError: passwordError, confirmPasswordError: confirmPasswordError, resetPasswordOnLoginSupplied: resetPasswordOnLogin, userID: userID, twitterHandleSupplied: twitterHandle, profilePictureSupplied: profilePicture, biographySupplied: biography, taglineSupplied: tagline, pageInformation: pageInformation)
            return viewRenderer.render("blog/admin/createUser", context)
        } catch {
            return container.future(error: error)
        }
    }
    
    public func createResetPasswordView(on container: Container, errors: [String]?, passwordError: Bool?, confirmPasswordError: Bool?, pageInformation: BlogAdminPageInformation) -> EventLoopFuture<View> {
        do {
            let viewRenderer = try container.make(ViewRenderer.self)
            let context = ResetPasswordPageContext(errors: errors, passwordError: passwordError, confirmPasswordError: confirmPasswordError, pageInformation: pageInformation)
            return viewRenderer.render("blog/admin/resetPassword", context)
        } catch {
            return container.future(error: error)
        }
    }
    
    
}
