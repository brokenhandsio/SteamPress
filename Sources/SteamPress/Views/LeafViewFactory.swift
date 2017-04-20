import Vapor
import URI
import HTTP
//import Paginator
import SwiftMarkdown
import SwiftSoup
import Foundation

struct LeafViewFactory: ViewFactory {

    let viewRenderer: ViewRenderer

    // MARK: - Admin Controller Views

    func createBlogPostView(uri: URI, errors: [String]? = nil, title: String? = nil, contents: String? = nil, slugUrl: String? = nil, tags: [Vapor.Node]? = nil, isEditing: Bool = false, postToEdit: BlogPost? = nil, draft: Bool = true) throws -> View {
        let titleError = (title == nil || (title?.isWhitespace() ?? false)) && errors != nil
        let contentsError = (contents == nil || (contents?.isWhitespace() ?? false)) && errors != nil

        let postPathPrefix: String

        if isEditing {
            guard let editSubstringIndex = uri.description.range(of: "admin/posts")?.lowerBound else {
                throw Abort.serverError
            }
            postPathPrefix = uri.description.substring(to: editSubstringIndex) + "posts/"
        }
        else {
            postPathPrefix = uri.description.replacingOccurrences(of: "admin/createPost", with: "posts")
        }

        var parameters: [String: NodeRepresentable] = [:]
        parameters["post_path_prefix"] = postPathPrefix
        parameters["title_error"] = titleError
        parameters["contents_error"] = contentsError

        if let createBlogErrors = errors {
            parameters["errors"] = try createBlogErrors.makeNode(in: nil)
        }

        if let titleSupplied = title {
            parameters["title_supplied"] = titleSupplied
        }

        if let contentsSupplied = contents {
            parameters["contents_supplied"] = contentsSupplied
        }

        if let slugUrlSupplied = slugUrl {
            parameters["slug_url_supplied"] = slugUrlSupplied
        }

        if let tagsSupplied = tags, tagsSupplied.count > 0 {
            parameters["tags_supplied"] = try tagsSupplied.makeNode(in: nil)
        }

        if draft {
            parameters["draft"] = true
        }

        if isEditing {
            parameters["editing"] = isEditing
            guard let post = postToEdit else {
                throw Abort.badRequest
            }
            parameters["post"] = try post.makeNode(in: BlogPostContext.all)
        }
        else {
            parameters["create_blog_post_page"] = true
        }

        return try viewRenderer.make("blog/admin/createPost", parameters)
    }

    func createUserView(editing: Bool = false, errors: [String]? = nil, name: String? = nil, username: String? = nil, passwordError: Bool? = nil, confirmPasswordError: Bool? = nil, resetPasswordRequired: Bool? = nil, userId: Vapor.Node? = nil, profilePicture: String? = nil, twitterHandle: String? = nil, biography: String? = nil, tagline: String? = nil) throws -> View {
        let nameError = name == nil && errors != nil
        let usernameError = username == nil && errors != nil

        var parameters: [String: NodeRepresentable] = [:]
        parameters["name_error"] = nameError
        parameters["username_error"] = usernameError

        if let createUserErrors = errors {
            parameters["errors"] = try createUserErrors.makeNode(in: nil)
        }

        if let nameSupplied = name {
            parameters["name_supplied"] = nameSupplied
        }

        if let usernameSupplied = username {
            parameters["username_supplied"] = usernameSupplied
        }

        if let passwordError = passwordError {
            parameters["password_error"] = passwordError
        }

        if let confirmPasswordError = confirmPasswordError {
            parameters["confirm_password_error"] = confirmPasswordError
        }

        if let _ = resetPasswordRequired {
            parameters["reset_password_on_login_supplied"] = true
        }

        if let profilePicture = profilePicture {
            parameters["profile_picture_supplied"] = profilePicture
        }

        if let twitterHandle = twitterHandle {
            parameters["twitter_handle_supplied"] = twitterHandle
        }

        if let biography = biography {
            parameters["biography_supplied"] = biography
        }

        if let tagline = tagline {
            parameters["tagline_supplied"] = tagline
        }

        if editing {
            parameters["editing"] = true
            guard let userId = userId else {
                throw Abort.badRequest
            }
            parameters["user_id"] = userId
        }

        return try viewRenderer.make("blog/admin/createUser", parameters)
    }

