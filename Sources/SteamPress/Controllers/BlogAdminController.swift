import Vapor
import HTTP
import Routing
import Auth
import Foundation
import Fluent

struct BlogAdminController {
    
    // MARK: - Properties
    fileprivate let drop: Droplet
    fileprivate let pathCreator: BlogPathCreator
    fileprivate let viewFactory: ViewFactory
    
    // MARK: - Initialiser
    init(drop: Droplet, pathCreator: BlogPathCreator, viewFactory: ViewFactory) {
        self.drop = drop
        self.pathCreator = pathCreator
        self.viewFactory = viewFactory
    }
    
    // MARK: - Route setup
    func addRoutes() {
        let router = drop.grouped(pathCreator.blogPath ?? "", "admin")
        
        router.get("login", handler: loginHandler)
        router.post("login", handler: loginPostHandler)
        router.get("logout", handler: logoutHandler)
        router.get("pivots", handler: pivotHandler)
        
        let protect = BlogAuthMiddleware(pathCreator: pathCreator)
        let routerSecure = router.grouped(protect)
        routerSecure.get(handler: adminHandler)
        routerSecure.get("createPost", handler: createPostHandler)
        routerSecure.post("createPost", handler: createPostPostHandler)
        routerSecure.get("createUser", handler: createUserHandler)
        routerSecure.post("createUser", handler: createUserPostHandler)
        routerSecure.get("profile", handler: profileHandler)
        routerSecure.get("posts", BlogPost.self, "delete", handler: deletePostHandler)
        routerSecure.get("posts", BlogPost.self, "edit", handler: editPostHandler)
        routerSecure.post("posts", BlogPost.self, "edit", handler: editPostPostHandler)
        routerSecure.get("users", BlogUser.self, "edit", handler: editUserHandler)
        routerSecure.post("users", BlogUser.self, "edit", handler: editUserPostHandler)
        routerSecure.get("users", BlogUser.self, "delete", handler: deleteUserPostHandler)
        routerSecure.get("resetPassword", handler: resetPasswordHandler)
        routerSecure.post("resetPassword", handler: resetPasswordPostHandler)
    }
    
    // MARK: - Route Handlers
    
    // MARK: - Blog Posts handlers
    func pivotHandler(_ request: Request) throws -> ResponseRepresentable {
        return try Pivot<BlogPost, BlogLabel>.all().makeJSON()
    }
    
    func createPostHandler(_ request: Request) throws -> ResponseRepresentable {
        return try viewFactory.createBlogPostView()
    }
    
    func createPostPostHandler(_ request: Request) throws -> ResponseRepresentable {
        let rawTitle = request.data["inputTitle"]?.string
        let rawContents = request.data["inputPostContents"]?.string
        let rawLabels = request.data["inputLabels"]?.string
        
        if let createPostErrors = validatePostCreation(title: rawTitle, contents: rawContents) {
            return try viewFactory.createBlogPostView(errors: createPostErrors, title: rawTitle, contents: rawContents, labels: rawLabels)
        }
        
        guard let user = try request.auth.user() as? BlogUser, let title = rawTitle, let contents = rawContents else {
            throw Abort.badRequest
        }
        
        let creationDate = Date()
        
        // Sort out our labels if we have any
        let labels = parseLabels(rawLabels)
        
        // Could probably unwrap this better
        var newPost = BlogPost(title: title, contents: contents, author: user, creationDate: creationDate)
        try newPost.save()
        
        // Save the labels
        for labelString in labels {
            try BlogLabel.addLabel(name: labelString, to: newPost)
        }
        
        // Should probably redirect to the page once created
        return Response(redirect: pathCreator.createPath(for: "admin"))
    }
    
    func deletePostHandler(request: Request, post: BlogPost) throws -> ResponseRepresentable {
        
        let labels = try post.labels()
        
        // Clean up pivots
        for label in labels {
            try label.deletePivot(for: post)
            
            // See if any of the labels need to be deleted
            if try label.blogPosts().count == 0 {
                try label.delete()
            }
        }
        
        try post.delete()
        return Response(redirect: pathCreator.createPath(for: "admin"))
    }
    
