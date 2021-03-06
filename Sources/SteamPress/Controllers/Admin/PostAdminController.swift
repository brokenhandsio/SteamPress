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
    func createPostHandler(_ req: Request) throws -> EventLoopFuture<View> {
        let presenter = try req.make(BlogAdminPresenter.self)
        return try presenter.createPostView(on: req, errors: nil, title: nil, contents: nil, slugURL: nil, tags: nil, isEditing: false, post: nil, isDraft: nil, titleError: false, contentsError: false, pageInformation: req.adminPageInfomation())
    }

    func createPostPostHandler(_ req: Request) throws -> EventLoopFuture<Response> {
        let data = try req.content.syncDecode(CreatePostData.self)
        let author = try req.requireAuthenticated(BlogUser.self)

        if data.draft == nil && data.publish == nil {
            throw Abort(.badRequest)
        }

        if let createPostErrors = validatePostCreation(data) {
            let presenter = try req.make(BlogAdminPresenter.self)
            let view = try presenter.createPostView(on: req, errors: createPostErrors.errors, title: data.title, contents: data.contents, slugURL: nil, tags: data.tags, isEditing: false, post: nil, isDraft: nil, titleError: createPostErrors.titleError, contentsError: createPostErrors.contentsError, pageInformation: req.adminPageInfomation())
            return try view.encode(for: req)
        }

        guard let title = data.title, let contents = data.contents else {
            throw Abort(.internalServerError)
        }

        return try BlogPost.generateUniqueSlugURL(from: title, on: req).flatMap { uniqueSlug in
            let newPost = try BlogPost(title: title, contents: contents, author: author, creationDate: Date(), slugUrl: uniqueSlug, published: data.publish != nil)

            let postRepository = try req.make(BlogPostRepository.self)
            return postRepository.save(newPost, on: req).flatMap { post in
                let tagsRepository = try req.make(BlogTagRepository.self)

                var existingTagsQuery = [EventLoopFuture<BlogTag?>]()
                for tagName in data.tags {
                    existingTagsQuery.append(tagsRepository.getTag(tagName, on: req))
                }

                return existingTagsQuery.flatten(on: req).flatMap { existingTagsWithOptionals in
                    let existingTags = existingTagsWithOptionals.compactMap { $0 }
                    var tagsSaves = [EventLoopFuture<BlogTag>]()
                    for tagName in data.tags {
                        if !existingTags.contains(where: { $0.name == tagName }) {
                            let tag = BlogTag(name: tagName)
                            tagsSaves.append(tagsRepository.save(tag, on: req))
                        }
                    }

                    return tagsSaves.flatten(on: req).flatMap { tags in
                        var tagLinks = [EventLoopFuture<Void>]()
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
    }

    func deletePostHandler(_ req: Request) throws -> EventLoopFuture<Response> {
        return try req.parameters.next(BlogPost.self).flatMap { post in
            let tagsRepository = try req.make(BlogTagRepository.self)
            return tagsRepository.deleteTags(for: post, on: req).flatMap {
                let redirect = req.redirect(to: self.pathCreator.createPath(for: "admin"))
                let postRepository = try req.make(BlogPostRepository.self)
                return postRepository.delete(post, on: req).transform(to: redirect)
            }
        }
    }

    func editPostHandler(_ req: Request) throws -> EventLoopFuture<View> {
        return try req.parameters.next(BlogPost.self).flatMap { post in
            let tagsRepository = try req.make(BlogTagRepository.self)
            return tagsRepository.getTags(for: post, on: req).flatMap { tags in
                let presenter = try req.make(BlogAdminPresenter.self)
                return try presenter.createPostView(on: req, errors: nil, title: post.title, contents: post.contents, slugURL: post.slugUrl, tags: tags.map { $0.name }, isEditing: true, post: post, isDraft: !post.published, titleError: false, contentsError: false, pageInformation: req.adminPageInfomation())
            }
        }
    }

    func editPostPostHandler(_ req: Request) throws -> EventLoopFuture<Response> {
        let data = try req.content.syncDecode(CreatePostData.self)
        return try req.parameters.next(BlogPost.self).flatMap { post in
            if let errors = self.validatePostCreation(data) {
                let presenter = try req.make(BlogAdminPresenter.self)
                return try presenter.createPostView(on: req, errors: errors.errors, title: data.title, contents: data.contents, slugURL: post.slugUrl, tags: data.tags, isEditing: true, post: post, isDraft: !post.published, titleError: errors.titleError, contentsError: errors.contentsError, pageInformation: req.adminPageInfomation()).encode(for: req)
            }

            guard let title = data.title, let contents = data.contents else {
                throw Abort(.internalServerError)
            }

            post.title = title
            post.contents = contents

            let slugURLFuture: EventLoopFuture<String>
            if let updateSlugURL = data.updateSlugURL, updateSlugURL {
                slugURLFuture = try BlogPost.generateUniqueSlugURL(from: title, on: req)
            } else {
                slugURLFuture = req.future(post.slugUrl)
            }

            return slugURLFuture.flatMap { slugURL in
                post.slugUrl = slugURL
                if post.published {
                    post.lastEdited = Date()
                } else {
                    post.created = Date()
                    if let publish = data.publish, publish {
                        post.published = true
                    }
                }

                let tagsRepository = try req.make(BlogTagRepository.self)
                return flatMap(tagsRepository.getTags(for: post, on: req), tagsRepository.getAllTags(on: req)) { existingTags, allTags in
                    let tagsToUnlink = existingTags.filter { (anExistingTag) -> Bool in
                        for tagName in data.tags {
                            if anExistingTag.name == tagName {
                                return false
                            }
                        }
                        return true
                    }
                    var removeTagLinkResults = [EventLoopFuture<Void>]()
                    for tagToUnlink in tagsToUnlink {
                        removeTagLinkResults.append(tagsRepository.remove(tagToUnlink, from: post, on: req))
                    }

                    let newTagsNames = data.tags.filter { (tagName) -> Bool in
                        !existingTags.contains { (existingTag) -> Bool in
                            existingTag.name == tagName
                        }
                    }

                    var tagCreateSaves = [EventLoopFuture<BlogTag>]()
                    for newTagName in newTagsNames {
                        let foundInAllTags = allTags.filter { $0.name == newTagName }.first
                        if let existingTag = foundInAllTags {
                            tagCreateSaves.append(req.future(existingTag))
                        } else {
                            let newTag = BlogTag(name: newTagName)
                            tagCreateSaves.append(tagsRepository.save(newTag, on: req))
                        }
                    }

                    return removeTagLinkResults.flatten(on: req).and(tagCreateSaves.flatten(on: req)).flatMap { (_, newTags) in
                        var postTagLinkResults = [EventLoopFuture<Void>]()
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
    }

    // MARK: - Validators
    private func validatePostCreation(_ data: CreatePostData) -> CreatePostErrors? {
        var createPostErrors = [String]()
        var titleError = false
        var contentsError = false

        if data.title.isEmptyOrWhitespace() {
            createPostErrors.append("You must specify a blog post title")
            titleError = true
        }

        if data.contents.isEmptyOrWhitespace() {
            createPostErrors.append("You must have some content in your blog post")
            contentsError = true
        }

        if createPostErrors.count == 0 {
            return nil
        }

        return CreatePostErrors(errors: createPostErrors, titleError: titleError, contentsError: contentsError)
    }

}
