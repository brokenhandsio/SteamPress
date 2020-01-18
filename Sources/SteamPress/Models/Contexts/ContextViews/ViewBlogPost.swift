import Foundation
import Vapor
import SwiftSoup
import SwiftMarkdown

struct ViewBlogPost: Encodable {
    var blogID: Int?
    var title: String
    var contents: String
    var author: Int
    var created: Date
    var lastEdited: Date?
    var slugUrl: String
    var published: Bool
    var longSnippet: String
    var createdDateLong: String
    var createdDateNumeric: String
    var lastEditedDateNumeric: String?
    var lastEditedDateLong: String?
    var authorName: String
    var authorUsername: String
    var postImage: String?
    var postImageAlt: String?
    var description: String
    var tags: [ViewBlogTag]
}

struct ViewBlogPostWithoutTags: Encodable {
    var blogID: Int?
    var title: String
    var contents: String
    var author: Int
    var created: Date
    var lastEdited: Date?
    var slugUrl: String
    var published: Bool
    var longSnippet: String
    var createdDateLong: String
    var createdDateNumeric: String
    var lastEditedDateNumeric: String?
    var lastEditedDateLong: String?
    var authorName: String
    var authorUsername: String
    var postImage: String?
    var postImageAlt: String?
    var description: String
}

extension BlogPost {
    
    func toViewPostWithoutTags(authorName: String, authorUsername: String, longFormatter: LongPostDateFormatter, numericFormatter: NumericPostDateFormatter) throws -> ViewBlogPostWithoutTags {
        let lastEditedNumeric: String?
        let lastEditedDateLong: String?
        if let lastEdited = self.lastEdited {
            lastEditedNumeric = numericFormatter.formatter.string(from: lastEdited)
            lastEditedDateLong = longFormatter.formatter.string(from: lastEdited)
        } else {
            lastEditedNumeric = nil
            lastEditedDateLong = nil
        }
        
        let postImage: String?
        let postImageAlt: String?
        
        let image = try SwiftSoup.parse(markdownToHTML(self.contents)).select("img").first()

        if let imageFound = image {
            postImage = try imageFound.attr("src")
            do {
                let imageAlt = try imageFound.attr("alt")
                if imageAlt != "" {
                    postImageAlt = imageAlt
                }  else {
                    postImageAlt = nil
                }
            } catch {
                postImageAlt = nil
            }
        } else {
            postImage = nil
            postImageAlt = nil
        }
        
        return try ViewBlogPostWithoutTags(blogID: self.blogID, title: self.title, contents: self.contents, author: self.author, created: self.created, lastEdited: self.lastEdited, slugUrl: self.slugUrl, published: self.published, longSnippet: self.longSnippet(), createdDateLong: longFormatter.formatter.string(from: created), createdDateNumeric: numericFormatter.formatter.string(from: created), lastEditedDateNumeric: lastEditedNumeric, lastEditedDateLong: lastEditedDateLong, authorName: authorName, authorUsername: authorUsername, postImage: postImage, postImageAlt: postImageAlt, description: self.description())
    }
    
    func toViewPost(authorName: String, authorUsername: String, longFormatter: LongPostDateFormatter, numericFormatter: NumericPostDateFormatter, tags: [BlogTag]) throws -> ViewBlogPost {
        let viewPost = try self.toViewPostWithoutTags(authorName: authorName, authorUsername: authorUsername, longFormatter: longFormatter, numericFormatter: numericFormatter)
        
        let viewTags = try tags.map { try $0.toViewBlogTag() }
        
        return ViewBlogPost(blogID: viewPost.blogID, title: viewPost.title, contents: viewPost.contents, author: viewPost.author, created: viewPost.created, lastEdited: viewPost.lastEdited, slugUrl: viewPost.slugUrl, published: viewPost.published, longSnippet: viewPost.longSnippet, createdDateLong: viewPost.createdDateLong, createdDateNumeric: viewPost.createdDateNumeric, lastEditedDateNumeric: viewPost.lastEditedDateNumeric, lastEditedDateLong: viewPost.lastEditedDateLong, authorName: viewPost.authorName, authorUsername: viewPost.authorUsername, postImage: viewPost.postImage, postImageAlt: viewPost.postImageAlt, description: viewPost.description, tags: viewTags)
    }
}

extension Array where Element: BlogPost {
    func convertToViewBlogPosts(authors: [BlogUser], tagsForPosts: [Int: [BlogTag]], on container: Container) throws -> [ViewBlogPost] {
        let longDateFormatter = try container.make(LongPostDateFormatter.self)
        let numericDateFormatter = try container.make(NumericPostDateFormatter.self)
        let viewPosts = try self.map { post -> ViewBlogPost in
            guard let blogID = post.blogID else {
                throw SteamPressError(identifier: "ViewBlogPost", "Post has no ID set")
            }
            return try post.toViewPost(authorName: authors.getAuthorName(id: post.author), authorUsername: authors.getAuthorUsername(id: post.author), longFormatter: longDateFormatter, numericFormatter: numericDateFormatter, tags: tagsForPosts[blogID] ?? [])
        }
        return viewPosts
    }
    
    func convertToViewBlogPostsWithoutTags(authors: [BlogUser], on container: Container) throws -> [ViewBlogPostWithoutTags] {
        let longDateFormatter = try container.make(LongPostDateFormatter.self)
        let numericDateFormatter = try container.make(NumericPostDateFormatter.self)
        let viewPosts = try self.map { post -> ViewBlogPostWithoutTags in
            return try post.toViewPostWithoutTags(authorName: authors.getAuthorName(id: post.author), authorUsername: authors.getAuthorUsername(id: post.author), longFormatter: longDateFormatter, numericFormatter: numericDateFormatter)
        }
        return viewPosts
    }
}
