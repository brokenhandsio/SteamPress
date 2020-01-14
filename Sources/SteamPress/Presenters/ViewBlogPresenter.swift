import Vapor
import SwiftSoup
import SwiftMarkdown

public struct ViewBlogPresenter: BlogPresenter {

    public func indexView(on container: Container, posts: [BlogPost], tags: [BlogTag], authors: [BlogUser], pageInformation: BlogGlobalPageInformation) -> EventLoopFuture<View> {
        do {
            let viewRenderer = try container.make(ViewRenderer.self)
            let context = BlogIndexPageContext(posts: posts, tags: tags, authors: authors, pageInformation: pageInformation)
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
            let formatter = try container.make(PostDateFormatter.self)
            let viewPost = post.toViewPost(formatter: formatter.formatter)

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

    public func authorView(on container: Container, author: BlogUser, posts: [BlogPost], postCount: Int, pageInformation: BlogGlobalPageInformation) -> EventLoopFuture<View> {
        do {
            let viewRenderer = try container.make(ViewRenderer.self)
            let myProfile: Bool
            if let loggedInUser = pageInformation.loggedInUser {
                myProfile = loggedInUser.userID == author.userID
            } else {
                myProfile = false
            }
            let formatter = try container.make(PostDateFormatter.self)
            let viewPosts = posts.map { $0.toViewPost(formatter: formatter.formatter) }
            let context = AuthorPageContext(author: author, posts: viewPosts, pageInformation: pageInformation, myProfile: myProfile, postCount: postCount)
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

    public func tagView(on container: Container, tag: BlogTag, posts: [BlogPost], pageInformation: BlogGlobalPageInformation) -> EventLoopFuture<View> {
        do {
            let viewRenderer = try container.make(ViewRenderer.self)
            let context = TagPageContext(tag: tag, pageInformation: pageInformation, posts: posts)
            return viewRenderer.render("blog/tag", context)
        } catch {
            return container.future(error: error)
        }
    }

    public func searchView(on container: Container, posts: [BlogPost], searchTerm: String?, pageInformation: BlogGlobalPageInformation) -> EventLoopFuture<View> {
        do {
            let viewRenderer = try container.make(ViewRenderer.self)
            let context = SearchPageContext(searchTerm: searchTerm, posts: posts, pageInformation: pageInformation)
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
