import Vapor
import URI
import HTTP
import SwiftMarkdown
import SwiftSoup
import Foundation
import Fluent

public extension BlogPost {
    func description() throws -> String {
        return try SwiftSoup.parse(markdownToHTML(shortSnippet())).text()
    }
}

struct PostLeafViewFactory: PostViewFactory {

    let viewFactory: ViewFactory

    func createBlogPostView(uri: URI, errors: [String]? = nil, title: String? = nil, contents: String? = nil, slugUrl: String? = nil, tags: [Vapor.Node]? = nil, isEditing: Bool = false, postToEdit: BlogPost? = nil, draft: Bool = true, user: BlogUser) throws -> View {
        let titleError = (title == nil || (title?.isWhitespace() ?? false)) && errors != nil
        let contentsError = (contents == nil || (contents?.isWhitespace() ?? false)) && errors != nil

        let postPathPrefix: String

        if isEditing {
            guard let editSubstringIndex = uri.descriptionWithoutPort.range(of: "admin/posts")?.lowerBound else {
                throw Abort.serverError
            }
            #if swift(>=4)
            postPathPrefix = uri.descriptionWithoutPort[..<editSubstringIndex] + "posts/"
            #else
            postPathPrefix = uri.descriptionWithoutPort.substring(to: editSubstringIndex) + "posts/"
            #endif
        } else {
            postPathPrefix = uri.descriptionWithoutPort.replacingOccurrences(of: "admin/createPost", with: "posts")
        }

        var parameters: [String: NodeRepresentable] = [:]
        parameters["post_path_prefix"] = postPathPrefix
        parameters["title_error"] = titleError
        parameters["contents_error"] = contentsError
        parameters["user"] = user

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

        if let tagsSupplied = tags, !tagsSupplied.isEmpty {
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
        } else {
            parameters["create_blog_post_page"] = true
        }

        return try viewFactory.viewRenderer.make("blog/admin/createPost", parameters)
    }

    func blogPostView(uri: URI, post: BlogPost, author: BlogUser, user: BlogUser?) throws -> View {

        var parameters: [String: Vapor.Node] = [:]
        parameters["post"] = try post.makeNode(in: BlogPostContext.all)
        parameters["author"] = try author.makeNode(in: nil)
        parameters["blog_post_page"] = true.makeNode(in: nil)
        parameters["post_uri"] = uri.descriptionWithoutPort.makeNode(in: nil)
        parameters["post_uri_encoded"] = uri.descriptionWithoutPort.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)?.makeNode(in: nil) ?? uri.descriptionWithoutPort.makeNode(in: nil)
        parameters["site_uri"] = uri.getRootUri().descriptionWithoutPort.makeNode(in: nil)
        parameters["post_description"] = try post.description().makeNode(in: nil)

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

        return try viewFactory.createPublicView(template: "blog/blogpost", uri: uri, parameters: parameters, user: user)
    }
}
