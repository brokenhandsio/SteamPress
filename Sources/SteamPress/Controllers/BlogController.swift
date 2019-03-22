import Vapor
//import HTTP
//import Routing
//import MarkdownProvider
//
struct BlogController: RouteCollection {

    // MARK: - Properties
    fileprivate let blogPostsPath = "posts"
    fileprivate let tagsPath = "tags"
    fileprivate let authorsPath = "authors"
    fileprivate let apiPath = "api"
    fileprivate let searchPath = "search"
//    fileprivate let drop: Droplet
//    fileprivate let pathCreator: BlogPathCreator
//    fileprivate let viewFactory: ViewFactory
    fileprivate let enableAuthorPages: Bool
//    fileprivate let enableTagsPages: Bool

    // MARK: - Initialiser
    init(enableAuthorPages: Bool) {
        self.enableAuthorPages = enableAuthorPages
    }
//    init(drop: Droplet, pathCreator: BlogPathCreator, viewFactory: ViewFactory, enableAuthorsPages: Bool, enableTagsPages: Bool) {
//        self.drop = drop
//        self.pathCreator = pathCreator
//        self.viewFactory = viewFactory
//        self.enableAuthorsPages = enableAuthorsPages
//        self.enableTagsPages = enableTagsPages
//    }
//
    // MARK: - Add routes
    func boot(router: Router) throws {
        router.get(use: indexHandler)
        router.get(blogPostsPath, String.parameter, use: blogPostHandler)
        if enableAuthorPages {
            router.get(authorsPath, use: allAuthorsViewHandler)
            router.get(authorsPath, String.parameter, use: authorViewHandler)
        }
    }
//    func addRoutes() {
//        drop.group(pathCreator.blogPath ?? "") { index in
//            index.get(handler: indexHandler)
//            index.get(blogPostsPath, String.parameter, handler: blogPostHandler)
//            index.get(apiPath, tagsPath, handler: tagApiHandler)
//            index.get(blogPostsPath, handler: blogPostIndexRedirectHandler)
//            index.get(searchPath, handler: searchHandler)
//
//            if enableAuthorsPages {
//                index.get(authorsPath, String.parameter, handler: authorViewHandler)
//                index.get(authorsPath, handler: allAuthorsViewHandler)
//            }
//
//            if enableTagsPages {
//                index.get(tagsPath, String.parameter, handler: tagViewHandler)
//                index.get(tagsPath, handler: allTagsViewHandler)
//            }
//        }
//    }

    // MARK: - Route Handlers

    func indexHandler(_ req: Request) throws -> Future<View> {
//        let paginatedBlogPosts = try BlogPost.makeQuery().filter(BlogPost.Properties.published, true).sort(BlogPost.Properties.created, .descending).paginate(for: request)
//
//        return try viewFactory.blogIndexView(uri: request.getURIWithHTTPSIfReverseProxy(), paginatedPosts: paginatedBlogPosts, tags: tags, authors: authors, loggedInUser: getLoggedInUser(in: request))
        let postRepository = try req.make(BlogPostRepository.self)
        let tagRepository = try req.make(BlogTagRepository.self)
        let userRepository = try req.make(BlogUserRepository.self)
        return flatMap(postRepository.getAllPostsSortedByPublishDate(on: req, includeDrafts: false),
                       tagRepository.getAllTags(on: req),
                       userRepository.getAllUsers(on: req)) { posts, tags, users in
            let presenter = try req.make(BlogPresenter.self)
            return presenter.indexView(on: req, posts: posts, tags: tags, authors: users)
        }
    }

//    func blogPostIndexRedirectHandler(request: Request) throws -> ResponseRepresentable {
//        return Response(redirect: pathCreator.createPath(for: pathCreator.blogPath), .permanent)
//    }

