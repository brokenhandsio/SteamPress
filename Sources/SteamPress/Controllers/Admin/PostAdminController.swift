import Vapor

struct PostAdminController: RouteCollection {
    
    // MARK: - Properties
    
    // MARK: - Initialiser
    
    // MARK: - Route setup
    func boot(router: Router) throws {
        router.get("createPost", use: createPostHandler)
        router.post("createPost", use: createPostPostHandler)
    }
    
    // MARK: - Route handlers
    func createPostHandler(_ req: Request) throws -> Future<View> {
        let presenter = try req.make(BlogAdminPresenter.self)
        return presenter.createPostView(on: req, errors: nil)
    }
    
    func createPostPostHandler(_ req: Request) throws -> Future<Response> {
        let data = try req.content.syncDecode(CreatePostData.self)
        let author = try req.requireAuthenticated(BlogUser.self)
        
        if let createPostErrors = validatePostCreation(data) {
            let presenter = try req.make(BlogAdminPresenter.self)
            let view = presenter.createPostView(on: req, errors: createPostErrors)
            return try view.encode(for: req)
        }
        
        guard let title = data.title else {
            throw Abort(.internalServerError)
        }
        
        let newPost = try BlogPost(title: title, contents: data.content, author: author, creationDate: Date(), slugUrl: title, published: true)
        
        let postRepository = try req.make(BlogPostRepository.self)
        return postRepository.savePost(newPost, on: req).map { post in
            return req.redirect(to: "/")
        }
        
        //
        //        if draft == nil && publish == nil {
        //            throw Abort.badRequest
        //        }
        //
        //        if let createPostErrors = validatePostCreation(title: rawTitle, contents: rawContents, slugUrl: rawSlugUrl) {
        //            return try viewFactory.createBlogPostView(uri: request.getURIWithHTTPSIfReverseProxy(), errors: createPostErrors, title: rawTitle, contents: rawContents, slugUrl: rawSlugUrl, tags: rawTags?.array, isEditing: false, postToEdit: nil, draft: true, user: try request.user())
        //        }
        //
        //        guard let title = rawTitle, let contents = rawContents, var slugUrl = rawSlugUrl else {
        //            throw Abort.badRequest
        //        }
        //
        //        let creationDate = Date()
        //
        //        // Make sure slugUrl is unique
        //        slugUrl = BlogPost.generateUniqueSlugUrl(from: slugUrl, logger: log)
        //
        //        var published = false
        //
        //        if publish != nil {
        //            published = true
        //        }
        //
        //        let newPost = BlogPost(title: title, contents: contents, author: try request.user(), creationDate: creationDate, slugUrl: slugUrl, published: published, logger: log)
        //        try newPost.save()
        //
        //        // Save the tags
        //        for tagNode in tagsArray {
        //            if let tagName = tagNode.string {
        //                try BlogTag.addTag(tagName, to: newPost)
        //            }
        //        }
        //
        //        return Response(redirect: pathCreator.createPath(for: "posts/\(newPost.slugUrl)"))
    }
    
    //
    //    // MARK: - Validators
    private func validatePostCreation(_ data: CreatePostData) -> [String]? {
        var createPostErrors: [String] = []

        if data.title.isEmptyOrWhitespace() {
            createPostErrors.append("You must specify a blog post title")
        }

//        if contents == nil || (contents?.isWhitespace() ?? false) {
//            createPostErrors.append("You must have some content in your blog post")
//        }
//
//        if (slugUrl == nil || (slugUrl?.isWhitespace() ?? false)) && (!(title == nil || (title?.isWhitespace() ?? false))) {
//            // The user can't manually edit this so if the title wasn't empty, we should never hit here
//            createPostErrors.append("There was an error with your request, please try again")
//        }

        if createPostErrors.count == 0 {
            return nil
        }

        return createPostErrors
    }


