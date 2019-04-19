import Vapor

struct BlogController: RouteCollection {

    // MARK: - Properties
    fileprivate let blogPostsPath = "posts"
    fileprivate let tagsPath = "tags"
    fileprivate let authorsPath = "authors"
    fileprivate let apiPath = "api"
    fileprivate let searchPath = "search"
//    fileprivate let pathCreator: BlogPathCreator
    fileprivate let enableAuthorPages: Bool
    fileprivate let enableTagsPages: Bool

    // MARK: - Initialiser
    init(enableAuthorPages: Bool, enableTagPages: Bool) {
        self.enableAuthorPages = enableAuthorPages
        self.enableTagsPages = enableTagPages
    }

    // MARK: - Add routes
    func boot(router: Router) throws {
        router.get(use: indexHandler)
        router.get(blogPostsPath, String.parameter, use: blogPostHandler)
        router.get(blogPostsPath, use: blogPostIndexRedirectHandler)
        router.get(searchPath, use: searchHandler)
        if enableAuthorPages {
            router.get(authorsPath, use: allAuthorsViewHandler)
            router.get(authorsPath, String.parameter, use: authorViewHandler)
        }
        if enableTagsPages {
            router.get(tagsPath, String.parameter, use: tagViewHandler)
            router.get(tagsPath, use: allTagsViewHandler)
        }
    }

    // MARK: - Route Handlers

    func indexHandler(_ req: Request) throws -> Future<View> {
        #warning("Pagination")
        let postRepository = try req.make(BlogPostRepository.self)
        let tagRepository = try req.make(BlogTagRepository.self)
        let userRepository = try req.make(BlogUserRepository.self)
        return flatMap(postRepository.getAllPostsSortedByPublishDate(includeDrafts: false, on: req),
                       tagRepository.getAllTags(on: req),
                       userRepository.getAllUsers(on: req)) { posts, tags, users in
            let presenter = try req.make(BlogPresenter.self)
            return presenter.indexView(on: req, posts: posts, tags: tags, authors: users)
        }
    }

    func blogPostIndexRedirectHandler(_ req: Request) throws -> Response {
//        return Response(redirect: pathCreator.createPath(for: pathCreator.blogPath), .permanent)
        #warning("Check path")
        return req.redirect(to: "/", type: .permanent)
    }

    func blogPostHandler(_ req: Request) throws -> Future<View> {
        let blogSlug = try req.parameters.next(String.self)
        let blogRepository = try req.make(BlogPostRepository.self)
        return blogRepository.getPost(slug: blogSlug, on: req).unwrap(or: Abort(.notFound)).flatMap { post in
            let userRepository = try req.make(BlogUserRepository.self)
            return userRepository.getUser(id: post.author, on: req).unwrap(or: Abort(.internalServerError)).flatMap { user in
                let presenter = try req.make(BlogPresenter.self)
                return presenter.postView(on: req, post: post, author: user)
            }
        }
    }

    func tagViewHandler(_ req: Request) throws -> Future<View> {
        #warning("Pagination")
        let tagName = try req.parameters.next(String.self)

        guard let decodedTagName = tagName.removingPercentEncoding else {
            throw Abort(.badRequest)
        }
        
        let tagRepository = try req.make(BlogTagRepository.self)
        return tagRepository.getTag(decodedTagName, on: req).unwrap(or: Abort(.notFound)).flatMap { tag in
            let postRepository = try req.make(BlogPostRepository.self)
            return postRepository.getSortedPublishedPosts(for: tag, on: req).flatMap { posts in
                let presenter = try req.make(BlogPresenter.self)
                return presenter.tagView(on: req, tag: tag, posts: posts)
            }
        }
    }

    func authorViewHandler(_ req: Request) throws -> Future<View> {
        let authorUsername = try req.parameters.next(String.self)
        let userRepository = try req.make(BlogUserRepository.self)
        
        return userRepository.getUser(username: authorUsername, on: req).flatMap { user in
            guard let author = user else {
                throw Abort(.notFound)
            }
            
            let postRepository = try req.make(BlogPostRepository.self)
            return postRepository.getAllPostsSortedByPublishDate(for: author, includeDrafts: false, on: req).flatMap { posts in
                let presenter = try req.make(BlogPresenter.self)
                return presenter.authorView(on: req, author: author, posts: posts)
            }
        }
    }

    func allTagsViewHandler(_ req: Request) throws -> Future<View> {
        let tagRepository = try req.make(BlogTagRepository.self)
        return tagRepository.getAllTags(on: req).flatMap { tags in
            let presenter = try req.make(BlogPresenter.self)
            return presenter.allTagsView(on: req, tags: tags)
        }
    }

    func allAuthorsViewHandler(_ req: Request) throws -> Future<View> {
        let presenter = try req.make(BlogPresenter.self)
        let authorRepository = try req.make(BlogUserRepository.self)
        return authorRepository.getAllUsers(on: req).flatMap { allUsers in
            return presenter.allAuthorsView(on: req, authors: allUsers)
        }
    }

    func searchHandler(_ req: Request) throws -> Future<View> {
        let preseneter = try req.make(BlogPresenter.self)
        guard let searchTerm = req.query[String.self, at: "term"], !searchTerm.isEmpty else {
            return preseneter.searchView(on: req, posts: nil, searchTerm: nil)
        }
        
        let postRepository = try req.make(BlogPostRepository.self)
        return postRepository.findPublishedPostsOrdered(for: searchTerm, on: req).flatMap { posts in
            return preseneter.searchView(on: req, posts: posts, searchTerm: searchTerm)
        }
    }

}

#warning("Move")
import Foundation

extension Request {
    func urlWithHTTPSIfReverseProxy() -> URL {
        if http.headers["X-Forwarded-Proto"].first == "https" {
//            let uri = URI(scheme: "https", userInfo: self.http.uri.userInfo, hostname: self.http.uri.hostname, port: nil, path: self.http.uri.path, query: self.http.uri.query, fragment: self.http.uri.fragment)
            //            return uri
        }
        return self.http.url
    }
}

//
//    private func getLoggedInUser(in request: Request) -> BlogUser? {
//        var loggedInUser: BlogUser? = nil
//
//        do {
//            loggedInUser = try request.user()
//        } catch {}
//
//        return loggedInUser
//    }