    func blogPostHandler(_ req: Request) throws -> Future<View> {
        let blogSlug = try req.parameters.next(String.self)
        let blogRepository = try req.make(BlogPostRepository.self)
        return blogRepository.getPost(on: req, slug: blogSlug).unwrap(or: Abort(.notFound)).flatMap { post in
            let userRepository = try req.make(BlogUserRepository.self)
            return userRepository.getUser(post.author, on: req).unwrap(or: Abort(.internalServerError)).flatMap { user in
                let presenter = try req.make(BlogPresenter.self)
                return presenter.postView(on: req, post: post, author: user)
            }
        }
    }

//    func tagViewHandler(request: Request) throws -> ResponseRepresentable {
//        let tagName: String = try request.parameters.next()
//
//        guard let decodedTagName = tagName.removingPercentEncoding else {
//            throw Abort.badRequest
//        }
//
//        guard let tag = try BlogTag.makeQuery().filter(BlogTag.Properties.name, decodedTagName).first() else {
//            throw Abort.notFound
//        }
//
//        let paginatedBlogPosts = try tag.sortedPosts().paginate(for: request)
//
//        return try viewFactory.tagView(uri: request.getURIWithHTTPSIfReverseProxy(), tag: tag, paginatedPosts: paginatedBlogPosts, user: getLoggedInUser(in: request))
//    }

    func authorViewHandler(_ req: Request) throws -> Future<View> {
        let authorUsername = try req.parameters.next(String.self)
        let userRepository = try req.make(BlogUserRepository.self)
        
        return userRepository.getUser(authorUsername, on: req).flatMap { user in
            guard let author = user else {
                throw Abort(.notFound)
            }
            
            let postRepository = try req.make(BlogPostRepository.self)
            return postRepository.getAllPostsSortedByPublishDate(on: req, for: author, includeDrafts: false).flatMap { posts in
                let presenter = try req.make(BlogPresenter.self)
                return presenter.authorView(on: req, author: author, posts: posts)
            }
        }
    }

//    func allTagsViewHandler(request: Request) throws -> ResponseRepresentable {
//        return try viewFactory.allTagsView(uri: request.getURIWithHTTPSIfReverseProxy(), allTags: BlogTag.all(), user: getLoggedInUser(in: request))
//    }

    func allAuthorsViewHandler(_ req: Request) throws -> Future<View> {
//        return try viewFactory.allAuthorsView(uri: request.getURIWithHTTPSIfReverseProxy(), allAuthors: BlogUser.all(), user: getLoggedInUser(in: request))
        let presenter = try req.make(BlogPresenter.self)
        let authorRepository = try req.make(BlogUserRepository.self)
        return authorRepository.getAllUsers(on: req).flatMap { allUsers in
            return presenter.allAuthorsView(on: req, authors: allUsers)
        }
    }

//    func tagApiHandler(request: Request) throws -> ResponseRepresentable {
//        return try JSON(node: BlogTag.all().makeNode(in: nil))
//    }
//    
//    func searchHandler(request: Request) throws -> ResponseRepresentable {
//        guard let searchTerm = request.query?["term"]?.string, searchTerm != "" else {
//            return try viewFactory.searchView(uri: request.getURIWithHTTPSIfReverseProxy(), searchTerm: nil, foundPosts: nil, emptySearch: true, user: getLoggedInUser(in: request))
//        }
//        
//        let posts = try BlogPost.makeQuery().filter(BlogPost.Properties.published, true).or { orGroup in
//            try orGroup.filter(BlogPost.Properties.title, .contains, searchTerm)
//            try orGroup.filter(BlogPost.Properties.contents, .contains, searchTerm)
//        }
//        .sort(BlogPost.Properties.created, .descending).paginate(for: request)
//        
//        return try viewFactory.searchView(uri: request.uri, searchTerm: searchTerm, foundPosts: posts, emptySearch: false, user: getLoggedInUser(in: request))
//    }
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
}

#warning("Move")
import Foundation

extension Request {
    func getURIWithHTTPSIfReverseProxy() -> URL {
        if http.headers["X-Forwarded-Proto"].first == "https" {
//            let uri = URI(scheme: "https", userInfo: self.http.uri.userInfo, hostname: self.http.uri.hostname, port: nil, path: self.http.uri.path, query: self.http.uri.query, fragment: self.http.uri.fragment)
            //            return uri
        }
        return self.http.url
    }
}

