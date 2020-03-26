import Vapor

struct BlogController: RouteCollection {

    // MARK: - Properties
    fileprivate let blogPostsPath = PathComponent(stringLiteral: "posts")
    fileprivate let tagsPath = PathComponent(stringLiteral: "tags")
    fileprivate let authorsPath = PathComponent(stringLiteral: "authors")
    fileprivate let apiPath = PathComponent(stringLiteral: "api")
    fileprivate let searchPath = PathComponent(stringLiteral: "search")
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
    func boot(routes: RoutesBuilder) throws {
        routes.get(use: indexHandler)
        routes.get(blogPostsPath, ":blogSlug", use: blogPostHandler)
        routes.get(blogPostsPath, use: blogPostIndexRedirectHandler)
        routes.get(searchPath, use: searchHandler)
        if enableAuthorPages {
            routes.get(authorsPath, use: allAuthorsViewHandler)
            routes.get(authorsPath, ":authorUsername", use: authorViewHandler)
        }
        if enableTagsPages {
            routes.get(tagsPath, BlogTag.parameter, use: tagViewHandler)
            routes.get(tagsPath, use: allTagsViewHandler)
        }
    }

    // MARK: - Route Handlers

    func indexHandler(_ req: Request) throws -> EventLoopFuture<View> {
        let paginationInformation = req.getPaginationInformation(postsPerPage: postsPerPage)
        return req.blogPostRepository.getAllPostsSortedByPublishDate(includeDrafts: false, count: postsPerPage, offset: paginationInformation.offset).and(req.blogTagRepository.getAllTags()).flatMap { posts, tags in
            req.blogUserRepository.getAllUsers().and(req.blogPostRepository.getAllPostsCount(includeDrafts: false)).flatMap { users, totalPostCount in
                req.blogTagRepository.getTagsForAllPosts().flatMap { tagsForPosts in
                    let presenter = try req.make(BlogPresenter.self)
                    return presenter.indexView(on: req, posts: posts, tags: tags, authors: users, tagsForPosts: tagsForPosts, pageInformation: try req.pageInformation(), paginationTagInfo: self.getPaginationInformation(currentPage: paginationInformation.page, totalPosts: totalPostCount, currentQuery: req.http.url.query))
                }
            }
        }
    }

    func blogPostIndexRedirectHandler(_ req: Request) throws -> Response {
        return req.redirect(to: pathCreator.createPath(for: pathCreator.blogPath), type: .permanent)
    }

    func blogPostHandler(_ req: Request) throws -> EventLoopFuture<View> {
        guard let blogSlug = req.parameters.get("blogSlug") else {
            throw Abort(.badRequest)
        }
        return req.blogPostRepository.getPost(slug: blogSlug).unwrap(or: Abort(.notFound)).flatMap { post in
            let tagsQuery = req.blogTagsRepository.getTags(for: post, on: req)
            let userQuery = req.blogUserRepository.getUser(id: post.author, on: req).unwrap(or: Abort(.internalServerError))
            return userQuery.and(tagsQuery).flatMap { user, tags in
                let presenter = try req.make(BlogPresenter.self)
                return presenter.postView(on: req, post: post, author: user, tags: tags, pageInformation: try req.pageInformation())
            }
        }
    }

    func tagViewHandler(_ req: Request) throws -> EventLoopFuture<View> {
        return try req.parameters.next(BlogTag.self).flatMap { tag in
            let paginationInformation = req.getPaginationInformation(postsPerPage: self.postsPerPage)
            let postsQuery = req.blogPostRepository.getSortedPublishedPosts(for: tag, count: self.postsPerPage, offset: paginationInformation.offset)
            let postCountQuery = req.blogPostRepository.getPublishedPostCount(for: tag)
            let usersQuery = req.blogUsersRepository.getAllUsers()
            return flatMap(postsQuery, postCountQuery, usersQuery) { posts, totalPosts, authors in
                let presenter = try req.make(BlogPresenter.self)
                let paginationTagInfo = self.getPaginationInformation(currentPage: paginationInformation.page, totalPosts: totalPosts, currentQuery: req.http.url.query)
                return presenter.tagView(on: req, tag: tag, posts: posts, authors: authors, totalPosts: totalPosts, pageInformation: try req.pageInformation(), paginationTagInfo: paginationTagInfo)
            }
        }
    }

