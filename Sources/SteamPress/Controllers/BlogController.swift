import Vapor

struct BlogController: RouteCollection {

    // MARK: - Properties
    fileprivate let blogPostsPath = "posts"
    fileprivate let tagsPath = "tags"
    fileprivate let authorsPath = "authors"
    fileprivate let apiPath = "api"
    fileprivate let searchPath = "search"
    fileprivate let pathCreator: BlogPathCreator
    fileprivate let enableAuthorPages: Bool
    fileprivate let enableTagsPages: Bool
    fileprivate let postsPerPage: Int

    // MARK: - Initialiser
    init(pathCreator: BlogPathCreator, enableAuthorPages: Bool, enableTagPages: Bool, postsPerPage: Int) {
        self.pathCreator = pathCreator
        self.enableAuthorPages = enableAuthorPages
        self.enableTagsPages = enableTagPages
        self.postsPerPage = postsPerPage
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
            router.get(tagsPath, BlogTag.parameter, use: tagViewHandler)
            router.get(tagsPath, use: allTagsViewHandler)
        }
    }

    // MARK: - Route Handlers

    func indexHandler(_ req: Request) throws -> EventLoopFuture<View> {
        let postRepository = try req.make(BlogPostRepository.self)
        let tagRepository = try req.make(BlogTagRepository.self)
        let userRepository = try req.make(BlogUserRepository.self)
        let paginationInformation = req.getPaginationInformation(postsPerPage: postsPerPage)
        return flatMap(postRepository.getAllPostsSortedByPublishDate(includeDrafts: false, on: req, count: postsPerPage, offset: paginationInformation.offset),
                       tagRepository.getAllTags(on: req),
                       userRepository.getAllUsers(on: req)) { posts, tags, users in
            let presenter = try req.make(BlogPresenter.self)
            return presenter.indexView(on: req, posts: posts, tags: tags, authors: users, pageInformation: try req.pageInformation())
        }
    }

    func blogPostIndexRedirectHandler(_ req: Request) throws -> Response {
        return req.redirect(to: pathCreator.createPath(for: pathCreator.blogPath), type: .permanent)
    }

    func blogPostHandler(_ req: Request) throws -> EventLoopFuture<View> {
        let blogSlug = try req.parameters.next(String.self)
        let blogRepository = try req.make(BlogPostRepository.self)
        return blogRepository.getPost(slug: blogSlug, on: req).unwrap(or: Abort(.notFound)).flatMap { post in
            let userRepository = try req.make(BlogUserRepository.self)
            return userRepository.getUser(id: post.author, on: req).unwrap(or: Abort(.internalServerError)).flatMap { user in
                let presenter = try req.make(BlogPresenter.self)
                return presenter.postView(on: req, post: post, author: user, pageInformation: try req.pageInformation())
            }
        }
    }

    func tagViewHandler(_ req: Request) throws -> EventLoopFuture<View> {
        return try req.parameters.next(BlogTag.self).flatMap { tag in
            let postRepository = try req.make(BlogPostRepository.self)
            let paginationInformation = req.getPaginationInformation(postsPerPage: self.postsPerPage)
            return postRepository.getSortedPublishedPosts(for: tag, on: req, count: self.postsPerPage, offset: paginationInformation.offset).flatMap { posts in
                let presenter = try req.make(BlogPresenter.self)
                return presenter.tagView(on: req, tag: tag, posts: posts, pageInformation: try req.pageInformation())
            }
        }
    }

    func authorViewHandler(_ req: Request) throws -> EventLoopFuture<View> {
        let authorUsername = try req.parameters.next(String.self)
        let userRepository = try req.make(BlogUserRepository.self)
        let paginationInformation = req.getPaginationInformation(postsPerPage: postsPerPage)
        return userRepository.getUser(username: authorUsername, on: req).flatMap { user in
            guard let author = user else {
                throw Abort(.notFound)
            }

            let postRepository = try req.make(BlogPostRepository.self)
            let authorPostQuery = postRepository.getAllPostsSortedByPublishDate(for: author, includeDrafts: false, on: req, count: self.postsPerPage, offset: paginationInformation.offset)
            let authorPostCountQuery = postRepository.getPostCount(for: author, on: req)
            return flatMap(authorPostQuery, authorPostCountQuery) { posts, postCount in
                let presenter = try req.make(BlogPresenter.self)
                return presenter.authorView(on: req, author: author, posts: posts, postCount: postCount, pageInformation: try req.pageInformation())
            }
        }
    }

    func allTagsViewHandler(_ req: Request) throws -> EventLoopFuture<View> {
        let tagRepository = try req.make(BlogTagRepository.self)
        return tagRepository.getAllTagsWithPostCount(on: req).flatMap { tagswithCount in
            let presenter = try req.make(BlogPresenter.self)
            let allTags = tagswithCount.map { $0.0 }
            let tagCounts = try tagswithCount.reduce(into: [Int: Int]()) {
                guard let tagID = $1.0.tagID else {
                    throw SteamPressError(identifier: "BlogController", "Tag ID not set")
                }
                return $0[tagID] = $1.1
            }
            return presenter.allTagsView(on: req, tags: allTags, tagPostCounts: tagCounts, pageInformation: try req.pageInformation())
        }
    }

    func allAuthorsViewHandler(_ req: Request) throws -> EventLoopFuture<View> {
        let presenter = try req.make(BlogPresenter.self)
        let authorRepository = try req.make(BlogUserRepository.self)
        return authorRepository.getAllUsersWithPostCount(on: req).flatMap { allUsersWithCount in
            let allUsers = allUsersWithCount.map { $0.0 }
            let authorCounts = try allUsersWithCount.reduce(into: [Int: Int]()) {
                guard let userID = $1.0.userID else {
                    throw SteamPressError(identifier: "BlogController", "User ID not set")
                }
                return $0[userID] = $1.1
            }
            return presenter.allAuthorsView(on: req, authors: allUsers, authorPostCounts: authorCounts, pageInformation: try req.pageInformation())
        }
    }

    func searchHandler(_ req: Request) throws -> EventLoopFuture<View> {
        let preseneter = try req.make(BlogPresenter.self)
        guard let searchTerm = req.query[String.self, at: "term"], !searchTerm.isEmpty else {
            return preseneter.searchView(on: req, posts: [], authors: [], searchTerm: nil, pageInformation: try req.pageInformation())
        }

        let postRepository = try req.make(BlogPostRepository.self)
        let authorRepository = try req.make(BlogUserRepository.self)
        let postsQuery = postRepository.findPublishedPostsOrdered(for: searchTerm, on: req)
        let userQuery = authorRepository.getAllUsers(on: req)
        return flatMap(postsQuery, userQuery) { posts, users in
            return preseneter.searchView(on: req, posts: posts, authors: users, searchTerm: searchTerm, pageInformation: try req.pageInformation())
        }
    }

}
