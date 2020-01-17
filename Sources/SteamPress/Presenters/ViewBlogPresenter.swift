import Vapor
import SwiftSoup
import SwiftMarkdown

public struct ViewBlogPresenter: BlogPresenter {

    public func indexView(on container: Container, posts: [BlogPost], tags: [BlogTag], authors: [BlogUser], pageInformation: BlogGlobalPageInformation, paginationTagInfo: PaginationTagInformation) -> EventLoopFuture<View> {
        do {
            let viewRenderer = try container.make(ViewRenderer.self)
            let longDateFormatter = try container.make(LongPostDateFormatter.self)
            let numericDateFormatter = try container.make(NumericPostDateFormatter.self)
            #warning("Test all the view post stuff")
            let viewPosts = posts.map { post -> ViewBlogPost in
                return post.toViewPost(authorName: authors.getAuthorName(id: post.author), authorUsername: authors.getAuthorUsername(id: post.author), longFormatter: longDateFormatter, numericFormatter: numericDateFormatter)
            }
            let context = BlogIndexPageContext(posts: viewPosts, tags: tags, authors: authors, pageInformation: pageInformation, paginationTagInformation: paginationTagInfo)
            return viewRenderer.render("blog/blog", context)
        } catch {
            return container.future(error: error)
        }
    }

    public func postView(on container: Container, post: BlogPost, author: BlogUser, pageInformation: BlogGlobalPageInformation) -> EventLoopFuture<View> {
        do {
            let viewRenderer = try container.make(ViewRenderer.self)

            var postImage: String?
            var postImageAlt: String?
            if let image = try SwiftSoup.parse(markdownToHTML(post.contents)).select("img").first() {
                postImage = try image.attr("src")
                let imageAlt = try image.attr("alt")
                if imageAlt != "" {
                    postImageAlt = imageAlt
                }
            }
            let shortSnippet = post.shortSnippet()
            #warning("test")
            let longFormatter = try container.make(LongPostDateFormatter.self)
            let numericFormatter = try container.make(NumericPostDateFormatter.self)
            let viewPost = post.toViewPost(authorName: author.name, authorUsername: author.username, longFormatter: longFormatter, numericFormatter: numericFormatter)

            let context = BlogPostPageContext(title: post.title, post: viewPost, author: author, pageInformation: pageInformation, postImage: postImage, postImageAlt: postImageAlt, shortSnippet: shortSnippet)
            return viewRenderer.render("blog/post", context)
        } catch {
            return container.future(error: error)
        }

    }

    public func allAuthorsView(on container: Container, authors: [BlogUser], authorPostCounts: [Int: Int], pageInformation: BlogGlobalPageInformation) -> EventLoopFuture<View> {
        do {
            let viewRenderer = try container.make(ViewRenderer.self)
            var viewAuthors = try authors.map { user -> ViewBlogAuthor in
                guard let userID = user.userID else {
                    throw SteamPressError(identifier: "ViewBlogPresenter", "User ID Was Not Set")
                }
                return ViewBlogAuthor(userID: userID, name: user.name, username: user.username, resetPasswordRequired: user.resetPasswordRequired, profilePicture: user.profilePicture, twitterHandle: user.twitterHandle, biography: user.biography, tagline: user.tagline, postCount: authorPostCounts[userID] ?? 0)

            }
            viewAuthors.sort { $0.postCount > $1.postCount }
            let context = AllAuthorsPageContext(pageInformation: pageInformation, authors: viewAuthors)
            return viewRenderer.render("blog/authors", context)
        } catch {
            return container.future(error: error)
        }
    }

