//import Vapor
////import URI
//import HTTP
//import SwiftMarkdown
//import SwiftSoup
//import Foundation
//import Fluent
//
//struct LeafViewFactory: ViewFactory {
//
//    let viewRenderer: ViewRenderer
//    let disqusName: String?
//    let siteTwitterHandle: String?
//    let googleAnalyticsIdentifier: String?
//
//    // MARK: - Admin Controller Views
//
//    func createBlogPostView(uri: URI, errors: [String]? = nil, title: String? = nil, contents: String? = nil, slugUrl: String? = nil, tags: [Vapor.Node]? = nil, isEditing: Bool = false, postToEdit: BlogPost? = nil, draft: Bool = true, user: BlogUser) throws -> View {
//        let titleError = (title == nil || (title?.isWhitespace() ?? false)) && errors != nil
//        let contentsError = (contents == nil || (contents?.isWhitespace() ?? false)) && errors != nil
//
//        let postPathPrefix: String
//
//        if isEditing {
//            guard let editSubstringIndex = uri.descriptionWithoutPort.range(of: "admin/posts")?.lowerBound else {
//                throw Abort.serverError
//            }
//            #if swift(>=4)
//            postPathPrefix = uri.descriptionWithoutPort[..<editSubstringIndex] + "posts/"
//            #else
//            postPathPrefix = uri.descriptionWithoutPort.substring(to: editSubstringIndex) + "posts/"
//            #endif
//        } else {
//            postPathPrefix = uri.descriptionWithoutPort.replacingOccurrences(of: "admin/createPost", with: "posts")
//        }
//
//        var parameters: [String: NodeRepresentable] = [:]
//        parameters["post_path_prefix"] = postPathPrefix
//        parameters["title_error"] = titleError
//        parameters["contents_error"] = contentsError
//        parameters["user"] = user
//
//        if let createBlogErrors = errors {
//            parameters["errors"] = try createBlogErrors.makeNode(in: nil)
//        }
//
//        if let titleSupplied = title {
//            parameters["title_supplied"] = titleSupplied
//        }
//
//        if let contentsSupplied = contents {
//            parameters["contents_supplied"] = contentsSupplied
//        }
//
//        if let slugUrlSupplied = slugUrl {
//            parameters["slug_url_supplied"] = slugUrlSupplied
//        }
//
//        if let tagsSupplied = tags, !tagsSupplied.isEmpty {
//            parameters["tags_supplied"] = try tagsSupplied.makeNode(in: nil)
//        }
//
//        if draft {
//            parameters["draft"] = true
//        }
//
//        if isEditing {
//            parameters["editing"] = isEditing
//            guard let post = postToEdit else {
//                throw Abort.badRequest
//            }
//            parameters["post"] = try post.makeNode(in: BlogPostContext.all)
//        } else {
//            parameters["create_blog_post_page"] = true
//        }
//
//        return try viewRenderer.make("blog/admin/createPost", parameters)
//    }
//
//    func createUserView(editing: Bool = false, errors: [String]? = nil, name: String? = nil, username: String? = nil, passwordError: Bool? = nil, confirmPasswordError: Bool? = nil, resetPasswordRequired: Bool? = nil, userId: Identifier? = nil, profilePicture: String? = nil, twitterHandle: String? = nil, biography: String? = nil, tagline: String? = nil, loggedInUser: BlogUser) throws -> View {
//        let nameError = name == nil && errors != nil
//        let usernameError = username == nil && errors != nil
//
//        var parameters: [String: NodeRepresentable] = [:]
//        parameters["name_error"] = nameError
//        parameters["username_error"] = usernameError
//        parameters["user"] = loggedInUser
//
//        if let createUserErrors = errors {
//            parameters["errors"] = try createUserErrors.makeNode(in: nil)
//        }
//
//        if let nameSupplied = name {
//            parameters["name_supplied"] = nameSupplied
//        }
//
//        if let usernameSupplied = username {
//            parameters["username_supplied"] = usernameSupplied
//        }
//
//        if let passwordError = passwordError {
//            parameters["password_error"] = passwordError
//        }
//
//        if let confirmPasswordError = confirmPasswordError {
//            parameters["confirm_password_error"] = confirmPasswordError
//        }
//
//        if resetPasswordRequired != nil {
//            parameters["reset_password_on_login_supplied"] = true
//        }
//
//        if let profilePicture = profilePicture {
//            parameters["profile_picture_supplied"] = profilePicture
//        }
//
//        if let twitterHandle = twitterHandle {
//            parameters["twitter_handle_supplied"] = twitterHandle
//        }
//
//        if let biography = biography {
//            parameters["biography_supplied"] = biography
//        }
//
//        if let tagline = tagline {
//            parameters["tagline_supplied"] = tagline
//        }
//
//        if editing {
//            parameters["editing"] = true
//            guard let userId = userId else {
//                throw Abort.badRequest
//            }
//            parameters["user_id"] = userId
//        }
//
//        return try viewRenderer.make("blog/admin/createUser", parameters)
//    }
//
//    func createLoginView(loginWarning: Bool = false, errors: [String]? = nil, username: String? = nil, password: String? = nil) throws -> View {
//        let usernameError = username == nil && errors != nil
//        let passwordError = password == nil && errors != nil
//
//        var parameters: [String: Vapor.Node] = [:]
//        parameters["username_error"] = usernameError.makeNode(in: nil)
//        parameters["password_error"] = passwordError.makeNode(in: nil)
//
//        if let usernameSupplied = username {
//            parameters["username_supplied"] = usernameSupplied.makeNode(in: nil)
//        }
//
//        if let loginErrors = errors {
//            parameters["errors"] = try loginErrors.makeNode(in: nil)
//        }
//
//        if loginWarning {
//            parameters["login_warning"] = true
//        }
//
//        return try viewRenderer.make("blog/admin/login", parameters)
//    }
//
//    func createBlogAdminView(errors: [String]? = nil, user: BlogUser) throws -> View {
//        let publishedBlogPosts = try BlogPost.makeQuery().filter(BlogPost.Properties.published, true).sort(BlogPost.Properties.created, .descending).all()
//        let draftBlogPosts = try BlogPost.makeQuery().filter(BlogPost.Properties.published, false).sort(BlogPost.Properties.created, .descending).all()
//        let users = try BlogUser.all()
//
//        var parameters: [String: Vapor.Node] = [:]
//        parameters["users"] = try users.makeNode(in: nil)
//        parameters["user"] = try user.makeNode(in: nil)
//
//        if !publishedBlogPosts.isEmpty {
//            parameters["published_posts"] = try publishedBlogPosts.makeNode(in: BlogPostContext.all)
//        }
//
//        if !draftBlogPosts.isEmpty {
//            parameters["draft_posts"] = try draftBlogPosts.makeNode(in: BlogPostContext.all)
//        }
//
//        if let errors = errors {
//            parameters["errors"] = try errors.makeNode(in: nil)
//        }
//
//        parameters["blog_admin_page"] = true
//
//        return try viewRenderer.make("blog/admin/index", parameters)
//    }
//
//    func createResetPasswordView(errors: [String]? = nil, passwordError: Bool? = nil, confirmPasswordError: Bool? = nil, user: BlogUser) throws -> View {
//
//        var parameters: [String: Vapor.Node] = [:]
//        parameters["user"] = try user.makeNode(in: nil)
//
//        if let resetPasswordErrors = errors {
//            parameters["errors"] = try resetPasswordErrors.makeNode(in: nil)
//        }
//
//        if let passwordError = passwordError {
//            parameters["password_error"] = passwordError.makeNode(in: nil)
//        }
//
//        if let confirmPasswordError = confirmPasswordError {
//            parameters["confirm_password_error"] = confirmPasswordError.makeNode(in: nil)
//        }
//
//        return try viewRenderer.make("blog/admin/resetPassword", parameters)
//    }
//
//    // MARK: - Blog Controller Views
//
//    func blogIndexView(uri: URI, paginatedPosts: Page<BlogPost>, tags: [BlogTag], authors: [BlogUser], loggedInUser: BlogUser?) throws -> View {
//
//        var parameters: [String: Vapor.Node] = [:]
//        parameters["blog_index_page"] = true.makeNode(in: nil)
//
//        if paginatedPosts.total > 0 {
//            parameters["posts"] = try paginatedPosts.makeNode(for: uri, in: BlogPostContext.longSnippet)
//        }
//
//        if !tags.isEmpty {
//            parameters["tags"] = try tags.makeNode(in: nil)
//        }
//
//        if !authors.isEmpty {
//            parameters["authors"] = try authors.makeNode(in: nil)
//        }
//
//        return try createPublicView(template: "blog/blog", uri: uri, parameters: parameters, user: loggedInUser)
//    }
//
//    func blogPostView(uri: URI, post: BlogPost, author: BlogUser, user: BlogUser?) throws -> View {
//
//        var parameters: [String: Vapor.Node] = [:]
//        parameters["post"] = try post.makeNode(in: BlogPostContext.all)
//        parameters["author"] = try author.makeNode(in: nil)
//        parameters["blog_post_page"] = true.makeNode(in: nil)
//        parameters["post_uri"] = uri.descriptionWithoutPort.makeNode(in: nil)
//        parameters["post_uri_encoded"] = uri.descriptionWithoutPort.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)?.makeNode(in: nil) ?? uri.descriptionWithoutPort.makeNode(in: nil)
//        parameters["site_uri"] = uri.getRootUri().descriptionWithoutPort.makeNode(in: nil)
//        parameters["post_description"] = try post.description().makeNode(in: nil)
//
//        let image = try SwiftSoup.parse(markdownToHTML(post.contents)).select("img").first()
//
//        if let imageFound = image {
//            parameters["post_image"] = try imageFound.attr("src").makeNode(in: nil)
//            do {
//                let imageAlt = try imageFound.attr("alt")
//                if imageAlt != "" {
//                    parameters["post_image_alt"] = imageAlt.makeNode(in: nil)
//                }
//            } catch {}
//        }
//
//        return try createPublicView(template: "blog/blogpost", uri: uri, parameters: parameters, user: user)
//    }
//
//    func tagView(uri: URI, tag: BlogTag, paginatedPosts: Page<BlogPost>, user: BlogUser?) throws -> View {
//
//        var parameters: [String: NodeRepresentable] = [:]
//        parameters["tag"] = try tag.makeNode(in: BlogTagContext.withPostCount)
//        parameters["tag_page"] = true
//
//        if paginatedPosts.total > 0 {
//            parameters["posts"] = try paginatedPosts.makeNode(for: uri, in: BlogPostContext.longSnippet)
//        }
//
//        return try createPublicView(template: "blog/tag", uri: uri, parameters: parameters, user: user)
//    }
//
//    func allTagsView(uri: URI, allTags: [BlogTag], user: BlogUser?) throws -> View {
//        var parameters: [String: NodeRepresentable] = [:]
//
//        if !allTags.isEmpty {
//            let sortedTags = allTags.sorted { return (try? $0.sortedPosts().count() > $1.sortedPosts().count()) ?? false }
//            parameters["tags"] = try sortedTags.makeNode(in: BlogTagContext.withPostCount)
//        }
//
//        return try createPublicView(template: "blog/tags", uri: uri, parameters: parameters, user: user)
//    }
//
//    func allAuthorsView(uri: URI, allAuthors: [BlogUser], user: BlogUser?) throws -> View {
//        var parameters: [String: NodeRepresentable] = [:]
//
//        if !allAuthors.isEmpty {
//            let sortedAuthors = allAuthors.sorted { return (try? $0.sortedPosts().count() > $1.sortedPosts().count()) ?? false }
//            parameters["authors"] = try sortedAuthors.makeNode(in: BlogUserContext.withPostCount)
//        }
//
//        return try createPublicView(template: "blog/authors", uri: uri, parameters: parameters, user: user)
//    }
//    
//    func profileView(uri: URI, author: BlogUser, paginatedPosts: Page<BlogPost>, loggedInUser: BlogUser?) throws -> View {
//        var parameters: [String: Vapor.Node] = [:]
//        parameters["author"] = try author.makeNode(in: BlogUserContext.withPostCount)
//        
//        parameters["profile_page"] = true.makeNode(in: nil)
//        
//        if paginatedPosts.total > 0 {
//            parameters["posts"] = try paginatedPosts.makeNode(for: uri, in: BlogPostContext.longSnippet)
//        }
//        
//        return try createPublicView(template: "blog/profile", uri: uri, parameters: parameters, user: loggedInUser)
//    }
//    
//    func searchView(uri: URI, searchTerm: String?, foundPosts: Page<BlogPost>?, emptySearch: Bool, user: BlogUser?) throws -> View {
//        var parameters: [String: Vapor.Node] = [:]
//        
//        let searchCount = foundPosts?.total ?? 0
//        if searchCount > 0 {
//            parameters["posts"] = try foundPosts?.makeNode(for: uri, in: BlogPostContext.longSnippet)
//        }
//        
//        parameters["searchCount"] = searchCount.makeNode(in: nil)
//        
//        if emptySearch {
//            parameters["emptySearch"] = true
//        }
//        
//        if let searchTerm = searchTerm {
//            parameters["searchTerm"] = searchTerm.makeNode(in: nil)
//        }
//        
//        return try createPublicView(template: "blog/search", uri: uri, parameters: parameters, user: user)
//    }
//
//    private func createPublicView(template: String, uri: URI, parameters: [String: NodeRepresentable], user: BlogUser? = nil) throws -> View {
//        var viewParameters = parameters
//
//        viewParameters["uri"] = uri.descriptionWithoutPort.makeNode(in: nil)
//
//        if let user = user {
//            viewParameters["user"] = try user.makeNode(in: nil)
//        }
//
//        if let disqusName = disqusName {
//            viewParameters["disqus_name"] = disqusName.makeNode(in: nil)
//        }
//
//        if let siteTwitterHandle = siteTwitterHandle {
//            viewParameters["site_twitter_handle"] = siteTwitterHandle.makeNode(in: nil)
//        }
//        
//        if let googleAnalyticsIdentifier = googleAnalyticsIdentifier {
//            viewParameters["google_analytics_identifier"] = googleAnalyticsIdentifier.makeNode(in: nil)
//        }
//
//        return try viewRenderer.make(template, viewParameters.makeNode(in: nil))
//    }
//    
//}
//
//extension URI {
//    func getRootUri() -> URI {
//        return URI(scheme: self.scheme, userInfo: nil, hostname: self.hostname, port: self.port, path: "", query: nil, fragment: nil).removingPath()
//    }
//
//    var descriptionWithoutPort: String {
//        get {
//            if scheme.isSecure {
//                return self.description.replacingFirstOccurrence(of: ":443", with: "")
//            }
//            else {
//                return self.description.replacingFirstOccurrence(of: ":80", with: "")
//            }
//        }
//    }
//}
//
//public extension BlogPost {
//    func description() throws -> String {
//        return try SwiftSoup.parse(markdownToHTML(shortSnippet())).text()
//    }
//}
//
//private extension String {
//    func replacingFirstOccurrence(of target: String, with replaceString: String) -> String
//    {
//        if let range = self.range(of: target) {
//            return self.replacingCharacters(in: range, with: replaceString)
//        }
//        return self
//    }
//}

