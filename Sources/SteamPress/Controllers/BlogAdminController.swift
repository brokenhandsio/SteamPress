//import Vapor
//import HTTP
//import Routing
////import AuthProvider
//import Foundation
//import Fluent
//import Validation
////import Cookies
//
//struct BlogAdminController {
//
//    // MARK: - Properties
//    fileprivate let drop: Droplet
//    fileprivate let pathCreator: BlogPathCreator
//    fileprivate let viewFactory: ViewFactory
//    fileprivate let log: LogProtocol
//
//    // MARK: - Initialiser
//    init(drop: Droplet, pathCreator: BlogPathCreator, viewFactory: ViewFactory) {
//        self.drop = drop
//        self.pathCreator = pathCreator
//        self.viewFactory = viewFactory
//        self.log = drop.log
//    }
//
//    // MARK: - Route setup
//    func addRoutes() {
//        let router = drop.grouped(pathCreator.blogPath ?? "", "admin")
//
//        router.get("login", handler: loginHandler)
//        router.post("login", handler: loginPostHandler)
//        router.get("logout", handler: logoutHandler)
//
//        let protect = BlogLoginRedirectAuthMiddleware(pathCreator: pathCreator)
//        let routerSecure = router.grouped(protect)
//        routerSecure.get(handler: adminHandler)
//        routerSecure.get("createPost", handler: createPostHandler)
//        routerSecure.post("createPost", handler: createPostPostHandler)
//        routerSecure.get("createUser", handler: createUserHandler)
//        routerSecure.post("createUser", handler: createUserPostHandler)
//        routerSecure.get("posts", BlogPost.parameter, "delete", handler: deletePostHandler)
//        routerSecure.get("posts", BlogPost.parameter, "edit", handler: editPostHandler)
//        routerSecure.post("posts", BlogPost.parameter, "edit", handler: editPostPostHandler)
//        routerSecure.get("users", BlogUser.parameter, "edit", handler: editUserHandler)
//        routerSecure.post("users", BlogUser.parameter, "edit", handler: editUserPostHandler)
//        routerSecure.get("users", BlogUser.parameter, "delete", handler: deleteUserPostHandler)
//        routerSecure.get("resetPassword", handler: resetPasswordHandler)
//        routerSecure.post("resetPassword", handler: resetPasswordPostHandler)
//    }
//
//    // MARK: - Route Handlers
//
//    // MARK: - Blog Posts handlers
//    func createPostHandler(_ request: Request) throws -> ResponseRepresentable {
//        return try viewFactory.createBlogPostView(uri: request.getURIWithHTTPSIfReverseProxy(), errors: nil, title: nil, contents: nil, slugUrl: nil, tags: nil, isEditing: false, postToEdit: nil, draft: true, user: try request.user())
//    }
//
//    func createPostPostHandler(_ request: Request) throws -> ResponseRepresentable {
//        let rawTitle = request.data["inputTitle"]?.string
//        let rawContents = request.data["inputPostContents"]?.string
//        let rawTags = request.data["inputTags"]
//        let rawSlugUrl = request.data["inputSlugUrl"]?.string
//        let draft = request.data["save-draft"]?.string
//        let publish = request.data["publish"]?.string
//
//        if draft == nil && publish == nil {
//            throw Abort.badRequest
//        }
//
//        let tagsArray = rawTags?.array ?? [rawTags?.string?.makeNode(in: nil) ?? nil]
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
//    }
//
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
//    // MARK: - User handlers
//    func createUserHandler(_ request: Request) throws -> ResponseRepresentable {
//        return try viewFactory.createUserView(editing: false, errors: nil, name: nil, username: nil, passwordError: nil, confirmPasswordError: nil, resetPasswordRequired: nil, userId: nil, profilePicture: nil, twitterHandle: nil, biography: nil, tagline: nil, loggedInUser: request.user())
//    }
//
//    func createUserPostHandler(_ request: Request) throws -> ResponseRepresentable {
//
//        let rawName = request.data["inputName"]?.string
//        let rawUsername = request.data["inputUsername"]?.string
//        let rawPassword = request.data["inputPassword"]?.string
//        let rawConfirmPassword = request.data["inputConfirmPassword"]?.string
//        let rawPasswordResetRequired = request.data["inputResetPasswordOnLogin"]?.string
//        let resetPasswordRequired = rawPasswordResetRequired != nil
//        let profilePicture = request.data["inputProfilePicture"]?.string
//        let tagline = request.data["inputTagline"]?.string
//        let biography = request.data["inputBiography"]?.string
//        let twitterHandle = request.data["inputTwitterHandle"]?.string
//
//        let (createUserRawErrors, passwordRawError, confirmPasswordRawError) = validateUserSaveDataExists(edit: false, name: rawName, username: rawUsername, password: rawPassword, confirmPassword: rawConfirmPassword, profilePicture: profilePicture)
//
//        // Return if we have any missing fields
//        if !(createUserRawErrors?.isEmpty ?? true) {
//            return try viewFactory.createUserView(editing: false, errors: createUserRawErrors, name: rawName, username: rawUsername, passwordError: passwordRawError, confirmPasswordError: confirmPasswordRawError, resetPasswordRequired: resetPasswordRequired, userId: nil, profilePicture: profilePicture, twitterHandle: twitterHandle, biography: biography, tagline: tagline, loggedInUser: request.user())
//        }
//
//        guard let name = rawName, let username = rawUsername?.lowercased(), let password = rawPassword, let confirmPassword = rawConfirmPassword else {
//            throw Abort.badRequest
//        }
//
//        let (createUserErrors, passwordError, confirmPasswordError) = validateUserSaveData(edit: false, name: name, username: username, password: password, confirmPassword: confirmPassword)
//
//        if !(createUserErrors?.isEmpty ?? true) {
//            return try viewFactory.createUserView(editing: false, errors: createUserErrors, name: name, username: username, passwordError: passwordError, confirmPasswordError: confirmPasswordError, resetPasswordRequired: resetPasswordRequired, userId: nil, profilePicture: profilePicture, twitterHandle: twitterHandle, biography: biography, tagline: tagline, loggedInUser: request.user())
//        }
//
//        // We now have valid data
//        let hashedPassword = try BlogUser.passwordHasher.make(password)
//        let newUser = BlogUser(name: name, username: username.lowercased(), password: hashedPassword, profilePicture: profilePicture, twitterHandle: twitterHandle, biography: biography, tagline: tagline)
//
//        if resetPasswordRequired {
//            newUser.resetPasswordRequired = true
//        }
//
//        do {
//            try newUser.save()
//        } catch {
//            return try viewFactory.createUserView(editing: false, errors: ["There was an error creating the user. Please try again"], name: name, username: username, passwordError: passwordError, confirmPasswordError: confirmPasswordError, resetPasswordRequired: resetPasswordRequired, userId: nil, profilePicture: profilePicture, twitterHandle: twitterHandle, biography: biography, tagline: tagline, loggedInUser: request.user())
//        }
//
//        return Response(redirect: pathCreator.createPath(for: "admin"))
//
//    }
//
//    func editUserHandler(request: Request) throws -> ResponseRepresentable {
//        let user = try request.parameters.next(BlogUser.self)
//        return try viewFactory.createUserView(editing: true, errors: nil, name: user.name, username: user.username, passwordError: nil, confirmPasswordError: nil, resetPasswordRequired: nil, userId: user.id, profilePicture: user.profilePicture, twitterHandle: user.twitterHandle, biography: user.biography, tagline: user.tagline, loggedInUser: request.user())
//    }
//
//    func editUserPostHandler(request: Request) throws -> ResponseRepresentable {
//        let user = try request.parameters.next(BlogUser.self)
//        let rawName = request.data["inputName"]?.string
//        let rawUsername = request.data["inputUsername"]?.string
//        let rawPassword = request.data["inputPassword"]?.string
//        let rawConfirmPassword = request.data["inputConfirmPassword"]?.string
//        let rawPasswordResetRequired = request.data["inputResetPasswordOnLogin"]?.string
//        let resetPasswordRequired = rawPasswordResetRequired != nil
//        let profilePicture = request.data["inputProfilePicture"]?.string
//        let tagline = request.data["inputTagline"]?.string
//        let biography = request.data["inputBiography"]?.string
//        let twitterHandle = request.data["inputTwitterHandle"]?.string
//
//        let (saveUserRawErrors, passwordRawError, confirmPasswordRawError) = validateUserSaveDataExists(edit: true, name: rawName, username: rawUsername, password: rawPassword, confirmPassword: rawConfirmPassword, profilePicture: profilePicture)
//
//        // Return if we have any missing fields
//        if !(saveUserRawErrors?.isEmpty ?? true) {
//            return try viewFactory.createUserView(editing: true, errors: saveUserRawErrors, name: rawName, username: rawUsername, passwordError: passwordRawError, confirmPasswordError: confirmPasswordRawError, resetPasswordRequired: resetPasswordRequired, userId: user.id, profilePicture: profilePicture, twitterHandle: twitterHandle, biography: biography, tagline: tagline, loggedInUser: request.user())
//        }
//
//        guard let name = rawName, let username = rawUsername else {
//            throw Abort.badRequest
//        }
//
//        let (saveUserErrors, passwordError, confirmPasswordError) = validateUserSaveData(edit: true, name: name, username: username, password: rawPassword, confirmPassword: rawConfirmPassword, previousUsername: user.username)
//
//        if !(saveUserErrors?.isEmpty ?? true) {
//            return try viewFactory.createUserView(editing: true, errors: saveUserErrors, name: name, username: username, passwordError: passwordError, confirmPasswordError: confirmPasswordError, resetPasswordRequired: resetPasswordRequired, userId: user.id, profilePicture: profilePicture, twitterHandle: twitterHandle, biography: biography, tagline: tagline, loggedInUser: request.user())
//        }
//
//        // We now have valid data
//        guard let userId = user.id, let userToUpdate = try BlogUser.find(userId) else {
//            throw Abort.badRequest
//        }
//        userToUpdate.name = name
//        userToUpdate.username = username
//        userToUpdate.profilePicture = profilePicture
//        userToUpdate.twitterHandle = twitterHandle
//        userToUpdate.biography = biography
//        userToUpdate.tagline = tagline
//
//        if resetPasswordRequired {
//            userToUpdate.resetPasswordRequired = true
//        }
//
//        if let password = rawPassword {
//            userToUpdate.password = try BlogUser.passwordHasher.make(password)
//        }
//
//        try userToUpdate.save()
//        return Response(redirect: pathCreator.createPath(for: "admin"))
//    }
//
//    func deleteUserPostHandler(request: Request) throws -> ResponseRepresentable {
//        let user = try request.parameters.next(BlogUser.self)
//        // Check we have at least one user left
//        let users = try BlogUser.all()
//        if users.count <= 1 {
//            return try viewFactory.createBlogAdminView(errors: ["You cannot delete the last user"], user: try request.user())
//        }
//        // Make sure we aren't deleting ourselves!
//        else if try request.user().id == user.id {
//            return try viewFactory.createBlogAdminView(errors: ["You cannot delete yourself whilst logged in"], user: try request.user())
//        } else {
//            try user.delete()
//            return Response(redirect: pathCreator.createPath(for: "admin"))
//        }
//    }
//
//    // MARK: - Login Handlers
//    func loginHandler(_ request: Request) throws -> ResponseRepresentable {
//        let loginRequired = request.uri.query == "loginRequired"
//        return try viewFactory.createLoginView(loginWarning: loginRequired, errors: nil, username: nil, password: nil)
//    }
//
//    func loginPostHandler(_ request: Request) throws -> ResponseRepresentable {
//        let rawUsername = request.data["inputUsername"]?.string
//        let rawPassword = request.data["inputPassword"]?.string
//        let rememberMe = request.data["remember-me"]?.string != nil
//
//        var loginErrors: [String] = []
//
//        if rawUsername == nil {
//            loginErrors.append("You must supply your username")
//        }
//
//        if rawPassword == nil {
//            loginErrors.append("You must supply your password")
//        }
//
//        if !loginErrors.isEmpty {
//            return try viewFactory.createLoginView(loginWarning: false, errors: loginErrors, username: rawUsername, password: rawPassword)
//        }
//
//        guard let username = rawUsername, let password = rawPassword else {
//            throw Abort.badRequest
//        }
//
//        let passwordCredentials = Password(username: username.lowercased(), password: password)
//
//        if rememberMe {
//            request.storage["remember_me"] = true
//        } else {
//            request.storage.removeValue(forKey: "remember_me")
//        }
//
//        do {
//            let user = try BlogUser.authenticate(passwordCredentials)
//            request.auth.authenticate(user)
//            return Response(redirect: pathCreator.createPath(for: "admin"))
//        } catch {
//            log.debug("Got error logging in \(error)")
//            let loginError = ["Your username or password was incorrect"]
//            return try viewFactory.createLoginView(loginWarning: false, errors: loginError, username: username, password: "")
//        }
//    }
//
//    func logoutHandler(_ request: Request) throws -> ResponseRepresentable {
//        try request.auth.unauthenticate()
//        return Response(redirect: pathCreator.createPath(for: pathCreator.blogPath))
//    }
//
//    // MARK: Admin Handler
//    func adminHandler(_ request: Request) throws -> ResponseRepresentable {
//        return try viewFactory.createBlogAdminView(errors: nil, user: try request.user())
//    }
//
//    // MARK: - Password handlers
//    func resetPasswordHandler(_ request: Request) throws -> ResponseRepresentable {
//        return try viewFactory.createResetPasswordView(errors: nil, passwordError: nil, confirmPasswordError: nil, user: request.user())
//    }
//
//    func resetPasswordPostHandler(_ request: Request) throws -> ResponseRepresentable {
//        let rawPassword = request.data["inputPassword"]?.string
//        let rawConfirmPassword = request.data["inputConfirmPassword"]?.string
//        var resetPasswordErrors: [String] = []
//        var passwordError: Bool?
//        var confirmPasswordError: Bool?
//
//        guard let password = rawPassword, let confirmPassword = rawConfirmPassword else {
//            if rawPassword == nil {
//                resetPasswordErrors.append("You must specify a password")
//                passwordError = true
//            }
//
//            if rawConfirmPassword == nil {
//                resetPasswordErrors.append("You must confirm your password")
//                confirmPasswordError = true
//            }
//
//            // Return if we have any missing fields
//            return try viewFactory.createResetPasswordView(errors: resetPasswordErrors, passwordError: passwordError, confirmPasswordError: confirmPasswordError, user: request.user())
//        }
//
//        if password != confirmPassword {
//            resetPasswordErrors.append("Your passwords must match!")
//            passwordError = true
//            confirmPasswordError = true
//        }
//
//        // Check password is valid
//        let validPassword = password.passes(PasswordValidator())
//        if !validPassword {
//            resetPasswordErrors.append("Your password must contain a lowercase letter, an upperacase letter, a number and a symbol")
//            passwordError = true
//        }
//
//        if !resetPasswordErrors.isEmpty {
//            return try viewFactory.createResetPasswordView(errors: resetPasswordErrors, passwordError: passwordError, confirmPasswordError: confirmPasswordError, user: request.user())
//        }
//
//        let user = try request.user()
//
//        user.password = try BlogUser.passwordHasher.make(password)
//        user.resetPasswordRequired = false
//        try user.save()
//
//        return Response(redirect: pathCreator.createPath(for: "admin"))
//    }
//
//    // MARK: - Validators
//    private func validatePostCreation(title: String?, contents: String?, slugUrl: String?) -> [String]? {
//        var createPostErrors: [String] = []
//
//        if title == nil || (title?.isWhitespace() ?? false) {
//            createPostErrors.append("You must specify a blog post title")
//        }
//
//        if contents == nil || (contents?.isWhitespace() ?? false) {
//            createPostErrors.append("You must have some content in your blog post")
//        }
//
//        if (slugUrl == nil || (slugUrl?.isWhitespace() ?? false)) && (!(title == nil || (title?.isWhitespace() ?? false))) {
//            // The user can't manually edit this so if the title wasn't empty, we should never hit here
//            createPostErrors.append("There was an error with your request, please try again")
//        }
//
//        if createPostErrors.count == 0 {
//            return nil
//        }
//
//        return createPostErrors
//    }
//
//    private func validateUserSaveDataExists(edit: Bool, name: String?, username: String?, password: String?, confirmPassword: String?, profilePicture: String?) -> ([String]?, Bool?, Bool?) {
//        var userSaveErrors: [String] = []
//        var passwordError: Bool?
//        var confirmPasswordError: Bool?
//
//        if name == nil || (name?.isWhitespace() ?? false) {
//            userSaveErrors.append("You must specify a name")
//        }
//
//        if username == nil || (username?.isWhitespace() ?? false) {
//            userSaveErrors.append("You must specify a username")
//        }
//
//        if !edit {
//            if password == nil {
//                userSaveErrors.append("You must specify a password")
//                passwordError = true
//            }
//
//            if confirmPassword == nil {
//                userSaveErrors.append("You must confirm your password")
//                confirmPasswordError = true
//            }
//        }
//
//        return (userSaveErrors, passwordError, confirmPasswordError)
//    }
//
//    private func validateUserSaveData(edit: Bool, name: String, username: String, password: String?, confirmPassword: String?, previousUsername: String? = nil) -> ([String]?, Bool?, Bool?) {
//
//        var userSaveErrors: [String] = []
//        var passwordError: Bool?
//        var confirmPasswordError: Bool?
//
//        if password != confirmPassword {
//            userSaveErrors.append("Your passwords must match!")
//            passwordError = true
//            confirmPasswordError = true
//        }
//
//        // Check name is valid
//        let validName = name.passes(NameValidator())
//        if !validName {
//            userSaveErrors.append("The name provided is not valid")
//        }
//
//        // Check username is valid
//        let validUsername = username.passes(UsernameValidator())
//        if !validUsername {
//            userSaveErrors.append("The username provided is not valid")
//        }
//
//        // Check password is valid
//        if !edit || password != nil {
//            guard let actualPassword = password else {
//                fatalError()
//            }
//            let validPassword = actualPassword.passes(PasswordValidator())
//            if !validPassword {
//                userSaveErrors.append("Your password must contain a lowercase letter, an upperacase letter, a number and a symbol")
//                passwordError = true
//            }
//        }
//
//        // Check username unique
//        do {
//            if username != previousUsername {
//                let usernames = try BlogUser.all().map { $0.username.lowercased() }
//                if usernames.contains(username.lowercased()) {
//                    userSaveErrors.append("Sorry that username has already been taken")
//                }
//            }
//        } catch {
//            userSaveErrors.append("Unable to validate username")
//        }
//
//        return (userSaveErrors, passwordError, confirmPasswordError)
//    }
//
//}
//
//// MARK: - Extensions
//extension String {
//
//    // TODO Could probably improve this
//    static func random(length: Int = 8) -> String {
//        let base = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
//        var randomString: String = ""
//
//        for _ in 0..<length {
//            #if swift(>=4)
//            let randomValue = Int.random(min: 0, max: base.count-1)
//            #else
//            let randomValue = Int.random(min: 0, max: base.characters.count-1)
//            #endif
//            randomString += "\(base[base.index(base.startIndex, offsetBy: Int(randomValue))])"
//        }
//        return randomString
//    }
//
//    func isWhitespace() -> Bool {
//        let whitespaceSet = CharacterSet.whitespacesAndNewlines
//        if isEmpty || self.trimmingCharacters(in: whitespaceSet).isEmpty {
//            return true
//        } else {
//            return false
//        }
//    }
//}