    public func authorView(on container: Container, author: BlogUser, posts: [BlogPost], postCount: Int, pageInformation: BlogGlobalPageInformation, paginationTagInfo: PaginationTagInformation) -> EventLoopFuture<View> {
        do {
            let viewRenderer = try container.make(ViewRenderer.self)
            let myProfile: Bool
            if let loggedInUser = pageInformation.loggedInUser {
                myProfile = loggedInUser.userID == author.userID
            } else {
                myProfile = false
            }
            let longFormatter = try container.make(LongPostDateFormatter.self)
            let numericFormatter = try container.make(NumericPostDateFormatter.self)
            let viewPosts = posts.map { $0.toViewPost(authorName: author.name, authorUsername: author.username, longFormatter: longFormatter, numericFormatter: numericFormatter) }
            let context = AuthorPageContext(author: author, posts: viewPosts, pageInformation: pageInformation, myProfile: myProfile, postCount: postCount, paginationTagInformation: paginationTagInfo)
            return viewRenderer.render("blog/profile", context)
        } catch {
            return container.future(error: error)
        }
    }

    public func allTagsView(on container: Container, tags: [BlogTag], tagPostCounts: [Int: Int], pageInformation: BlogGlobalPageInformation) -> EventLoopFuture<View> {
        do {
            let viewRenderer = try container.make(ViewRenderer.self)
            var viewTags = try tags.map { tag -> ViewBlogTag in
                guard let tagID = tag.tagID else {
                    throw SteamPressError(identifier: "ViewBlogPresenter", "Tag ID Was Not Set")
                }
                return ViewBlogTag(tagID: tagID, name: tag.name, postCount: tagPostCounts[tagID] ?? 0)
            }
            viewTags.sort { $0.postCount > $1.postCount }
            let context = AllTagsPageContext(title: "All Tags", tags: viewTags, pageInformation: pageInformation)
            return viewRenderer.render("blog/tags", context)
        } catch {
            return container.future(error: error)
        }
    }

    public func tagView(on container: Container, tag: BlogTag, posts: [BlogPost], totalPosts: Int, pageInformation: BlogGlobalPageInformation, paginationTagInfo: PaginationTagInformation) -> EventLoopFuture<View> {
        do {
            let viewRenderer = try container.make(ViewRenderer.self)
            let context = TagPageContext(tag: tag, pageInformation: pageInformation, posts: posts, postCount: totalPosts, paginationTagInformation: paginationTagInfo)
            return viewRenderer.render("blog/tag", context)
        } catch {
            return container.future(error: error)
        }
    }

    public func searchView(on container: Container, totalResults: Int, posts: [BlogPost], authors: [BlogUser], searchTerm: String?, pageInformation: BlogGlobalPageInformation, paginationTagInfo: PaginationTagInformation) -> EventLoopFuture<View> {
        do {
            #warning("Test users")
            let viewRenderer = try container.make(ViewRenderer.self)
            let longDateFormatter = try container.make(LongPostDateFormatter.self)
            let numericDateFormatter = try container.make(NumericPostDateFormatter.self)
            let viewPosts = posts.map { post -> ViewBlogPost in
                return post.toViewPost(authorName: authors.getAuthorName(id: post.author), authorUsername: authors.getAuthorUsername(id: post.author), longFormatter: longDateFormatter, numericFormatter: numericDateFormatter)
            }
            #warning("Test pagination information and total results")
            let context = SearchPageContext(searchTerm: searchTerm, posts: viewPosts, totalResults: totalResults, pageInformation: pageInformation, paginationTagInformation: paginationTagInfo)
            return viewRenderer.render("blog/search", context)
        } catch {
            return container.future(error: error)
        }
    }

    public func loginView(on container: Container, loginWarning: Bool, errors: [String]?, username: String?, usernameError: Bool, passwordError: Bool, rememberMe: Bool, pageInformation: BlogGlobalPageInformation) -> EventLoopFuture<View> {
        do {
            let viewRenderer = try container.make(ViewRenderer.self)
            let context = LoginPageContext(errors: errors, loginWarning: loginWarning, username: username, usernameError: usernameError, passwordError: passwordError, rememberMe: rememberMe, pageInformation: pageInformation)
            return viewRenderer.render("blog/admin/login", context)
        } catch {
            return container.future(error: error)
        }
    }
}
