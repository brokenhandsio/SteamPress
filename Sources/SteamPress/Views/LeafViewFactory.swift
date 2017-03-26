import Vapor
import URI
import HTTP
import Paginator
import SwiftMarkdown
import SwiftSoup

struct LeafViewFactory: ViewFactory {

    let viewRenderer: ViewRenderer

    // MARK: - Admin Controller Views

    func createBlogPostView(uri: URI, errors: [String]? = nil, title: String? = nil, contents: String? = nil, slugUrl: String? = nil, tags: [Vapor.Node]? = nil, isEditing: Bool = false, postToEdit: BlogPost? = nil, draft: Bool = true) throws -> View {
        let titleError = (title == nil || (title?.isWhitespace())!) && errors != nil
        let contentsError = (contents == nil || (contents?.isWhitespace())!) && errors != nil

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

        var parameters = [
            "postPathPrefix": postPathPrefix.makeNode(),
            "titleError": titleError.makeNode(),
            "contentsError": contentsError.makeNode(),
            ]

        if let createBlogErrors = errors {
            parameters["errors"] = try createBlogErrors.makeNode()
        }

        if let titleSupplied = title {
            parameters["titleSupplied"] = titleSupplied.makeNode()
        }

        if let contentsSupplied = contents {
            parameters["contentsSupplied"] = contentsSupplied.makeNode()
        }

        if let slugUrlSupplied = slugUrl {
            parameters["slugUrlSupplied"] = slugUrlSupplied.makeNode()
        }

        if let tagsSupplied = tags, tagsSupplied.count > 0 {
            parameters["tagsSupplied"] = try tagsSupplied.makeNode()
        }
        
        if draft {
            parameters["draft"] = true.makeNode()
        }

        if isEditing {
            parameters["editing"] = isEditing.makeNode()
            guard let post = postToEdit else {
                throw Abort.badRequest
            }
            parameters["post"] = try post.makeNode()
        }
        else {
            parameters["createBlogPostPage"] = true
        }

        return try viewRenderer.make("blog/admin/createPost", parameters)
    }

    func createUserView(editing: Bool = false, errors: [String]? = nil, name: String? = nil, username: String? = nil, passwordError: Bool? = nil, confirmPasswordError: Bool? = nil, resetPasswordRequired: Bool? = nil, userId: Vapor.Node? = nil, profilePicture: String? = nil, twitterHandle: String? = nil, biography: String? = nil, tagline: String? = nil) throws -> View {
        let nameError = name == nil && errors != nil
        let usernameError = username == nil && errors != nil

        var parameters = [
            "nameError": nameError.makeNode(),
            "usernameError": usernameError.makeNode(),
            ]

        if let createUserErrors = errors {
            parameters["errors"] = try createUserErrors.makeNode()
        }

        if let nameSupplied = name {
            parameters["nameSupplied"] = nameSupplied.makeNode()
        }

        if let usernameSupplied = username {
            parameters["usernameSupplied"] = usernameSupplied.makeNode()
        }

        if let passwordError = passwordError {
            parameters["passwordError"] = passwordError.makeNode()
        }

        if let confirmPasswordError = confirmPasswordError {
            parameters["confirmPasswordError"] = confirmPasswordError.makeNode()
        }

        if let _ = resetPasswordRequired {
            parameters["resetPasswordOnLoginSupplied"] = true
        }
        
        if let profilePicture = profilePicture {
            parameters["profile_picture_supplied"] = profilePicture.makeNode()
        }
        
        if let twitterHandle = twitterHandle {
            parameters["twitter_handle_supplied"] = twitterHandle.makeNode()
        }
        
        if let biography = biography {
            parameters["biography_supplied"] = biography.makeNode()
        }
        
        if let tagline = tagline {
            parameters["tagline_supplied"] = tagline.makeNode()
        }

        if editing {
            parameters["editing"] = true
            guard let userId = userId else {
                throw Abort.badRequest
            }
            parameters["userId"] = userId
        }

        return try viewRenderer.make("blog/admin/createUser", parameters)
    }

