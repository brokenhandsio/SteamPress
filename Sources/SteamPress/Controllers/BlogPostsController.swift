import Vapor
import HTTP
import Routing
import MarkdownProvider

struct BlogPostsController {

    fileprivate let drop: Droplet
    fileprivate let pathCreator: BlogPathCreator
    fileprivate let viewFactory: PostLeafViewFactory
    fileprivate let blogPostsPath = "posts"
    fileprivate let log: LogProtocol

    // MARK: - Initialiser
    init(drop: Droplet, pathCreator: BlogPathCreator, viewFactory: PostLeafViewFactory) {
        self.drop = drop
        self.pathCreator = pathCreator
        self.viewFactory = viewFactory
        self.log = drop.log
    }

    // MARK: - Add routes
    func addRoutes() {
        drop.group(pathCreator.blogPath ?? "") { index in

            index.get(blogPostsPath, String.parameter, handler: blogPostHandler)
            index.get(blogPostsPath, handler: blogPostIndexRedirectHandler)
        }

        self.addAdminRoutes()
    }

    private func addAdminRoutes() {
        let router = drop.grouped(pathCreator.blogPath ?? "", "admin")
        let protect = BlogLoginRedirectAuthMiddleware(pathCreator: pathCreator)
        let routerSecure = router.grouped(protect)

        routerSecure.get("createPost", handler: createPostHandler)
        routerSecure.post("createPost", handler: createPostPostHandler)

        routerSecure.get("posts", BlogPost.parameter, "delete", handler: deletePostHandler)
        routerSecure.get("posts", BlogPost.parameter, "edit", handler: editPostHandler)
        routerSecure.post("posts", BlogPost.parameter, "edit", handler: editPostPostHandler)
    }

    func blogPostIndexRedirectHandler(request: Request) throws -> ResponseRepresentable {
        return Response(redirect: pathCreator.createPath(for: pathCreator.blogPath), .permanent)
    }

    func blogPostHandler(request: Request) throws -> ResponseRepresentable {
        let blogSlugUrl: String = try request.parameters.next()
        guard let blogPost = try BlogPost.makeQuery().filter(BlogPost.Properties.slugUrl, blogSlugUrl).first() else {
            throw Abort.notFound
        }

        guard let author = try blogPost.postAuthor.get() else {
            throw Abort.badRequest
        }

        return try viewFactory.blogPostView(uri: request.getURIWithHTTPSIfReverseProxy(), post: blogPost, author: author, user: try? request.user())
    }

    func createPostHandler(_ request: Request) throws -> ResponseRepresentable {
        return try viewFactory.createBlogPostView(uri: request.getURIWithHTTPSIfReverseProxy(), errors: nil, title: nil, contents: nil, slugUrl: nil, tags: nil, isEditing: false, postToEdit: nil, draft: true, user: try request.user())
    }

    func createPostPostHandler(_ request: Request) throws -> ResponseRepresentable {
        let rawTitle = request.data["inputTitle"]?.string
        let rawContents = request.data["inputPostContents"]?.string
        let rawTags = request.data["inputTags"]
        let rawSlugUrl = request.data["inputSlugUrl"]?.string
        let draft = request.data["save-draft"]?.string
        let publish = request.data["publish"]?.string

        if draft == nil && publish == nil {
            throw Abort.badRequest
        }

        let tagsArray = rawTags?.array ?? [rawTags?.string?.makeNode(in: nil) ?? nil]

        if let createPostErrors = validatePostCreation(title: rawTitle, contents: rawContents, slugUrl: rawSlugUrl) {
            return try viewFactory.createBlogPostView(uri: request.getURIWithHTTPSIfReverseProxy(), errors: createPostErrors, title: rawTitle, contents: rawContents, slugUrl: rawSlugUrl, tags: rawTags?.array, isEditing: false, postToEdit: nil, draft: true, user: try request.user())
        }

        guard let title = rawTitle, let contents = rawContents, var slugUrl = rawSlugUrl else {
            throw Abort.badRequest
        }

        let creationDate = Date()

        // Make sure slugUrl is unique
        slugUrl = BlogPost.generateUniqueSlugUrl(from: slugUrl, logger: log)

        var published = false

        if publish != nil {
            published = true
        }

        let newPost = BlogPost(title: title, contents: contents, author: try request.user(), creationDate: creationDate, slugUrl: slugUrl, published: published, logger: log)
        try newPost.save()

        // Save the tags
        for tagNode in tagsArray {
            if let tagName = tagNode.string {
                try BlogTag.addTag(tagName, to: newPost)
            }
        }

        return Response(redirect: pathCreator.createPath(for: "posts/\(newPost.slugUrl)"))
    }

