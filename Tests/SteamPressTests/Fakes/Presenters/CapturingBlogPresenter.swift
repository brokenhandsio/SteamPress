import SteamPress
import Vapor

import Foundation

class CapturingBlogPresenter: BlogPresenter {

    // MARK: - BlogPresenter
    private(set) var indexPosts: [BlogPost]?
    private(set) var indexTags: [BlogTag]?
    private(set) var indexAuthors: [BlogUser]?
    private(set) var indexPageInformation: BlogGlobalPageInformation?
    #warning("test")
    private(set) var indexPaginationTagInfo: PaginationTagInformation?
    func indexView(on container: Container, posts: [BlogPost], tags: [BlogTag], authors: [BlogUser], pageInformation: BlogGlobalPageInformation, paginationTagInfo: PaginationTagInformation) -> EventLoopFuture<View> {
        self.indexPosts = posts
        self.indexTags = tags
        self.indexAuthors = authors
        self.indexPageInformation = pageInformation
        self.indexPaginationTagInfo = paginationTagInfo
        return TestDataBuilder.createFutureView(on: container)
    }

    private(set) var post: BlogPost?
    private(set) var postAuthor: BlogUser?
    private(set) var postPageInformation: BlogGlobalPageInformation?
    func postView(on container: Container, post: BlogPost, author: BlogUser, pageInformation: BlogGlobalPageInformation) -> EventLoopFuture<View> {
        self.post = post
        self.postAuthor = author
        self.postPageInformation = pageInformation
        return TestDataBuilder.createFutureView(on: container)
    }

    private(set) var allAuthors: [BlogUser]?
    private(set) var allAuthorsPostCount: [Int: Int]?
    private(set) var allAuthorsPageInformation: BlogGlobalPageInformation?
    func allAuthorsView(on container: Container, authors: [BlogUser], authorPostCounts: [Int: Int], pageInformation: BlogGlobalPageInformation) -> EventLoopFuture<View> {
        self.allAuthors = authors
        self.allAuthorsPostCount = authorPostCounts
        self.allAuthorsPageInformation = pageInformation
        return TestDataBuilder.createFutureView(on: container)
    }

    private(set) var author: BlogUser?
    private(set) var authorPosts: [BlogPost]?
    private(set) var authorPostCount: Int?
    private(set) var authorPageInformation: BlogGlobalPageInformation?
    #warning("test")
    private(set) var authorPaginationTagInfo: PaginationTagInformation?
    func authorView(on container: Container, author: BlogUser, posts: [BlogPost], postCount: Int, pageInformation: BlogGlobalPageInformation, paginationTagInfo: PaginationTagInformation) -> EventLoopFuture<View> {
        self.author = author
        self.authorPosts = posts
        self.authorPostCount = postCount
        self.authorPageInformation = pageInformation
        self.authorPaginationTagInfo = paginationTagInfo
        return TestDataBuilder.createFutureView(on: container)
    }

    private(set) var allTagsPageTags: [BlogTag]?
    private(set) var allTagsPagePostCount: [Int: Int]?
    private(set) var allTagsPageInformation: BlogGlobalPageInformation?
    func allTagsView(on container: Container, tags: [BlogTag], tagPostCounts: [Int: Int], pageInformation: BlogGlobalPageInformation) -> EventLoopFuture<View> {
        self.allTagsPageTags = tags
        self.allTagsPagePostCount = tagPostCounts
        self.allTagsPageInformation = pageInformation
        return TestDataBuilder.createFutureView(on: container)
    }

    private(set) var tag: BlogTag?
    private(set) var tagPosts: [BlogPost]?
    private(set) var tagPageInformation: BlogGlobalPageInformation?
    #warning("test")
    private(set) var tagPaginationTagInfo: PaginationTagInformation?
    func tagView(on container: Container, tag: BlogTag, posts: [BlogPost], pageInformation: BlogGlobalPageInformation, paginationTagInfo: PaginationTagInformation) -> EventLoopFuture<View> {
        self.tag = tag
        self.tagPosts = posts
        self.tagPageInformation = pageInformation
        self.tagPaginationTagInfo = paginationTagInfo
        return TestDataBuilder.createFutureView(on: container)
    }

    private(set) var searchPosts: [BlogPost]?
    private(set) var searchAuthors: [BlogUser]?
    private(set) var searchTerm: String?
    #warning("Test")
    private(set) var searchTotalResults: Int?
    private(set) var searchPageInformation: BlogGlobalPageInformation?
    private(set) var searchPaginationTagInfo: PaginationTagInformation?
    func searchView(on container: Container, totalResults: Int, posts: [BlogPost], authors: [BlogUser], searchTerm: String?, pageInformation: BlogGlobalPageInformation, paginationTagInfo: PaginationTagInformation) -> EventLoopFuture<View> {
        self.searchPosts = posts
        self.searchTerm = searchTerm
        self.searchPageInformation = pageInformation
        self.searchTotalResults = totalResults
        self.searchAuthors = authors
        self.searchPaginationTagInfo = paginationTagInfo
        return TestDataBuilder.createFutureView(on: container)
    }

    private(set) var loginWarning: Bool?
    private(set) var loginErrors: [String]?
    private(set) var loginUsername: String?
    private(set) var loginUsernameError: Bool?
    private(set) var loginPasswordError: Bool?
    private(set) var loginPageInformation: BlogGlobalPageInformation?
    private(set) var loginPageRememberMe: Bool?
    func loginView(on container: Container, loginWarning: Bool, errors: [String]?, username: String?, usernameError: Bool, passwordError: Bool, rememberMe: Bool, pageInformation: BlogGlobalPageInformation) -> EventLoopFuture<View> {
        self.loginWarning = loginWarning
        self.loginErrors = errors
        self.loginUsername = username
        self.loginUsernameError = usernameError
        self.loginPasswordError = passwordError
        self.loginPageInformation = pageInformation
        self.loginPageRememberMe = rememberMe
        return TestDataBuilder.createFutureView(on: container)
    }
}