    func createLoginView(loginWarning: Bool = false, errors: [String]? = nil, username: String? = nil, password: String? = nil) throws -> View {
        let usernameError = username == nil && errors != nil
        let passwordError = password == nil && errors != nil

        var parameters: [String: Vapor.Node] = [:]
        parameters["username_error"] = usernameError.makeNode(in: nil)
        parameters["password_error"] = passwordError.makeNode(in: nil)

        if let usernameSupplied = username {
            parameters["username_supplied"] = usernameSupplied.makeNode(in: nil)
        }

        if let loginErrors = errors {
            parameters["errors"] = try loginErrors.makeNode(in: nil)
        }

        if loginWarning {
            parameters["login_warning"] = true
        }

        return try viewRenderer.make("blog/admin/login", parameters)
    }

    func createBlogAdminView(errors: [String]? = nil) throws -> View {
        let publishedBlogPosts = try BlogPost.makeQuery().filter("published", true).sort("created", .descending).all()
        let draftBlogPosts = try BlogPost.makeQuery().filter("published", false).sort("created", .descending).all()
        let users = try BlogUser.all()

        var parameters: [String: Vapor.Node] = [:]
        parameters["users"] = try users.makeNode(in: nil
        )

        if publishedBlogPosts.count > 0 {
            parameters["published_posts"] = try publishedBlogPosts.makeNode(in: BlogPostContext.all)
        }

        if draftBlogPosts.count > 0 {
            parameters["draft_posts"] = try draftBlogPosts.makeNode(in: BlogPostContext.all)
        }

        if let errors = errors {
            parameters["errors"] = try errors.makeNode(in: nil)
        }

        parameters["blog_admin_page"] = true

        return try viewRenderer.make("blog/admin/index", parameters)
    }

    func createResetPasswordView(errors: [String]? = nil, passwordError: Bool? = nil, confirmPasswordError: Bool? = nil) throws -> View {

        var parameters: [String: Vapor.Node] = [:]

        if let resetPasswordErrors = errors {
            parameters["errors"] = try resetPasswordErrors.makeNode(in: nil)
        }

        if let passwordError = passwordError {
            parameters["password_error"] = passwordError.makeNode(in: nil)
        }

        if let confirmPasswordError = confirmPasswordError {
            parameters["confirm_password_error"] = confirmPasswordError.makeNode(in: nil)
        }

        return try viewRenderer.make("blog/admin/resetPassword", parameters)
    }

    func createProfileView(uri: URI, author: BlogUser, isMyProfile: Bool, paginatedPosts: Paginator<BlogPost>, loggedInUser: BlogUser?, disqusName: String?, siteTwitterHandle: String?) throws -> View {
        var parameters: [String: Vapor.Node] = [:]
        parameters["author"] = try author.makeNode(in: BlogUserContext.withPostCount)

        if isMyProfile {
            parameters["my_profile"] = true.makeNode(in: nil)
        }
        else {
            parameters["profile_page"] = true.makeNode(in: nil)
        }

        if paginatedPosts.totalPages ?? 0 > 0 {
            parameters["posts"] = try paginatedPosts.makeNode(context: BlogPostContext.longSnippet)
        }

        return try createPublicView(template: "blog/profile", uri: uri, parameters: parameters, user: loggedInUser, disqusName: disqusName, siteTwitterHandle: siteTwitterHandle)
    }

    // MARK: - Blog Controller Views

    func blogIndexView(uri: URI, paginatedPosts: Paginator<BlogPost>, tags: [BlogTag], authors: [BlogUser], loggedInUser: BlogUser?, disqusName: String?, siteTwitterHandle: String?) throws -> View {

        var parameters: [String: Vapor.Node] = [:]
        parameters["blog_index_page"] = true.makeNode(in: nil)

        if paginatedPosts.totalPages ?? 0 > 0 {
            parameters["posts"] = try paginatedPosts.makeNode(context: BlogPostContext.longSnippet)
        }

        if tags.count > 0 {
            parameters["tags"] = try tags.makeNode(in: nil)
        }

        if authors.count > 0 {
            parameters["authors"] = try authors.makeNode(in: nil)
        }

        return try createPublicView(template: "blog/blog", uri: uri, parameters: parameters, user: loggedInUser, disqusName: disqusName, siteTwitterHandle: siteTwitterHandle)
    }