    func deletePostHandler(request: Request) throws -> ResponseRepresentable {

        let post = try request.parameters.next(BlogPost.self)
        let tags = try post.tags.all()

        // Clean up pivots
        for tag in tags {
            try tag.deletePivot(for: post)

            // See if any of the tags need to be deleted
            if try tag.posts.all().count == 0 {
                try tag.delete()
            }
        }

        try post.delete()
        return Response(redirect: pathCreator.createPath(for: "admin"))
    }

    func editPostHandler(request: Request) throws -> ResponseRepresentable {
        let post = try request.parameters.next(BlogPost.self)
        let tags = try post.tags.all()
        let tagsArray: [Node] = tags.map { $0.name.makeNode(in: nil) }
        return try viewFactory.createBlogPostView(uri: request.getURIWithHTTPSIfReverseProxy(), errors: nil, title: post.title, contents: post.contents, slugUrl: post.slugUrl, tags: tagsArray, isEditing: true, postToEdit: post, draft: !post.published, user: try request.user())
    }

    func editPostPostHandler(request: Request) throws -> ResponseRepresentable {
        let post = try request.parameters.next(BlogPost.self)
        let rawTitle = request.data["inputTitle"]?.string
        let rawContents = request.data["inputPostContents"]?.string
        let rawTags = request.data["inputTags"]
        let rawSlugUrl = request.data["inputSlugUrl"]?.string
        let publish = request.data["publish"]?.string

        let tagsArray = rawTags?.array ?? [rawTags?.string?.makeNode(in: nil) ?? nil]

        if let errors = validatePostCreation(title: rawTitle, contents: rawContents, slugUrl: rawSlugUrl) {
            return try viewFactory.createBlogPostView(uri: request.getURIWithHTTPSIfReverseProxy(), errors: errors, title: rawTitle, contents: rawContents, slugUrl: rawSlugUrl, tags: tagsArray, isEditing: true, postToEdit: post, draft: false, user: try request.user())
        }

        guard let title = rawTitle, let contents = rawContents, let slugUrl = rawSlugUrl else {
            throw Abort.badRequest
        }

        post.title = title
        post.contents = contents
        if post.slugUrl != slugUrl {
            post.slugUrl = BlogPost.generateUniqueSlugUrl(from: slugUrl, logger: log)
        }

        let existing = try post.tags.all()
        let existingStringArray = existing.map { $0.name }
        let newTagsStringArray = tagsArray.map { $0.string ?? "" }.filter { $0 != "" }

        // Work out new tags and tags to delete
        let existingSet: Set<String> = Set(existingStringArray)
        let newTagSet: Set<String> = Set(newTagsStringArray)

        let tagsToDelete = existingSet.subtracting(newTagSet)
        let tagsToAdd = newTagSet.subtracting(existingSet)

        for deleteTag in tagsToDelete {
            let tag = try BlogTag.makeQuery().filter(BlogTag.Properties.name, deleteTag).first()
            guard let tagToCleanUp = tag else {
                throw Abort.badRequest
            }
            try tagToCleanUp.deletePivot(for: post)
            if try tagToCleanUp.posts.all().count == 0 {
                try tagToCleanUp.delete()
            }
        }

        for newTagString in tagsToAdd {
            try BlogTag.addTag(newTagString, to: post)
        }

        if post.published {
            post.lastEdited = Date()
        } else {
            post.created = Date()
            if publish != nil {
                post.published = true
            }
        }

        try post.save()

        return Response(redirect: pathCreator.createPath(for: "posts/\(post.slugUrl)"))
    }

    private func validatePostCreation(title: String?, contents: String?, slugUrl: String?) -> [String]? {
        var createPostErrors: [String] = []

        if title == nil || (title?.isWhitespace() ?? false) {
            createPostErrors.append("You must specify a blog post title")
        }

        if contents == nil || (contents?.isWhitespace() ?? false) {
            createPostErrors.append("You must have some content in your blog post")
        }

        if (slugUrl == nil || (slugUrl?.isWhitespace() ?? false)) && (!(title == nil || (title?.isWhitespace() ?? false))) {
            // The user can't manually edit this so if the title wasn't empty, we should never hit here
            createPostErrors.append("There was an error with your request, please try again")
        }

        if createPostErrors.count == 0 {
            return nil
        }

        return createPostErrors
    }
}