    func editPostHandler(request: Request, post: BlogPost) throws -> ResponseRepresentable {
        let labels = try post.labels()
        var labelsString = labels.reduce("",{$0 + $1.name + " "})
        var labelsSupplied: String? = nil
        if !labelsString.isEmpty {
            // Remove final ' '
            labelsString.remove(at: labelsString.index(before: labelsString.endIndex))
            labelsSupplied = labelsString
        }
        return try viewFactory.createBlogPostView(title: post.title, contents: post.contents, labels: labelsSupplied,isEditing: true, postToEdit: post)
    }
    
    func editPostPostHandler(request: Request, post: BlogPost) throws -> ResponseRepresentable {
        let rawTitle = request.data["inputTitle"]?.string
        let rawContents = request.data["inputPostContents"]?.string
        let rawLabels = request.data["inputLabels"]?.string
        
        if let errors = validatePostCreation(title: rawTitle, contents: rawContents) {
            return try viewFactory.createBlogPostView(errors: errors, title: rawTitle, contents: rawContents, labels: rawLabels, isEditing: true, postToEdit: post)
        }
        
        guard let title = rawTitle, let contents = rawContents else {
            throw Abort.badRequest
        }
        
        var post = post
        post.title = title
        post.contents = contents
        post.lastEdited = Date()
        
        let existing = try post.labels()
        let existingString = existing.map { $0.name }
        let newLabels: [String]
            
        if let newLabelsString = rawLabels {
            newLabels = parseLabels(newLabelsString)
        }
        else {
            newLabels = []
        }
        
        // Work out new labels and labels to delete
        let existingSet:Set<String> = Set(existingString)
        let newLabelSet:Set<String> = Set(newLabels)
        
        let labelsToDelete = existingSet.subtracting(newLabelSet)
        let labelsToAdd = newLabelSet.subtracting(existingSet)
        
        for deleteLabel in labelsToDelete {
            let label = try BlogLabel.query().filter("name", deleteLabel).first()
            guard let labelToCleanUp = label else {
                throw Abort.badRequest
            }
            try labelToCleanUp.deletePivot(for: post)
            if try labelToCleanUp.blogPosts().count == 0 {
                try labelToCleanUp.delete()
            }
        }
        
        for newLabelString in labelsToAdd {
            try BlogLabel.addLabel(name: newLabelString, to: post)
        }
        
        try post.save()
        
        return Response(redirect: pathCreator.createPath(for: "admin"))
    }
    
    // MARK: - User handlers
    func createUserHandler(_ request: Request) throws -> ResponseRepresentable {
        return try viewFactory.createUserView()
    }
    
    func createUserPostHandler(_ request: Request) throws -> ResponseRepresentable {
        
        let rawName = request.data["inputName"]?.string
        let rawUsername = request.data["inputUsername"]?.string
        let rawPassword = request.data["inputPassword"]?.string
        let rawConfirmPassword = request.data["inputConfirmPassword"]?.string
        let rawPasswordResetRequired = request.data["inputResetPasswordOnLogin"]?.string
        let resetPasswordRequired = rawPasswordResetRequired != nil
        
        let (createUserRawErrors, passwordRawError, confirmPasswordRawError) = validateUserSaveDataExists(edit: false, name: rawName, username: rawUsername, password: rawPassword, confirmPassword: rawConfirmPassword)
        
        // Return if we have any missing fields
        if (createUserRawErrors?.count)! > 0 {
            return try viewFactory.createUserView(errors: createUserRawErrors, name: rawName, username: rawUsername, passwordError: passwordRawError, confirmPasswordError: confirmPasswordRawError, resetPasswordRequired: resetPasswordRequired)
        }
        
        guard let name = rawName, let username = rawUsername?.lowercased(), let password = rawPassword, let confirmPassword = rawConfirmPassword else {
            throw Abort.badRequest
        }
        
        let (createUserErrors, passwordError, confirmPasswordError) = validateUserSaveData(edit: false, name: name, username: username, password: password, confirmPassword: confirmPassword)
        
        if (createUserErrors?.count)! > 0 {
            return try viewFactory.createUserView(errors: createUserErrors, name: name, username: username, passwordError: passwordError, confirmPasswordError: confirmPasswordError, resetPasswordRequired: resetPasswordRequired)
        }
        
        // We now have valid data
        let creds = BlogUserCredentials(username: username.lowercased(), password: password, name: name)
        if var user = try BlogUser.register(credentials: creds) as? BlogUser {
            if resetPasswordRequired {
                user.resetPasswordRequired = true
            }
            try user.save()
            return Response(redirect: pathCreator.createPath(for: "admin"))
        }
        else {
            return try viewFactory.createUserView(errors: ["There was an error creating the user. Please try again"], name: name, username: username, passwordError: passwordError, confirmPasswordError: confirmPasswordError, resetPasswordRequired: resetPasswordRequired)
        }
    }
    