    func createLoginView(loginWarning: Bool = false, errors: [String]? = nil, username: String? = nil, password: String? = nil) throws -> View {
        let usernameError = username == nil && errors != nil
        let passwordError = password == nil && errors != nil

        var parameters = [
            "usernameError": usernameError.makeNode(),
            "passwordError": passwordError.makeNode()
        ]

        if let usernameSupplied = username {
            parameters["usernameSupplied"] = usernameSupplied.makeNode()
        }

        if let loginErrors = errors {
            parameters["errors"] = try loginErrors.makeNode()
        }

        if loginWarning {
            parameters["loginWarning"] = true
        }

        return try viewRenderer.make("blog/admin/login", parameters)
    }

    func createBlogAdminView(errors: [String]? = nil) throws -> View {
        let publishedBlogPosts = try BlogPost.query().filter("published", true).sort("created", .descending).all()
        let draftBlogPosts = try BlogPost.query().filter("published", false).sort("created", .descending).all()
        let users = try BlogUser.all()

        var parameters = try Node(node: [
            "users": users.makeNode()
            ])

        if publishedBlogPosts.count > 0 {
            parameters["published_posts"] = try publishedBlogPosts.makeNode(context: BlogPostContext.all)
        }
        
        if draftBlogPosts.count > 0 {
            parameters["draft_posts"] = try draftBlogPosts.makeNode(context: BlogPostContext.all)
        }

        if let errors = errors {
            parameters["errors"] = try errors.makeNode()
        }

        parameters["blogAdminPage"] = true

        return try viewRenderer.make("blog/admin/index", parameters)
    }

    func createResetPasswordView(errors: [String]? = nil, passwordError: Bool? = nil, confirmPasswordError: Bool? = nil) throws -> View {

        var parameters: [String: Vapor.Node] = [:]

        if let resetPasswordErrors = errors {
            parameters["errors"] = try resetPasswordErrors.makeNode()
        }

        if let passwordError = passwordError {
            parameters["passwordError"] = passwordError.makeNode()
        }

        if let confirmPasswordError = confirmPasswordError {
            parameters["confirmPasswordError"] = confirmPasswordError.makeNode()
        }

        return try viewRenderer.make("blog/admin/resetPassword", parameters)
    }

    func createProfileView(uri: URI, author: BlogUser, isMyProfile: Bool, posts: [BlogPost], loggedInUser: BlogUser?, disqusName: String?, siteTwitterHandle: String?) throws -> View {
        var parameters: [String: Vapor.Node] = [
            "author": try author.makeNode(),
        ]

        if isMyProfile {
            parameters["myProfile"] = true.makeNode()
        }
        else {
            parameters["profilePage"] = true.makeNode()
        }

        if posts.count > 0 {
            parameters["posts"] = try posts.makeNode(context: BlogPostContext.shortSnippet)
        }
        
        return try createPublicView(template: "blog/profile", uri: uri, parameters: parameters, user: loggedInUser, disqusName: disqusName, siteTwitterHandle: siteTwitterHandle)
    }

    // MARK: - Blog Controller Views

    func blogIndexView(uri: URI, paginatedPosts: Paginator<BlogPost>, tags: [BlogTag], authors: [BlogUser], loggedInUser: BlogUser?, disqusName: String?, siteTwitterHandle: String?) throws -> View {

        var parameters: [String: Vapor.Node] = [
            "blogIndexPage": true.makeNode()
        ]

        if paginatedPosts.totalPages ?? 0 > 0 {
            parameters["posts"] = try paginatedPosts.makeNode(context: BlogPostContext.longSnippet)
        }

        if tags.count > 0 {
            parameters["tags"] = try tags.makeNode()
        }
        
        if authors.count > 0 {
            parameters["authors"] = try authors.makeNode()
        }
        
        return try createPublicView(template: "blog/blog", uri: uri, parameters: parameters, user: loggedInUser, disqusName: disqusName, siteTwitterHandle: siteTwitterHandle)
    }

