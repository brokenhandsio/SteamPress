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
            let view = presenter.createPostView(on: req, errors: createPostErrors, title: data.title, contents: data.contents, slugURL: data.slugURL, tags: data.tags, isEditing: false, post: nil, isDraft: nil)
            return try view.encode(for: req)
        }
        
        guard let title = data.title, let contents = data.contents, let slugURL = data.slugURL else {
            throw Abort(.internalServerError)
        }
        
        //        // Make sure slugUrl is unique
        //        slugUrl = BlogPost.generateUniqueSlugUrl(from: slugUrl, logger: log)
        
        let newPost = try BlogPost(title: title, contents: contents, author: author, creationDate: Date(), slugUrl: slugURL, published: data.publish != nil)
        
        let postRepository = try req.make(BlogPostRepository.self)
        return postRepository.save(newPost, on: req).flatMap { post in
            let tagsRepository = try req.make(BlogTagRepository.self)
            
            var existingTagsQuery = [Future<BlogTag?>]()
            for tagName in data.tags {
                try existingTagsQuery.append(tagsRepository.getTag(BlogTag.percentEncodedTagName(from: tagName), on: req))
            }
            
            return existingTagsQuery.flatten(on: req).flatMap { existingTagsWithOptionals in
                let existingTags = existingTagsWithOptionals.compactMap { $0 }
                var tagsSaves = [Future<BlogTag>]()
                for tagName in data.tags {
                    if try !existingTags.contains { try $0.name == BlogTag.percentEncodedTagName(from: tagName) } {
                        let tag = try BlogTag(name: tagName)
                        tagsSaves.append(tagsRepository.save(tag, on: req))
                    }
                }

                return tagsSaves.flatten(on: req).flatMap { tags in
                    var tagLinks = [Future<Void>]()
                    for tag in tags {
                        tagLinks.append(tagsRepository.add(tag, to: post, on: req))
                    }
                    for tag in existingTags {
                        tagLinks.append(tagsRepository.add(tag, to: post, on: req))
                    }
                    let redirect = req.redirect(to: self.pathCreator.createPath(for: "posts/\(post.slugUrl)"))
                    return tagLinks.flatten(on: req).transform(to: redirect)
                }
            }
        }
    }

    func deletePostHandler(_ req: Request) throws -> Future<Response> {
        return try req.parameters.next(BlogPost.self).flatMap { post in
            let tagsRepository = try req.make(BlogTagRepository.self)
            return tagsRepository.deleteTags(for: post, on: req).flatMap { tags in
                let redirect = req.redirect(to: self.pathCreator.createPath(for: "admin"))
                let postRepository = try req.make(BlogPostRepository.self)
                return postRepository.delete(post, on: req).transform(to: redirect)
            }
        }
    }

    func editPostHandler(_ req: Request) throws -> Future<View> {
        return try req.parameters.next(BlogPost.self).flatMap { post in
            let tagsRepository = try req.make(BlogTagRepository.self)
            return tagsRepository.getTags(for: post, on: req).flatMap { tags in
                let presenter = try req.make(BlogAdminPresenter.self)
                return presenter.createPostView(on: req, errors: nil, title: post.title, contents: post.contents, slugURL: post.slugUrl, tags: tags.map { $0.name }, isEditing: true, post: post, isDraft: !post.published)
            }
        }
    }
    
    func editPostPostHandler(_ req: Request) throws -> Future<Response> {
        let data = try req.content.syncDecode(CreatePostData.self)
        return try req.parameters.next(BlogPost.self).flatMap { post in
            if let errors = self.validatePostCreation(data) {
                let presenter = try req.make(BlogAdminPresenter.self)
                return try presenter.createPostView(on: req, errors: errors, title: data.title, contents: data.contents, slugURL: data.slugURL, tags: data.tags, isEditing: true, post: post, isDraft: !post.published).encode(for: req)
            }
            
            guard let title = data.title, let contents = data.contents, let slugUrl = data.slugURL else {
                throw Abort(.internalServerError)
            }
            
            post.title = title
            post.contents = contents
            
//            if post.slugUrl != slugUrl {
//                post.slugUrl = BlogPost.generateUniqueSlugUrl(from: slugUrl, logger: log)
//            }
            post.slugUrl = slugUrl
            
            if post.published {
                post.lastEdited = Date()
            } else {
                post.created = Date()
                if let publish = data.publish, publish {
                    post.published = true
                }
            }
            
            let tagsRepository = try req.make(BlogTagRepository.self)
            return tagsRepository.getTags(for: post, on: req).flatMap { existingTags in
                let tagsToUnlink = try existingTags.filter { (anExistingTag) -> Bool in
                    for tagName in data.tags {
                        if try anExistingTag.name == BlogTag.percentEncodedTagName(from: tagName) {
                            return false
                        }
                    }
                    return true
                }
                var removeTagLinkResults = [Future<Void>]()
                for tagToUnlink in tagsToUnlink {
                    removeTagLinkResults.append(tagsRepository.remove(tagToUnlink, from: post, on: req))
                }
                
                let newTagsNames = try data.tags.filter { (tagName) -> Bool in
                    try !existingTags.contains { (existingTag) -> Bool in
                        try existingTag.name == BlogTag.percentEncodedTagName(from: tagName)
                    }
                }
                
                var tagCreateSaves = [Future<BlogTag>]()
                for newTagName in newTagsNames {
                    let newTag = try BlogTag(name: newTagName)
                    tagCreateSaves.append(tagsRepository.save(newTag, on: req))
                }
                
                return removeTagLinkResults.flatten(on: req).and(tagCreateSaves.flatten(on: req)).flatMap { (_, newTags) in
                    var postTagLinkResults = [Future<Void>]()
                    for tag in newTags {
                        postTagLinkResults.append(tagsRepository.add(tag, to: post, on: req))
                    }
                    return postTagLinkResults.flatten(on: req).flatMap {
                        let redirect = req.redirect(to: self.pathCreator.createPath(for: "posts/\(post.slugUrl)"))
                        let postRepository = try req.make(BlogPostRepository.self)
                        return postRepository.save(post, on: req).transform(to: redirect)
                    }
                }
            }
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
