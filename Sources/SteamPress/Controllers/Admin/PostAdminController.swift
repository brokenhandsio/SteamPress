import Vapor

struct PostAdminController: RouteCollection {
    
    // MARK: - Properties
    private let pathCreator: BlogPathCreator
    
    // MARK: - Initialiser
    init(pathCreator: BlogPathCreator) {
        self.pathCreator = pathCreator
    }
    
    // MARK: - Route setup
    func boot(router: Router) throws {
        router.get("createPost", use: createPostHandler)
        router.post("createPost", use: createPostPostHandler)
        router.post("posts", Int.parameter, "edit", use: editPostPostHandler)
        router.post("posts", Int.parameter, "delete", use: deletePostHandler)
    }
    
    // MARK: - Route handlers
    func createPostHandler(_ req: Request) throws -> Future<View> {
        let presenter = try req.make(BlogAdminPresenter.self)
        return presenter.createPostView(on: req, errors: nil)
    }
    
    func createPostPostHandler(_ req: Request) throws -> Future<Response> {
        let data = try req.content.syncDecode(CreatePostData.self)
        let author = try req.requireAuthenticated(BlogUser.self)
        
        if data.draft == nil && data.publish == nil {
            throw Abort(.badRequest)
        }
        
        if let createPostErrors = validatePostCreation(data) {
            let presenter = try req.make(BlogAdminPresenter.self)
            let view = presenter.createPostView(on: req, errors: createPostErrors)
            return try view.encode(for: req)
        }
        
        guard let title = data.title, let contents = data.contents, let slugURL = data.slugURL else {
            throw Abort(.internalServerError)
        }
        
        let newPost = try BlogPost(title: title, contents: contents, author: author, creationDate: Date(), slugUrl: slugURL, published: data.publish != nil)
        
        let postRepository = try req.make(BlogPostRepository.self)
        return postRepository.save(newPost, on: req).map { post in
            return req.redirect(to: self.pathCreator.createPath(for: "posts/\(post.slugUrl)"))
        }
        
        //        if let createPostErrors = validatePostCreation(title: rawTitle, contents: rawContents, slugUrl: rawSlugUrl) {
        //            return try viewFactory.createBlogPostView(uri: request.getURIWithHTTPSIfReverseProxy(), errors: createPostErrors, title: rawTitle, contents: rawContents, slugUrl: rawSlugUrl, tags: rawTags?.array, isEditing: false, postToEdit: nil, draft: true, user: try request.user())
        //        }
        //        // Make sure slugUrl is unique
        //        slugUrl = BlogPost.generateUniqueSlugUrl(from: slugUrl, logger: log)
        //        // Save the tags
        //        for tagNode in tagsArray {
        //            if let tagName = tagNode.string {
        //                try BlogTag.addTag(tagName, to: newPost)
        //            }
        //        }
    }

    func deletePostHandler(_ req: Request) throws -> Future<Response> {
        let postID = try req.parameters.next(Int.self)
        let postRepository = try req.make(BlogPostRepository.self)
        return postRepository.getPost(id: postID, on: req).unwrap(or: Abort(.notFound)).flatMap { post in
//            let tags = try post.tags.all()
//
//            // Clean up pivots
//            for tag in tags {
//                try tag.deletePivot(for: post)
//
//                // See if any of the tags need to be deleted
//                if try tag.posts.all().count == 0 {
//                    try tag.delete()
//                }
//            }
            let redirect = req.redirect(to: self.pathCreator.createPath(for: "admin"))
            return postRepository.delete(post, on: req).transform(to: redirect)
        }
    }

//    func editPostHandler(request: Request) throws -> ResponseRepresentable {
//        let post = try request.parameters.next(BlogPost.self)
//        let tags = try post.tags.all()
//        let tagsArray: [Node] = tags.map { $0.name.makeNode(in: nil) }
//        return try viewFactory.createBlogPostView(uri: request.getURIWithHTTPSIfReverseProxy(), errors: nil, title: post.title, contents: post.contents, slugUrl: post.slugUrl, tags: tagsArray, isEditing: true, postToEdit: post, draft: !post.published, user: try request.user())
//    }
    
    func editPostPostHandler(_ req: Request) throws -> Future<Response> {
        let data = try req.content.syncDecode(CreatePostData.self)
        let postID = try req.parameters.next(Int.self)
        let postRepository = try req.make(BlogPostRepository.self)
        
        return postRepository.getPost(id: postID, on: req).unwrap(or: Abort(.notFound)).flatMap { post in
            //        if let errors = validatePostCreation(title: rawTitle, contents: rawContents, slugUrl: rawSlugUrl) {
            //            return try viewFactory.createBlogPostView(uri: request.getURIWithHTTPSIfReverseProxy(), errors: errors, title: rawTitle, contents: rawContents, slugUrl: rawSlugUrl, tags: tagsArray, isEditing: true, postToEdit: post, draft: false, user: try request.user())
            //        }
            
            guard let title = data.title, let contents = data.contents, let slugUrl = data.slugURL else {
                throw Abort(.internalServerError)
            }
            
            post.title = title
            post.contents = contents
            post.slugUrl = slugUrl

//            if post.slugUrl != slugUrl {
//                post.slugUrl = BlogPost.generateUniqueSlugUrl(from: slugUrl, logger: log)
//            }
//
//            let existing = try post.tags.all()
//            let existingStringArray = existing.map { $0.name }
//            let newTagsStringArray = tagsArray.map { $0.string ?? "" }.filter { $0 != "" }
//
//            // Work out new tags and tags to delete
//            let existingSet: Set<String> = Set(existingStringArray)
//            let newTagSet: Set<String> = Set(newTagsStringArray)
//
//            let tagsToDelete = existingSet.subtracting(newTagSet)
//            let tagsToAdd = newTagSet.subtracting(existingSet)
//
//            for deleteTag in tagsToDelete {
//                let tag = try BlogTag.makeQuery().filter(BlogTag.Properties.name, deleteTag).first()
//                guard let tagToCleanUp = tag else {
//                    throw Abort.badRequest
//                }
//                try tagToCleanUp.deletePivot(for: post)
//                if try tagToCleanUp.posts.all().count == 0 {
//                    try tagToCleanUp.delete()
//                }
//            }
//
//            for newTagString in tagsToAdd {
//                try BlogTag.addTag(newTagString, to: post)
//            }
//
//            if post.published {
//                post.lastEdited = Date()
//            } else {
//                post.created = Date()
//                if publish != nil {
//                    post.published = true
//                }
//            }
//
            let redirect = req.redirect(to: self.pathCreator.createPath(for: "posts/\(post.slugUrl)"))
            return postRepository.save(post, on: req).transform(to: redirect)
        }
    }
    
    
    
    
    //    // MARK: - Validators
    private func validatePostCreation(_ data: CreatePostData) -> [String]? {
        var createPostErrors = [String]()
        
        if data.title.isEmptyOrWhitespace() {
            createPostErrors.append("You must specify a blog post title")
        }
        
        if data.contents.isEmptyOrWhitespace() {
            createPostErrors.append("You must have some content in your blog post")
        }
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

}

struct CreatePostData: Content {
    let title: String?
    let contents: String?
    let publish: Bool?
    let draft: Bool?
    let slugURL: String?
    #warning("Tags")
    #warning("Slug URL")
    #warning("Publish flag")
}

extension Optional where Wrapped == String {
    func isEmptyOrWhitespace() -> Bool {
        guard let string = self else {
            return true
        }
        
        return string.trimmingCharacters(in: .whitespaces).isEmpty
    }
}
