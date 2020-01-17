import Vapor

public struct ViewBlogAdminPresenter: BlogAdminPresenter {

    let pathCreator: BlogPathCreator

    public func createIndexView(on container: Container, posts: [BlogPost], users: [BlogUser], errors: [String]?, pageInformation: BlogAdminPageInformation) -> EventLoopFuture<View> {
        do {
            let viewRenderer = try container.make(ViewRenderer.self)
            let publishedPosts = try posts.filter { $0.published }.convertToViewBlogPostsWithoutTags(authors: users, on: container)
            let draftPosts = try posts.filter { !$0.published }.convertToViewBlogPostsWithoutTags(authors: users, on: container)
            let context = AdminPageContext(errors: errors, publishedPosts: publishedPosts, draftPosts: draftPosts, users: users, pageInformation: pageInformation)
            return viewRenderer.render("blog/admin/index", context)
        } catch {
            return container.future(error: error)
        }
    }

    public func createPostView(on container: Container, errors: [String]?, title: String?, contents: String?, slugURL: String?, tags: [String]?, isEditing: Bool, post: BlogPost?, isDraft: Bool?, titleError: Bool, contentsError: Bool, pageInformation: BlogAdminPageInformation) -> EventLoopFuture<View> {
        do {
            if isEditing {
                guard post != nil else {
                    return container.future(error: SteamPressError(identifier: "ViewBlogAdminPresenter", "Blog Post is empty whilst editing"))
                }
            }
            let viewRenderer = try container.make(ViewRenderer.self)
            let postPathSuffix = pathCreator.createPath(for: "posts")
            let postPathPrefix = pageInformation.websiteURL.appendingPathComponent(postPathSuffix)
            let pageTitle = isEditing ? "Edit Blog Post" : "Create Blog Post"
            let context = CreatePostPageContext(title: pageTitle, editing: isEditing, post: post, draft: isDraft ?? false, errors: errors, titleSupplied: title, contentsSupplied: contents, tagsSupplied: tags, slugURLSupplied: slugURL, titleError: titleError, contentsError: contentsError, postPathPrefix: postPathPrefix.absoluteString, pageInformation: pageInformation)
            return viewRenderer.render("blog/admin/createPost", context)
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