    func blogPostView(uri: URI, post: BlogPost, author: BlogUser, user: BlogUser?, disqusName: String?, siteTwitterHandle: String?) throws -> View {
        
        var parameters: [String: NodeRepresentable] = [
            "post": try post.makeNode(context: BlogPostContext.all),
            "author": try author.makeNode(),
            "blogPostPage": true.makeNode(),
            "post_uri": uri.description.makeNode(),
            "post_uri_encoded": uri.description.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? uri.description,
            "site_uri": uri.getRootUri().description.makeNode(),
            "post_description": try SwiftSoup.parse(markdownToHTML(post.shortSnippet())).text().makeNode()
        ]
        
        let image = try SwiftSoup.parse(markdownToHTML(post.contents)).select("img").first()
        
        if let imageFound = image {
            parameters["post_image"] = try imageFound.attr("src").makeNode()
        }

        return try createPublicView(template: "blog/blogpost", uri: uri, parameters: parameters, user: user, disqusName: disqusName, siteTwitterHandle: siteTwitterHandle)
    }

    func tagView(uri: URI, tag: BlogTag, paginatedPosts: Paginator<BlogPost>, user: BlogUser?, disqusName: String?, siteTwitterHandle: String?) throws -> View {

        var parameters: [String: Vapor.Node] = [
            "tag": try tag.makeNode(context: BlogTagContext.withPostCount),
            "tagPage": true.makeNode(),
        ]

        if paginatedPosts.totalPages ?? 0 > 0 {
            parameters["posts"] = try paginatedPosts.makeNode(context: BlogPostContext.longSnippet)
        }
        
        return try createPublicView(template: "blog/tag", uri: uri, parameters: parameters, user: user, disqusName: disqusName, siteTwitterHandle: siteTwitterHandle)
    }
    
    func allTagsView(uri: URI, allTags: [BlogTag], user: BlogUser?, siteTwitterHandle: String?) throws -> View {
        var parameters: [String: NodeRepresentable] = [:]
        
        if allTags.count > 0 {
            let sortedTags = allTags.sorted { return (try? $0.blogPosts().count > $1.blogPosts().count) ?? false }
            parameters["tags"] = try sortedTags.makeNode(context: BlogTagContext.withPostCount)
        }
        
        return try createPublicView(template: "blog/tags", uri: uri, parameters: parameters, user: user, siteTwitterHandle: siteTwitterHandle)
    }
    
    func allAuthorsView(uri: URI, allAuthors: [BlogUser], user: BlogUser?, siteTwitterHandle: String?) throws -> View {
        var parameters: [String: NodeRepresentable] = [:]
        
        if allAuthors.count > 0 {
            let sortedAuthors = allAuthors.sorted { return (try? $0.posts().count > $1.posts().count) ?? false }
            parameters["authors"] = try sortedAuthors.makeNode(context: BlogUserContext.withPostCount)
        }
        
        return try createPublicView(template: "blog/authors", uri: uri, parameters: parameters, user: user, siteTwitterHandle: siteTwitterHandle)
    }
    
    private func createPublicView(template: String, uri: URI, parameters: [String: NodeRepresentable], user: BlogUser? = nil, disqusName: String? = nil, siteTwitterHandle: String? = nil) throws -> View {
        var viewParameters = parameters
        
        viewParameters["uri"] = uri.description.makeNode()
        
        if let user = user {
            viewParameters["user"] = try user.makeNode()
        }
        
        if let disqusName = disqusName {
            viewParameters["disqusName"] = disqusName.makeNode()
        }
        
        if let siteTwitterHandle = siteTwitterHandle {
            viewParameters["site_twitter_handle"] = siteTwitterHandle.makeNode()
        }
        
        return try viewRenderer.make(template, viewParameters.makeNode())
    }
}

extension URI {
    func getRootUri() -> URI {
        return URI(scheme: self.scheme, userInfo: nil, host: self.host, port: self.port, path: "", query: nil, rawQuery: nil, fragment: nil).removingPath()
    }
}
