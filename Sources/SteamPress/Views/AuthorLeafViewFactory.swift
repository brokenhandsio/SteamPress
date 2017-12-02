import Vapor
import URI
import HTTP
import SwiftMarkdown
import SwiftSoup
import Foundation
import Fluent

struct AuthorLeafViewFactory: AuthorViewFactory {

    let viewFactory: ViewFactory

    func createUserView(editing: Bool = false, errors: [String]? = nil, name: String? = nil, username: String? = nil, passwordError: Bool? = nil, confirmPasswordError: Bool? = nil, resetPasswordRequired: Bool? = nil, userId: Identifier? = nil, profilePicture: String? = nil, twitterHandle: String? = nil, biography: String? = nil, tagline: String? = nil, loggedInUser: BlogUser) throws -> View {
        let nameError = name == nil && errors != nil
        let usernameError = username == nil && errors != nil

        var parameters: [String: NodeRepresentable] = [:]
        parameters["name_error"] = nameError
        parameters["username_error"] = usernameError
        parameters["user"] = loggedInUser

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

        if resetPasswordRequired != nil {
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

        return try viewFactory.viewRenderer.make("blog/admin/createUser", parameters)
    }

    func allAuthorsView(uri: URI, allAuthors: [BlogUser], user: BlogUser?) throws -> View {
        var parameters: [String: NodeRepresentable] = [:]

        if !allAuthors.isEmpty {
            let sortedAuthors = allAuthors.sorted { return (try? $0.sortedPosts().count() > $1.sortedPosts().count()) ?? false }
            parameters["authors"] = try sortedAuthors.makeNode(in: BlogUserContext.withPostCount)
        }

        return try viewFactory.createPublicView(template: "blog/authors", uri: uri, parameters: parameters, user: user)
    }
    
    func profileView(uri: URI, author: BlogUser, paginatedPosts: Page<BlogPost>, loggedInUser: BlogUser?) throws -> View {
        var parameters: [String: Vapor.Node] = [:]
        parameters["author"] = try author.makeNode(in: BlogUserContext.withPostCount)
        
        parameters["profile_page"] = true.makeNode(in: nil)
        
        if paginatedPosts.total > 0 {
            parameters["posts"] = try paginatedPosts.makeNode(for: uri, in: BlogPostContext.longSnippet)
        }
        
        return try viewFactory.createPublicView(template: "blog/profile", uri: uri, parameters: parameters, user: loggedInUser)
    }
}
