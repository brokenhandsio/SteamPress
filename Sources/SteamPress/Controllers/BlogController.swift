import Vapor
//import HTTP
//import Routing
//import MarkdownProvider
//
//struct BlogController {
//
//    // MARK: - Properties
//    fileprivate let blogPostsPath = "posts"
//    fileprivate let tagsPath = "tags"
//    fileprivate let authorsPath = "authors"
//    fileprivate let apiPath = "api"
//    fileprivate let searchPath = "search"
//    fileprivate let drop: Droplet
//    fileprivate let pathCreator: BlogPathCreator
//    fileprivate let viewFactory: ViewFactory
//    fileprivate let enableAuthorsPages: Bool
//    fileprivate let enableTagsPages: Bool
//
//    // MARK: - Initialiser
//    init(drop: Droplet, pathCreator: BlogPathCreator, viewFactory: ViewFactory, enableAuthorsPages: Bool, enableTagsPages: Bool) {
//        self.drop = drop
//        self.pathCreator = pathCreator
//        self.viewFactory = viewFactory
//        self.enableAuthorsPages = enableAuthorsPages
//        self.enableTagsPages = enableTagsPages
//    }
//
//    // MARK: - Add routes
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
//
//    // MARK: - Route Handlers
//
//    func indexHandler(request: Request) throws -> ResponseRepresentable {
//        let tags = try BlogTag.all()
//        let authors = try BlogUser.all()
//        let paginatedBlogPosts = try BlogPost.makeQuery().filter(BlogPost.Properties.published, true).sort(BlogPost.Properties.created, .descending).paginate(for: request)
//
//        return try viewFactory.blogIndexView(uri: request.getURIWithHTTPSIfReverseProxy(), paginatedPosts: paginatedBlogPosts, tags: tags, authors: authors, loggedInUser: getLoggedInUser(in: request))
//    }
//
//    func blogPostIndexRedirectHandler(request: Request) throws -> ResponseRepresentable {
//        return Response(redirect: pathCreator.createPath(for: pathCreator.blogPath), .permanent)
//    }
//
//    func blogPostHandler(request: Request) throws -> ResponseRepresentable {
//        let blogSlugUrl: String = try request.parameters.next()
//        guard let blogPost = try BlogPost.makeQuery().filter(BlogPost.Properties.slugUrl, blogSlugUrl).first() else {
//            throw Abort.notFound
//        }
//
//        guard let author = try blogPost.postAuthor.get() else {
//            throw Abort.badRequest
//        }
//
//        return try viewFactory.blogPostView(uri: request.getURIWithHTTPSIfReverseProxy(), post: blogPost, author: author, user: getLoggedInUser(in: request))
//    }
//
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
//
//    func authorViewHandler(request: Request) throws -> ResponseRepresentable {
//        let authorUsername: String = try request.parameters.next()
//
//        guard let author = try BlogUser.makeQuery().filter(BlogUser.Properties.username, authorUsername).first() else {
//            throw Abort.notFound
//        }
//
//        let posts = try author.sortedPosts().paginate(for: request)
//
//        return try viewFactory.profileView(uri: request.getURIWithHTTPSIfReverseProxy(), author: author, paginatedPosts: posts, loggedInUser: getLoggedInUser(in: request))
//    }
//
//    func allTagsViewHandler(request: Request) throws -> ResponseRepresentable {
//        return try viewFactory.allTagsView(uri: request.getURIWithHTTPSIfReverseProxy(), allTags: BlogTag.all(), user: getLoggedInUser(in: request))
//    }
//
//    func allAuthorsViewHandler(request: Request) throws -> ResponseRepresentable {
//        return try viewFactory.allAuthorsView(uri: request.getURIWithHTTPSIfReverseProxy(), allAuthors: BlogUser.all(), user: getLoggedInUser(in: request))
//    }
//
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
//}

// TOOD move

extension Request {
    func getURIWithHTTPSIfReverseProxy() -> URI {
        if self.headers["X-Forwarded-Proto"] == "https" {
            let uri = URI(scheme: "https", userInfo: self.uri.userInfo, hostname: self.uri.hostname, port: nil, path: self.uri.path, query: self.uri.query, fragment: self.uri.fragment)
            return uri
        }

        return self.uri
    }
}