    func editUserHandler(request: Request, user: BlogUser) throws -> ResponseRepresentable {
        return try viewFactory.createUserView(editing: true, name: user.name, username: user.username, userId: user.id)
    }
    
    func editUserPostHandler(request: Request, user: BlogUser) throws -> ResponseRepresentable {
        let rawName = request.data["inputName"]?.string
        let rawUsername = request.data["inputUsername"]?.string
        let rawPassword = request.data["inputPassword"]?.string
        let rawConfirmPassword = request.data["inputConfirmPassword"]?.string
        let rawPasswordResetRequired = request.data["inputResetPasswordOnLogin"]?.string
        let resetPasswordRequired = rawPasswordResetRequired != nil
        
        let (saveUserRawErrors, passwordRawError, confirmPasswordRawError) = validateUserSaveDataExists(edit: true, name: rawName, username: rawUsername, password: rawPassword, confirmPassword: rawConfirmPassword)
        
        // Return if we have any missing fields
        if (saveUserRawErrors?.count)! > 0 {
            return try viewFactory.createUserView(editing: true, errors: saveUserRawErrors, name: rawName, username: rawUsername, passwordError: passwordRawError, confirmPasswordError: confirmPasswordRawError, resetPasswordRequired: resetPasswordRequired, userId: user.id)
        }
        
        guard let name = rawName, let username = rawUsername else {
            throw Abort.badRequest
        }
        
        let (saveUserErrors, passwordError, confirmPasswordError) = validateUserSaveData(edit: true, name: name, username: username, password: rawPassword, confirmPassword: rawConfirmPassword, previousUsername: user.username)
        
        if (saveUserErrors?.count)! > 0 {
            return try viewFactory.createUserView(editing: true, errors: saveUserErrors, name: name, username: username, passwordError: passwordError, confirmPasswordError: confirmPasswordError, resetPasswordRequired: resetPasswordRequired, userId: user.id)
        }
        
        // We now have valid data
        guard let userId = user.id, var userToUpdate = try BlogUser.query().filter("id", userId).first() else {
            throw Abort.badRequest
        }
        userToUpdate.name = name
        userToUpdate.username = username
        
        if resetPasswordRequired {
            userToUpdate.resetPasswordRequired = true
        }
        
        if let password = rawPassword {
            let newCreds = BlogUserCredentials(username: username, password: password, name: name)
            let newUserPassword = BlogUser(credentials: newCreds)
            userToUpdate.password = newUserPassword.password
        }
        
        try userToUpdate.save()
        return Response(redirect: pathCreator.createPath(for: "admin"))
    }
    
    func deleteUserPostHandler(request: Request, user: BlogUser) throws -> ResponseRepresentable {
        guard let currentUser = try request.auth.user() as? BlogUser else {
            throw Abort.badRequest
        }
        
        // Check we have at least one user left
        let users = try BlogUser.all()
        if users.count <= 1 {
            return try viewFactory.createBlogAdminView(errors: ["You cannot delete the last user"])
        }
        // Make sure we aren't deleting ourselves!
        else if currentUser.id == user.id {
            return try viewFactory.createBlogAdminView(errors: ["You cannot delete yourself whilst logged in"])
        }
        else {
            try user.delete()
            return Response(redirect: pathCreator.createPath(for: "admin"))
        }
    }
    