    func authorViewHandler(_ req: Request) throws -> EventLoopFuture<View> {
        guard let authorUsername = req.parameters.get("authorUsername") else {
            throw Abort(.badRequest)
        }
        let paginationInformation = req.getPaginationInformation(postsPerPage: postsPerPage)
        return req.blogUserRepository.getUser(username: authorUsername).flatMap { user in
            guard let author = user else {
                throw Abort(.notFound)
            }
            let authorPostQuery = req.blogPostRepository.getAllPostsSortedByPublishDate(for: author, includeDrafts: false, count: self.postsPerPage, offset: paginationInformation.offset)
            let tagQuery = req.blogTagRepository.getTagsForAllPosts()
            let authorPostCountQuery = req.blogPostRepository.getPostCount(for: author)
            return authorPostQuery.and(authorPostCountQuery).flatMap { posts, postCount in
                tagQuery.flatMap { tagsForPosts in
                    let presenter = try req.make(BlogPresenter.self)
                    let paginationTagInfo = self.getPaginationInformation(currentPage: paginationInformation.page, totalPosts: postCount, currentQuery: req.http.url.query)
                    return presenter.authorView(on: req, author: author, posts: posts, postCount: postCount, tagsForPosts: tagsForPosts, pageInformation: try req.pageInformation(), paginationTagInfo: paginationTagInfo)
                }
            }
        }
    }

    func allTagsViewHandler(_ req: Request) throws -> EventLoopFuture<View> {
        return req.blogTagRepository.getAllTagsWithPostCount().flatMap { tagswithCount in
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
        return req.blogUserRepository.getAllUsersWithPostCount().flatMap { allUsersWithCount in
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
        let paginationInformation = req.getPaginationInformation(postsPerPage: postsPerPage)
        guard let searchTerm = req.query[String.self, at: "term"], !searchTerm.isEmpty else {
            let paginationTagInfo = getPaginationInformation(currentPage: paginationInformation.page, totalPosts: 0, currentQuery: req.url.query)
            return preseneter.searchView(on: req, totalResults: 0, posts: [], authors: [], searchTerm: nil, tagsForPosts: [:], pageInformation: try req.pageInformation(), paginationTagInfo: paginationTagInfo)
        }

        let postsCountQuery = req.blogPostRepository.getPublishedPostCount(for: searchTerm)
        let postsQuery = req.blogPostRepository.findPublishedPostsOrdered(for: searchTerm, count: self.postsPerPage, offset: paginationInformation.offset)
        let tagsQuery = req.blogTagRepository.getTagsForAllPosts()
        let userQuery = req.blogUserRepository.getAllUsers()
        return postsQuery.and(postsCountQuery).flatMap { posts, totalPosts in
            userQuery.and(tagsQuery).flatMap { users, tagsForPosts in
                let paginationTagInfo = self.getPaginationInformation(currentPage: paginationInformation.page, totalPosts: totalPosts, currentQuery: req.url.query)
                return preseneter.searchView(on: req, totalResults: totalPosts, posts: posts, authors: users, searchTerm: searchTerm, tagsForPosts: tagsForPosts, pageInformation: try req.pageInformation(), paginationTagInfo: paginationTagInfo)
            }
        }
    }
    
    func getPaginationInformation(currentPage: Int, totalPosts: Int, currentQuery: String?) -> PaginationTagInformation {
        let totalPages = Int(ceil(Double(totalPosts) / Double(postsPerPage)))
        return PaginationTagInformation(currentPage: currentPage, totalPages: totalPages, currentQuery: currentQuery)
    }

}