    func blogPostView(uri: URI, post: BlogPost, author: BlogUser, user: BlogUser?, disqusName: String?, siteTwitterHandle: String?) throws -> View {

        var parameters: [String: Vapor.Node] = [:]
        parameters["post"] = try post.makeNode(in: BlogPostContext.all)
        parameters["author"] = try author.makeNode(in: nil)
        parameters["blog_post_page"] = true.makeNode(in: nil)
        parameters["post_uri"] = uri.description.makeNode(in: nil)
        parameters["post_uri_encoded"] = uri.description.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)?.makeNode(in: nil) ?? uri.description.makeNode(in: nil)
        parameters["site_uri"] = uri.getRootUri().description.makeNode(in: nil)
        parameters["post_description"] = try SwiftSoup.parse(markdownToHTML(post.shortSnippet())).text().makeNode(in: nil)

        let image = try SwiftSoup.parse(markdownToHTML(post.contents)).select("img").first()

        if let imageFound = image {
            parameters["post_image"] = try imageFound.attr("src").makeNode(in: nil)
            do {
                let imageAlt = try imageFound.attr("alt")
                if imageAlt != "" {
                    parameters["post_image_alt"] = imageAlt.makeNode(in: nil)
                }
            } catch {}
        }

        return try createPublicView(template: "blog/blogpost", uri: uri, parameters: parameters, user: user, disqusName: disqusName, siteTwitterHandle: siteTwitterHandle)
    }

    func tagView(uri: URI, tag: BlogTag, paginatedPosts: Paginator<BlogPost>, user: BlogUser?, disqusName: String?, siteTwitterHandle: String?) throws -> View {

        var parameters: [String: NodeRepresentable] = [:]
        parameters["tag"] = try tag.makeNode(in: BlogTagContext.withPostCount)
        parameters["tag_page"] = true

        if paginatedPosts.totalPages ?? 0 > 0 {
            parameters["posts"] = try paginatedPosts.makeNode(in: BlogPostContext.longSnippet)
        }

        return try createPublicView(template: "blog/tag", uri: uri, parameters: parameters, user: user, disqusName: disqusName, siteTwitterHandle: siteTwitterHandle)
    }

    func allTagsView(uri: URI, allTags: [BlogTag], user: BlogUser?, siteTwitterHandle: String?) throws -> View {
        var parameters: [String: NodeRepresentable] = [:]

        if allTags.count > 0 {
            let sortedTags = allTags.sorted { return (try? $0.blogPosts().count > $1.blogPosts().count) ?? false }
            parameters["tags"] = try sortedTags.makeNode(in: BlogTagContext.withPostCount)
        }

        return try createPublicView(template: "blog/tags", uri: uri, parameters: parameters, user: user, siteTwitterHandle: siteTwitterHandle)
    }

    func allAuthorsView(uri: URI, allAuthors: [BlogUser], user: BlogUser?, siteTwitterHandle: String?) throws -> View {
        var parameters: [String: NodeRepresentable] = [:]

        if allAuthors.count > 0 {
            let sortedAuthors = allAuthors.sorted { return (try? $0.posts().count > $1.posts().count) ?? false }
            parameters["authors"] = try sortedAuthors.makeNode(in: BlogUserContext.withPostCount)
        }

        return try createPublicView(template: "blog/authors", uri: uri, parameters: parameters, user: user, siteTwitterHandle: siteTwitterHandle)
    }

    private func createPublicView(template: String, uri: URI, parameters: [String: NodeRepresentable], user: BlogUser? = nil, disqusName: String? = nil, siteTwitterHandle: String? = nil) throws -> View {
        var viewParameters = parameters

        viewParameters["uri"] = uri.description.makeNode(in: nil)

        if let user = user {
            viewParameters["user"] = try user.makeNode(in: nil)
        }

        if let disqusName = disqusName {
            viewParameters["disqus_name"] = disqusName.makeNode(in: nil)
        }

        if let siteTwitterHandle = siteTwitterHandle {
            viewParameters["site_twitter_handle"] = siteTwitterHandle.makeNode(in: nil)
        }

        return try viewRenderer.make(template, viewParameters.makeNode(in: nil))
    }
}

extension URI {
    func getRootUri() -> URI {
        return URI(scheme: self.scheme, userInfo: nil, hostname: self.hostname, port: self.port, path: "", query: nil, rawQuery: nil, fragment: nil).removingPath()
    }
}