    // MARK: - Login Handlers
    func loginHandler(_ request: Request) throws -> ResponseRepresentable {
        // See if we need to create an admin user on first login
        do {
            let users = try BlogUser.all()
            if users.count == 0 {
                let password = String.random()
                let creds = BlogUserCredentials(username: "admin", password: password, name: "Admin")
                if var user = try BlogUser.register(credentials: creds) as? BlogUser {
                    user.resetPasswordRequired = true
                    try user.save()
                    print("An Admin user been created for you - the username is admin and the password is \(password)")
                    print("You will be asked to change your password once you have logged in, please do this immediately!")
                }
            }
        }
        catch {
            print("There was an error creating a new admin user: \(error)")
        }
        
        return try viewFactory.createLoginView()
    }
    
    func loginPostHandler(_ request: Request) throws -> ResponseRepresentable {
        
        let rawUsername = request.data["inputUsername"]?.string
        let rawPassword = request.data["inputPassword"]?.string
        
        var loginErrors: [String] = []
        
        if rawUsername == nil {
            loginErrors.append("You must supply your username")
        }
        
        if rawPassword == nil {
            loginErrors.append("You must supply your password")
        }
        
        if loginErrors.count > 0 {
            return try viewFactory.createLoginView(errors: loginErrors, username: rawUsername, password: rawPassword)
        }
        
        guard let username = rawUsername, let password = rawPassword else {
            throw Abort.badRequest
        }
        
        let credentials = BlogUserCredentials(username: username.lowercased(), password: password)
        
        do {
            try request.auth.login(credentials)
            
            guard let _ = try request.auth.user() as? BlogUser else {
                throw Abort.badRequest
            }
            return Response(redirect: pathCreator.createPath(for: "admin"))
        }
        catch {
            print("Got error logging in \(error)")
            let loginError = ["Your username or password was incorrect"]
            return try viewFactory.createLoginView(errors: loginError, username: username, password: password)
        }
    }
    
    func logoutHandler(_ request: Request) throws -> ResponseRepresentable {
        try request.auth.logout()
        return Response(redirect: pathCreator.createPath(for: pathCreator.blogPath))
    }
    
    // MARK: Admin Handler
    func adminHandler(_ request: Request) throws -> ResponseRepresentable {
        return try viewFactory.createBlogAdminView()
    }
    
    // MARK: - Profile Handler
    func profileHandler(_ request: Request) throws -> ResponseRepresentable {
        
        guard let user = try request.auth.user() as? BlogUser else {
            throw Abort.badRequest
        }
        
        return try viewFactory.createProfileView(user: user, isMyProfile: true)
    }
    
    // MARK: - Password handlers
    func resetPasswordHandler(_ request: Request) throws -> ResponseRepresentable {
        return try viewFactory.createResetPasswordView()
    }
    
    func resetPasswordPostHandler(_ request: Request) throws -> ResponseRepresentable {
        let rawPassword = request.data["inputPassword"]?.string
        let rawConfirmPassword = request.data["inputConfirmPassword"]?.string
        var resetPasswordErrors: [String] = []
        var passwordError: Bool?
        var confirmPasswordError: Bool?
        
        if rawPassword == nil {
            resetPasswordErrors.append("You must specify a password")
            passwordError = true
        }
        
        if rawConfirmPassword == nil {
            resetPasswordErrors.append("You must confirm your password")
            confirmPasswordError = true
        }
        
        // Return if we have any missing fields
        if resetPasswordErrors.count > 0 {
            return try viewFactory.createResetPasswordView(errors: resetPasswordErrors, passwordError: passwordError, confirmPasswordError: confirmPasswordError)
        }
        
        guard let password = rawPassword, let confirmPassword = rawConfirmPassword else {
            throw Abort.badRequest
        }
        
        if password != confirmPassword {
            resetPasswordErrors.append("Your passwords must match!")
            passwordError = true
            confirmPasswordError = true
        }
        
        // Check password is valid
        let validPassword = password.passes(PasswordValidator.self)
        if !validPassword {
            resetPasswordErrors.append("Your password must contain a lowercase letter, an upperacase letter, a number and a symbol")
            passwordError = true
        }
        
        if resetPasswordErrors.count > 0 {
            return try viewFactory.createResetPasswordView(errors: resetPasswordErrors, passwordError: passwordError, confirmPasswordError: confirmPasswordError)
        }
        
        guard var user = try request.auth.user() as? BlogUser else {
            throw Abort.badRequest
        }
        
        // Use the credentials class to hash the password
        let newCreds = BlogUserCredentials(username: user.username, password: password, name: user.name)
        let updatedUser = BlogUser(credentials: newCreds)
        user.password = updatedUser.password
        user.resetPasswordRequired = false
        try user.save()
        
        return Response(redirect: pathCreator.createPath(for: "admin"))
    }
    
