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
        router.get("posts", BlogPost.parameter, "edit", use: editPostHandler)
        router.post("posts", BlogPost.parameter, "edit", use: editPostPostHandler)
        router.post("posts", BlogPost.parameter, "delete", use: deletePostHandler)
    }
    
    // MARK: - Route handlers
    func createPostHandler(_ req: Request) throws -> Future<View> {
        let presenter = try req.make(BlogAdminPresenter.self)
        return presenter.createPostView(on: req, errors: nil, title: nil, contents: nil, slugURL: nil, tags: nil, isEditing: false, post: nil, isDraft: nil)
    }
    
    func createPostPostHandler(_ req: Request) throws -> Future<Response> {
        let data = try req.content.syncDecode(CreatePostData.self)
        let author = try req.requireAuthenticated(BlogUser.self)
        
        if data.draft == nil && data.publish == nil {
            throw Abort(.badRequest)
        }
        
        if let createPostErrors = validatePostCreation(data) {
            let presenter = try req.make(BlogAdminPresenter.self)
            #warning("Test/sort out tags")
            let view = presenter.createPostView(on: req, errors: createPostErrors, title: data.title, contents: data.contents, slugURL: data.slugURL, tags: nil, isEditing: false, post: nil, isDraft: nil)
            return try view.encode(for: req)
        }
        
        guard let title = data.title, let contents = data.contents, let slugURL = data.slugURL else {
            throw Abort(.internalServerError)
        }
        
        let newPost = try BlogPost(title: title, contents: contents, author: author, creationDate: Date(), slugUrl: slugURL, published: data.publish != nil)
        
        let postRepository = try req.make(BlogPostRepository.self)
        return postRepository.save(newPost, on: req).flatMap { post in
            let tagsRepository = try req.make(BlogTagRepository.self)
            var tagsSaves = [Future<BlogTag>]()
            for tagName in data.tags {
                let tag = try BlogTag(name: tagName)
                tagsSaves.append(tagsRepository.save(tag, on: req))
            }
            return tagsSaves.flatten(on: req).flatMap { tags in
                var tagLinks = [Future<Void>]()
                for tag in tags {
                    tagLinks.append(tagsRepository.add(tag, to: post, on: req))
                }
                let redirect = req.redirect(to: self.pathCreator.createPath(for: "posts/\(post.slugUrl)"))
                return tagLinks.flatten(on: req).transform(to: redirect)
            }
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
        return try req.parameters.next(BlogPost.self).flatMap { post in
            let tagsRepository = try req.make(BlogTagRepository.self)
            return try tagsRepository.deleteTags(for: post, on: req).flatMap { tags in
                let redirect = req.redirect(to: self.pathCreator.createPath(for: "admin"))
                let postRepository = try req.make(BlogPostRepository.self)
                return postRepository.delete(post, on: req).transform(to: redirect)
            }
        }
    }

    func editPostHandler(_ req: Request) throws -> Future<View> {
        return try req.parameters.next(BlogPost.self).flatMap { post in
            #warning("Test tags")
//            let tags = try post.tags.all()
//            let tagsArray: [Node] = tags.map { $0.name.makeNode(in: nil) }
            let presenter = try req.make(BlogAdminPresenter.self)
            return presenter.createPostView(on: req, errors: nil, title: post.title, contents: post.contents, slugURL: post.slugUrl, tags: nil, isEditing: true, post: post, isDraft: !post.published)
        }
    }
    
    func editPostPostHandler(_ req: Request) throws -> Future<Response> {
        let data = try req.content.syncDecode(CreatePostData.self)
        return try req.parameters.next(BlogPost.self).flatMap { post in
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
            let postRepository = try req.make(BlogPostRepository.self)
            return postRepository.save(post, on: req).transform(to: redirect)
        }
    }
    
    
    
    
    // MARK: - Validators
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