    //    func deletePostHandler(request: Request) throws -> ResponseRepresentable {
    //
    //        let post = try request.parameters.next(BlogPost.self)
    //        let tags = try post.tags.all()
    //
    //        // Clean up pivots
    //        for tag in tags {
    //            try tag.deletePivot(for: post)
    //
    //            // See if any of the tags need to be deleted
    //            if try tag.posts.all().count == 0 {
    //                try tag.delete()
    //            }
    //        }
    //
    //        try post.delete()
    //        return Response(redirect: pathCreator.createPath(for: "admin"))
    //    }
    //
    //    func editPostHandler(request: Request) throws -> ResponseRepresentable {
    //        let post = try request.parameters.next(BlogPost.self)
    //        let tags = try post.tags.all()
    //        let tagsArray: [Node] = tags.map { $0.name.makeNode(in: nil) }
    //        return try viewFactory.createBlogPostView(uri: request.getURIWithHTTPSIfReverseProxy(), errors: nil, title: post.title, contents: post.contents, slugUrl: post.slugUrl, tags: tagsArray, isEditing: true, postToEdit: post, draft: !post.published, user: try request.user())
    //    }
    //
    //    func editPostPostHandler(request: Request) throws -> ResponseRepresentable {
    //        let post = try request.parameters.next(BlogPost.self)
    //        let rawTitle = request.data["inputTitle"]?.string
    //        let rawContents = request.data["inputPostContents"]?.string
    //        let rawTags = request.data["inputTags"]
    //        let rawSlugUrl = request.data["inputSlugUrl"]?.string
    //        let publish = request.data["publish"]?.string
    //
    //        let tagsArray = rawTags?.array ?? [rawTags?.string?.makeNode(in: nil) ?? nil]
    //
    //        if let errors = validatePostCreation(title: rawTitle, contents: rawContents, slugUrl: rawSlugUrl) {
    //            return try viewFactory.createBlogPostView(uri: request.getURIWithHTTPSIfReverseProxy(), errors: errors, title: rawTitle, contents: rawContents, slugUrl: rawSlugUrl, tags: tagsArray, isEditing: true, postToEdit: post, draft: false, user: try request.user())
    //        }
    //
    //        guard let title = rawTitle, let contents = rawContents, let slugUrl = rawSlugUrl else {
    //            throw Abort.badRequest
    //        }
    //
    //        post.title = title
    //        post.contents = contents
    //        if post.slugUrl != slugUrl {
    //            post.slugUrl = BlogPost.generateUniqueSlugUrl(from: slugUrl, logger: log)
    //        }
    //
    //        let existing = try post.tags.all()
    //        let existingStringArray = existing.map { $0.name }
    //        let newTagsStringArray = tagsArray.map { $0.string ?? "" }.filter { $0 != "" }
    //
    //        // Work out new tags and tags to delete
    //        let existingSet: Set<String> = Set(existingStringArray)
    //        let newTagSet: Set<String> = Set(newTagsStringArray)
    //
    //        let tagsToDelete = existingSet.subtracting(newTagSet)
    //        let tagsToAdd = newTagSet.subtracting(existingSet)
    //
    //        for deleteTag in tagsToDelete {
    //            let tag = try BlogTag.makeQuery().filter(BlogTag.Properties.name, deleteTag).first()
    //            guard let tagToCleanUp = tag else {
    //                throw Abort.badRequest
    //            }
    //            try tagToCleanUp.deletePivot(for: post)
    //            if try tagToCleanUp.posts.all().count == 0 {
    //                try tagToCleanUp.delete()
    //            }
    //        }
    //
    //        for newTagString in tagsToAdd {
    //            try BlogTag.addTag(newTagString, to: post)
    //        }
    //
    //        if post.published {
    //            post.lastEdited = Date()
    //        } else {
    //            post.created = Date()
    //            if publish != nil {
    //                post.published = true
    //            }
    //        }
    //
    //        try post.save()
    //
    //        return Response(redirect: pathCreator.createPath(for: "posts/\(post.slugUrl)"))
    //    }
    //
}

struct CreatePostData: Content {
    let title: String?
    let content: String
    let publish: Bool
    #warning("Tags")
    #warning("Drafts")
    #warning("Slug URL")
    #warning("Publish flag")
}

extension Optional where Wrapped == String {
    func isEmptyOrWhitespace() -> Bool {
        // Check nil
        guard let this = self else { return true }
        
        // Check empty string
        if this.isEmpty {
            return true
        }
        // Trim and check empty string
        return this.trimmingCharacters(in: .whitespaces).isEmpty
    }
}