    // MARK: - Validators
    private func validatePostCreation(title: String?, contents: String?) -> [String]? {
        var createPostErrors: [String] = []
        
        if title == nil || (title?.isWhitespace())! {
            createPostErrors.append("You must specify a blog post title")
        }
        
        if contents == nil || (contents?.isWhitespace())! {
            createPostErrors.append("You must have some content in your blog post")
        }
        
        if createPostErrors.count == 0 {
            return nil
        }
        
        return createPostErrors
        
    }
    
    private func validateUserSaveDataExists(edit: Bool, name: String?, username: String?, password: String?, confirmPassword: String?) -> ([String]?, Bool?, Bool?) {
        var userSaveErrors: [String] = []
        var passwordError: Bool?
        var confirmPasswordError: Bool?
        
        if name == nil || (name?.isWhitespace())! {
            userSaveErrors.append("You must specify a name")
        }
        
        if username == nil || (username?.isWhitespace())! {
            userSaveErrors.append("You must specify a username")
        }
        
        if !edit {
            if password == nil {
                userSaveErrors.append("You must specify a password")
                passwordError = true
            }
            
            if confirmPassword == nil {
                userSaveErrors.append("You must confirm your password")
                confirmPasswordError = true
            }
        }
        
        return (userSaveErrors, passwordError, confirmPasswordError)
    }
    
    private func validateUserSaveData(edit: Bool, name: String, username: String, password: String?, confirmPassword: String?, previousUsername: String? = nil) -> ([String]?, Bool?, Bool?) {
        
        var userSaveErrors: [String] = []
        var passwordError: Bool?
        var confirmPasswordError: Bool?
        
        if password != confirmPassword {
            userSaveErrors.append("Your passwords must match!")
            passwordError = true
            confirmPasswordError = true
        }
        
        // Check name is valid
        let validName = name.passes(NameValidator.self)
        if !validName {
            userSaveErrors.append("The name provided is not valid")
        }
        
        // Check username is valid
        let validUsername = username.passes(UsernameValidator.self)
        if !validUsername {
            userSaveErrors.append("The username provided is not valid")
        }
        
        // Check password is valid
        if !edit || password != nil {
            guard let actualPassword = password else {
                fatalError()
            }
            let validPassword = actualPassword.passes(PasswordValidator.self)
            if !validPassword {
                userSaveErrors.append("Your password must contain a lowercase letter, an upperacase letter, a number and a symbol")
                passwordError = true
            }
        }
        
        // Check username unique
        do {
            if username != previousUsername {
                let usernames = try BlogUser.all().map { $0.username.lowercased() }
                if usernames.contains(username.lowercased()) {
                    userSaveErrors.append("Sorry that username has already been taken")
                }
            }
        }
        catch {
            userSaveErrors.append("Unable to validate username")
        }
        
        return (userSaveErrors, passwordError, confirmPasswordError)

        
    }
    
    fileprivate func parseLabels(_ labelsString: String?) -> [String] {
        guard let labelsString = labelsString else {
            return []
        }
        
        let labels = labelsString.components(separatedBy: " ")
        return labels
    }
    
}

// MARK: - Extensions
extension String {
    
    // TODO Could probably improve this
    static func random(length: Int = 8) -> String {
        let base = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        var randomString: String = ""
        
        for _ in 0..<length {
            let randomValue = Int.random(min: 0, max: base.characters.count)
            randomString += "\(base[base.index(base.startIndex, offsetBy: Int(randomValue))])"
        }
        return randomString
    }
    
    func isWhitespace() -> Bool {
        let whitespaceSet = CharacterSet.whitespacesAndNewlines
        if isEmpty || self.trimmingCharacters(in: whitespaceSet).isEmpty {
            return true
        }
        else {
            return false
        }
    }
}
