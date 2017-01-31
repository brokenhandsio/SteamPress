import Vapor
import HTTP

struct ViewFactory {
    
    let drop: Droplet
    
    func createBlogPostView(errors: [String]? = nil, title: String? = nil, contents: String? = nil, labels: String? = nil, isEditing: Bool = false, postToEdit: BlogPost? = nil) throws -> View {
        let titleError = (title == nil || (title?.isWhitespace())!) && errors != nil
        let contentsError = (contents == nil || (contents?.isWhitespace())!) && errors != nil
        
        var parameters = [
            "titleError": titleError.makeNode(),
            "contentsError": contentsError.makeNode(),
            ]
        
        if let createBlogErrors = errors {
            parameters["errors"] = try createBlogErrors.makeNode()
        }
        
        if let titleSupplied = title {
            parameters["titleSupplied"] = titleSupplied.makeNode()
        }
        
        if let contentsSupplied = contents {
            parameters["contentsSupplied"] = contentsSupplied.makeNode()
        }
        
        if let labelsSupplied = labels {
            parameters["labelsSupplied"] = labelsSupplied.makeNode()
        }
        
        if isEditing {
            parameters["editing"] = isEditing.makeNode()
            guard let post = postToEdit else {
                throw Abort.badRequest
            }
            parameters["post"] = try post.makeNode()
        }
        else {
            parameters["createBlogPostPage"] = true
        }
        
        print("Create Post view parameters created with titleError set to \(titleError), contentsError set to \(contentsError), editing set to \(isEditing) and errors set to \(errors)")
        
        return try drop.view.make("blog/admin/createPost", parameters)
    }
    
    func createUserView(editing: Bool = false, errors: [String]? = nil, name: String? = nil, username: String? = nil, passwordError: Bool? = nil, confirmPasswordError: Bool? = nil, resetPasswordRequired: Bool? = nil, userId: Node? = nil) throws -> View {
        let nameError = name == nil && errors != nil
        let usernameError = username == nil && errors != nil
        
        var parameters = [
            "nameError": nameError.makeNode(),
            "usernameError": usernameError.makeNode(),
            ]
        
        if let createUserErrors = errors {
            parameters["errors"] = try createUserErrors.makeNode()
        }
        
        if let nameSupplied = name {
            parameters["nameSupplied"] = nameSupplied.makeNode()
        }
        
        if let usernameSupplied = username {
            parameters["usernameSupplied"] = usernameSupplied.makeNode()
        }
        
        if let passwordError = passwordError {
            parameters["passwordError"] = passwordError.makeNode()
        }
        
        if let confirmPasswordError = confirmPasswordError {
            parameters["confirmPasswordError"] = confirmPasswordError.makeNode()
        }
        
        if let _ = resetPasswordRequired {
            parameters["resetPasswordOnLoginSupplied"] = true
        }
        
        if editing {
            parameters["editing"] = true
            guard let userId = userId else {
                throw Abort.badRequest
            }
            parameters["userId"] = userId
        }
        
        print("Create User view parameters created with nameError set to \(nameError), usernameError set to \(usernameError), passwordError set to \(passwordError), confirmPasswordError set to \(confirmPasswordError) and errors set to \(errors)")
        
        return try drop.view.make("blog/admin/createUser", parameters)
    }
    
    func createLoginView(errors: [String]? = nil, username: String? = nil, password: String? = nil) throws -> View {
        let usernameError = username == nil && errors != nil
        let passwordError = password == nil && errors != nil
        
        var parameters = [
            "usernameError": usernameError.makeNode(),
            "passwordError": passwordError.makeNode()
        ]
        
        if let usernameSupplied = username {
            parameters["usernameSupplied"] = usernameSupplied.makeNode()
        }
        
        if let loginErrors = errors {
            parameters["errors"] = try loginErrors.makeNode()
        }
        
        print("Login view parameters created with usernameError set to \(usernameError), passwordError set to \(passwordError) and errors set to \(errors)")
        
        return try drop.view.make("blog/admin/login", parameters)
    }
    
    func createBlogAdminView(errors: [String]? = nil) throws -> View {
        let blogPosts = try BlogPost.all()
        let users = try BlogUser.all()
        
        var parameters = try Node(node: [
            "users": users.makeNode(context: BlogUserPasswordHidden())
            ])
        
        if blogPosts.count > 0 {
            parameters["posts"] = try blogPosts.makeNode(context: BlogPostContext.all)
        }
        
        if let errors = errors {
            parameters["errors"] = try errors.makeNode()
        }
        
        parameters["blogAdminPage"] = true
        
        return try drop.view.make("blog/admin/index", parameters)
    }
    
    func createResetPasswordView(errors: [String]? = nil, passwordError: Bool? = nil, confirmPasswordError: Bool? = nil) throws -> View {
        
        var parameters: [String: Node] = [:]
        
        if let resetPasswordErrors = errors {
            parameters["errors"] = try resetPasswordErrors.makeNode()
        }
        
        if let passwordError = passwordError {
            parameters["passwordError"] = passwordError.makeNode()
        }
        
        if let confirmPasswordError = confirmPasswordError {
            parameters["confirmPasswordError"] = confirmPasswordError.makeNode()
        }
        
        print("Reset Password view parameters created with passwordError set to \(passwordError), confirmPasswordError set to \(confirmPasswordError) and errors set to \(errors)")
        
        return try drop.view.make("blog/admin/resetPassword", parameters)
    }
    
    func createProfileView(user: BlogUser, isMyProfile: Bool) throws -> ResponseRepresentable {
        var parameters: [String: Node] = [
            "user": try user.makeNode(context: BlogUserPasswordHidden())
        ]
        
        if isMyProfile {
            parameters["myProfile"] = true.makeNode()
        }
        else {
            parameters["profilePage"] = true.makeNode()
        }
        
        if try user.posts().count > 0 {
            parameters["posts"] = try user.posts().makeNode(context: BlogPostContext.all)
        }
        
        return try drop.view.make("blog/profile", parameters)
    }
}
