import Vapor
import URI
import HTTP
import SwiftMarkdown
import SwiftSoup
import Foundation
import Fluent

struct BlogLeafViewFactory: BlogViewFactory {

    let viewFactory: ViewFactory

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

        return try viewFactory.viewRenderer.make("blog/admin/login", parameters)
    }

    func createBlogAdminView(errors: [String]? = nil, user: BlogUser) throws -> View {
        let publishedBlogPosts = try BlogPost.makeQuery().filter(BlogPost.Properties.published, true).sort(BlogPost.Properties.created, .descending).all()
        let links = try BlogLink.all()

        let draftBlogPosts = try BlogPost.makeQuery().filter(BlogPost.Properties.published, false).sort(BlogPost.Properties.created, .descending).all()
        let users = try BlogUser.all()

        var parameters: [String: Vapor.Node] = [:]
        parameters["users"] = try users.makeNode(in: nil)
        parameters["user"] = try user.makeNode(in: nil)

        if !publishedBlogPosts.isEmpty {
            parameters["published_posts"] = try publishedBlogPosts.makeNode(in: BlogPostContext.all)
        }

        if !links.isEmpty {
            parameters["links"] = try links.makeNode(in: nil)
        }

        if !draftBlogPosts.isEmpty {
            parameters["draft_posts"] = try draftBlogPosts.makeNode(in: BlogPostContext.all)
        }

        if let errors = errors {
            parameters["errors"] = try errors.makeNode(in: nil)
        }

        parameters["blog_admin_page"] = true

        return try viewFactory.viewRenderer.make("blog/admin/index", parameters)
    }

    func createResetPasswordView(errors: [String]? = nil, passwordError: Bool? = nil, confirmPasswordError: Bool? = nil, user: BlogUser) throws -> View {

        var parameters: [String: Vapor.Node] = [:]
        parameters["user"] = try user.makeNode(in: nil)

        if let resetPasswordErrors = errors {
            parameters["errors"] = try resetPasswordErrors.makeNode(in: nil)
        }

        if let passwordError = passwordError {
            parameters["password_error"] = passwordError.makeNode(in: nil)
        }

        if let confirmPasswordError = confirmPasswordError {
            parameters["confirm_password_error"] = confirmPasswordError.makeNode(in: nil)
        }

        return try viewFactory.viewRenderer.make("blog/admin/resetPassword", parameters)
    }

    func blogIndexView(uri: URI, paginatedPosts: Page<BlogPost>, tags: [BlogTag], links: [BlogLink], authors: [BlogUser], loggedInUser: BlogUser?) throws -> View {

        var parameters: [String: Vapor.Node] = [:]
        parameters["blog_index_page"] = true.makeNode(in: nil)

        if paginatedPosts.total > 0 {
            parameters["posts"] = try paginatedPosts.makeNode(for: uri, in: BlogPostContext.longSnippet)
        }

        if !tags.isEmpty {
            parameters["tags"] = try tags.makeNode(in: nil)
        }

        if !links.isEmpty {
            parameters["links"] = try links.makeNode(in: nil)
        }

        if !authors.isEmpty {
            parameters["authors"] = try authors.makeNode(in: nil)
        }

        return try viewFactory.createPublicView(template: "blog/blog", uri: uri, parameters: parameters, user: loggedInUser)
    }
    
    func searchView(uri: URI, searchTerm: String?, foundPosts: Page<BlogPost>?, emptySearch: Bool, user: BlogUser?) throws -> View {
        var parameters: [String: Vapor.Node] = [:]
        
        let searchCount = foundPosts?.total ?? 0
        if searchCount > 0 {
            parameters["posts"] = try foundPosts?.makeNode(for: uri, in: BlogPostContext.longSnippet)
        }
        
        parameters["searchCount"] = searchCount.makeNode(in: nil)
        
        if emptySearch {
            parameters["emptySearch"] = true
        }
        
        if let searchTerm = searchTerm {
            parameters["searchTerm"] = searchTerm.makeNode(in: nil)
        }
        
        return try viewFactory.createPublicView(template: "blog/search", uri: uri, parameters: parameters, user: user)
    }
}
