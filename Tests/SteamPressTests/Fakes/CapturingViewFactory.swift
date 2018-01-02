//import URI
import Foundation
@testable import SteamPress
import Vapor
import Fluent

class CapturingViewFactory: ViewFactory {
    
    private func createDummyView() -> View {
        return View(data: "Test".makeBytes())
    }
    
    private(set) var createPostErrors: [String]? = nil
    private(set) var createBlogPostUser: BlogUser?
    private(set) var createPostURI: URI?
    func createBlogPostView(uri: URI, errors: [String]?, title: String?, contents: String?, slugUrl: String?, tags: [Node]?, isEditing: Bool, postToEdit: BlogPost?, draft: Bool, user: BlogUser) throws -> View {
        self.createPostErrors = errors
        self.createBlogPostUser = user
        self.createPostURI = uri
        return createDummyView()
    }
    
    private(set) var createUserErrors: [String]? = nil
    private(set) var createUserLoggedInUser: BlogUser?
    func createUserView(editing: Bool, errors: [String]?, name: String?, username: String?, passwordError: Bool?, confirmPasswordError: Bool?, resetPasswordRequired: Bool?, userId: Identifier?, profilePicture: String?, twitterHandle: String?, biography: String?, tagline: String?, loggedInUser: BlogUser) throws -> View {
        self.createUserErrors = errors
        self.createUserLoggedInUser = loggedInUser
        return createDummyView()
    }
    
    func createLoginView(loginWarning: Bool, errors: [String]?, username: String?, password: String?) throws -> View {
        return createDummyView()
    }
    
    private(set) var adminViewErrors: [String]? = nil
    private(set) var adminUser: BlogUser? = nil
    func createBlogAdminView(errors: [String]?, user: BlogUser) throws -> View {
        adminUser = user
        adminViewErrors = errors
        return createDummyView()
    }
    
    private(set) var resetPasswordErrors: [String]? = nil
    private(set) var resetPasswordErrorFlag: Bool? = nil
    private(set) var resetPasswordConfirmErrorFlag: Bool? = nil
    private(set) var resetPasswordUser: BlogUser?
    func createResetPasswordView(errors: [String]?, passwordError: Bool?, confirmPasswordError: Bool?, user: BlogUser) throws -> View {
        self.resetPasswordErrors = errors
        self.resetPasswordErrorFlag = passwordError
        self.resetPasswordConfirmErrorFlag = confirmPasswordError
        self.resetPasswordUser = user
        return createDummyView()
    }
    
    private(set) var author: BlogUser? = nil
    private(set) var authorPosts: Page<BlogPost>? = nil
    private(set) var authorURI: URI? = nil
    func profileView(uri: URI, author: BlogUser, paginatedPosts: Page<BlogPost>, loggedInUser: BlogUser?) throws -> View {
        self.author = author
        self.authorPosts = paginatedPosts
        self.authorURI = uri
        return createDummyView()
    }
    
    private(set) var blogPost: BlogPost? = nil
    private(set) var blogPostAuthor: BlogUser? = nil
    private(set) var blogPostURI: URI? = nil
    func blogPostView(uri: URI, post: BlogPost, author: BlogUser, user: BlogUser?) throws -> View {
        self.blogPost = post
        self.blogPostAuthor = author
        self.blogPostURI = uri
        return createDummyView()
    }
    
    private(set) var tag: BlogTag? = nil
    private(set) var tagPosts: Page<BlogPost>? = nil
    private(set) var tagUser: BlogUser? = nil
    private(set) var tagURI: URI? = nil
    func tagView(uri: URI, tag: BlogTag, paginatedPosts: Page<BlogPost>, user: BlogUser?) throws -> View {
        self.tag = tag
        self.tagPosts = paginatedPosts
        self.tagUser = user
        self.tagURI = uri
        return createDummyView()
    }
    
    private(set) var blogIndexTags: [BlogTag]? = nil
    private(set) var blogIndexAuthors: [BlogUser]? = nil
    private(set) var paginatedPosts: Page<BlogPost>? = nil
    private(set) var blogIndexURI: URI? = nil
    func blogIndexView(uri: URI, paginatedPosts: Page<BlogPost>, tags: [BlogTag], authors: [BlogUser], loggedInUser: BlogUser?) throws -> View {
        self.blogIndexTags = tags
        self.paginatedPosts = paginatedPosts
        self.blogIndexURI = uri
        self.blogIndexAuthors = authors
        return createDummyView()
    }
    
    private(set) var allAuthorsURI: URI? = nil
    private(set) var allAuthorsPageAuthors: [BlogUser]? = nil
    func allAuthorsView(uri: URI, allAuthors: [BlogUser], user: BlogUser?) throws -> View {
        self.allAuthorsURI = uri
        self.allAuthorsPageAuthors = allAuthors
        return createDummyView()
    }
    
    private(set) var allTagsURI: URI? = nil
    private(set) var allTagsPageTags: [BlogTag]? = nil
    func allTagsView(uri: URI, allTags: [BlogTag], user: BlogUser?) throws -> View {
        self.allTagsURI = uri
        self.allTagsPageTags = allTags
        return createDummyView()
    }
    
    private(set) var searchPosts: Page<BlogPost>?
    private(set) var emptySearch: Bool?
    private(set) var searchTerm: String?
    func searchView(uri: URI, searchTerm: String?, foundPosts: Page<BlogPost>?, emptySearch: Bool, user: BlogUser?) throws -> View {
        self.searchPosts = foundPosts
        self.emptySearch = emptySearch
        self.searchTerm = searchTerm
        return createDummyView()
    }
}
