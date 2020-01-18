import Vapor
import SwiftSoup
import SwiftMarkdown

public struct ViewBlogPresenter: BlogPresenter {

    public func indexView(on container: Container, posts: [BlogPost], tags: [BlogTag], authors: [BlogUser], tagsForPosts: [Int: [BlogTag]], pageInformation: BlogGlobalPageInformation, paginationTagInfo: PaginationTagInformation) -> EventLoopFuture<View> {
        do {
            let viewRenderer = try container.make(ViewRenderer.self)
            #warning("Test all the view post stuff")
            let viewPosts = try posts.convertToViewBlogPosts(authors: authors, tagsForPosts: tagsForPosts, on: container)
            let viewTags = try tags.map { try $0.toViewBlogTag() }
            let context = BlogIndexPageContext(posts: viewPosts, tags: viewTags, authors: authors, pageInformation: pageInformation, paginationTagInformation: paginationTagInfo)
            return viewRenderer.render("blog/blog", context)
        } catch {
            return container.future(error: error)
        }
    }

    public func postView(on container: Container, post: BlogPost, author: BlogUser, tags: [BlogTag], pageInformation: BlogGlobalPageInformation) -> EventLoopFuture<View> {
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
            let viewPost = try post.toViewPost(authorName: author.name, authorUsername: author.username, longFormatter: longFormatter, numericFormatter: numericFormatter, tags: tags)

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

    public func authorView(on container: Container, author: BlogUser, posts: [BlogPost], postCount: Int, tagsForPosts: [Int: [BlogTag]], pageInformation: BlogGlobalPageInformation, paginationTagInfo: PaginationTagInformation) -> EventLoopFuture<View> {
        do {
            let viewRenderer = try container.make(ViewRenderer.self)
            let myProfile: Bool
            if let loggedInUser = pageInformation.loggedInUser {
                myProfile = loggedInUser.userID == author.userID
            } else {
                myProfile = false
            }
            let viewPosts = try posts.convertToViewBlogPosts(authors: [author], tagsForPosts: tagsForPosts, on: container)
            let context = AuthorPageContext(author: author, posts: viewPosts, pageInformation: pageInformation, myProfile: myProfile, postCount: postCount, paginationTagInformation: paginationTagInfo)
            return viewRenderer.render("blog/profile", context)
        } catch {
            return container.future(error: error)
        }
    }

    public func allTagsView(on container: Container, tags: [BlogTag], tagPostCounts: [Int: Int], pageInformation: BlogGlobalPageInformation) -> EventLoopFuture<View> {
        do {
            let viewRenderer = try container.make(ViewRenderer.self)
            var viewTags = try tags.map { tag -> BlogTagWithPostCount in
                guard let tagID = tag.tagID else {
                    throw SteamPressError(identifier: "ViewBlogPresenter", "Tag ID Was Not Set")
                }
                guard let urlEncodedName = tag.name.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {
                    throw SteamPressError(identifier: "ViewBlogPresenter", "Failed to URL encoded tag name")
                }
                return BlogTagWithPostCount(tagID: tagID, name: tag.name, postCount: tagPostCounts[tagID] ?? 0, urlEncodedName: urlEncodedName)
            }
            viewTags.sort { $0.postCount > $1.postCount }
            let context = AllTagsPageContext(title: "All Tags", tags: viewTags, pageInformation: pageInformation)
            return viewRenderer.render("blog/tags", context)
        } catch {
            return container.future(error: error)
        }
    }

    public func tagView(on container: Container, tag: BlogTag, posts: [BlogPost], authors: [BlogUser], totalPosts: Int, pageInformation: BlogGlobalPageInformation, paginationTagInfo: PaginationTagInformation) -> EventLoopFuture<View> {
        do {
            let viewRenderer = try container.make(ViewRenderer.self)
            let tagsForPosts = try posts.reduce(into: [Int: [BlogTag]]()) { dict, blog in
                guard let blogID = blog.blogID else {
                    throw SteamPressError(identifier: "ViewBlogPresenter", "Blog has no ID set")
                }
                dict[blogID] = [tag]
            }
            
            let viewPosts = try posts.convertToViewBlogPosts(authors: authors, tagsForPosts: tagsForPosts, on: container)
            let context = TagPageContext(tag: tag, pageInformation: pageInformation, posts: viewPosts, postCount: totalPosts, paginationTagInformation: paginationTagInfo)
            return viewRenderer.render("blog/tag", context)
        } catch {
            return container.future(error: error)
        }
    }

    public func searchView(on container: Container, totalResults: Int, posts: [BlogPost], authors: [BlogUser], searchTerm: String?, tagsForPosts: [Int: [BlogTag]], pageInformation: BlogGlobalPageInformation, paginationTagInfo: PaginationTagInformation) -> EventLoopFuture<View> {
        do {
            #warning("Test users")
            let viewRenderer = try container.make(ViewRenderer.self)
            let viewPosts = try posts.convertToViewBlogPosts(authors: authors, tagsForPosts: tagsForPosts, on: container)
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
