import Vapor
import URI
import HTTP
import Paginator

struct LeafViewFactory: ViewFactory {
    
    let drop: Droplet
    
    // MARK: - Admin Controller Views
    
    func createBlogPostView(uri: URI, errors: [String]? = nil, title: String? = nil, contents: String? = nil, slugUrl: String? = nil, tags: String? = nil, isEditing: Bool = false, postToEdit: BlogPost? = nil) throws -> View {
        let titleError = (title == nil || (title?.isWhitespace())!) && errors != nil
        let contentsError = (contents == nil || (contents?.isWhitespace())!) && errors != nil
        
        let postPathPrefix: String
        
        if isEditing {
            guard let editSubstringIndex = uri.description.range(of: "admin/posts")?.lowerBound else {
                throw Abort.serverError
            }
            postPathPrefix = uri.description.substring(to: editSubstringIndex) + "posts/"
        }
        else {
            postPathPrefix = uri.description.replacingOccurrences(of: "admin/createPost", with: "posts")
        }
        
        var parameters = [
            "postPathPrefix": postPathPrefix.makeNode(),
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
        
        if let slugUrlSupplied = slugUrl {
            parameters["slugUrlSupplied"] = slugUrlSupplied.makeNode()
        }
        
        if let tagsSupplied = tags {
            parameters["tagsSupplied"] = tagsSupplied.makeNode()
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
    
    func createLoginView(loginWarning: Bool = false, errors: [String]? = nil, username: String? = nil, password: String? = nil) throws -> View {
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
        
        if loginWarning {
            parameters["loginWarning"] = true
        }
        
        print("Login view parameters created with usernameError set to \(usernameError), passwordError set to \(passwordError) and errors set to \(errors)")
        
        return try drop.view.make("blog/admin/login", parameters)
    }
    
    func createBlogAdminView(errors: [String]? = nil) throws -> View {
        let blogPosts = try BlogPost.all()
        let users = try BlogUser.all()
        
        var parameters = try Node(node: [
            "users": users.makeNode()
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
    
    func createProfileView(user: BlogUser, isMyProfile: Bool, posts: [BlogPost], disqusName: String?) throws -> View {
        var parameters: [String: Node] = [
            "user": try user.makeNode()
        ]
        
        if isMyProfile {
            parameters["myProfile"] = true.makeNode()
        }
        else {
            parameters["profilePage"] = true.makeNode()
        }
        
        if posts.count > 0 {
            parameters["posts"] = try posts.makeNode(context: BlogPostContext.shortSnippet)
        }
        
        if let disqusName = disqusName {
            parameters["disqusName"] = disqusName.makeNode()
        }
        
        return try drop.view.make("blog/profile", parameters)
    }
    
    // MARK: - Blog Controller Views
    
    func blogIndexView(paginatedPosts: Paginator<BlogPost>, tags: [BlogTag], loggedInUser: BlogUser?, disqusName: String?) throws -> View {
        
        var parameters: [String: Node] = [:]
        
        if paginatedPosts.totalPages ?? 0 > 0 {
            parameters["posts"] = try paginatedPosts.makeNode(context: BlogPostContext.longSnippet)
        }
        
        if tags.count > 0 {
            parameters["tags"] = try tags.makeNode()
        }
        
        if let user = loggedInUser {
            parameters["user"] = try user.makeNode()
        }
        
        parameters["blogIndexPage"] = true
        
        if let disqusName = disqusName {
            parameters["disqusName"] = disqusName.makeNode()
        }
        
        return try drop.view.make("blog/blog", parameters)

    }
    
    func blogPostView(post: BlogPost, author: BlogUser, user: BlogUser?, disqusName: String?) throws -> View {
        
        var parameters = try Node(node: [
            "post": try post.makeNode(context: BlogPostContext.all),
            "author": try author.makeNode(),
            "blogPostPage": true.makeNode()
            ])
        
        if let user = user {
            parameters["user"] = try user.makeNode()
        }
        
        if let disqusName = disqusName {
            parameters["disqusName"] = disqusName.makeNode()
        }
        
        return try drop.view.make("blog/blogpost", parameters)
    }
    
    func tagView(tag: BlogTag, posts: [BlogPost], user: BlogUser?, disqusName: String?) throws -> View {
        
        var parameters: [String: Node] = [
            "tag": try tag.makeNode(),
            "tagPage": true.makeNode(),
        ]
        
        if posts.count > 0 {
            parameters["posts"] = try posts.makeNode(context: BlogPostContext.shortSnippet)
        }
        
        if let user = user {
            parameters["user"] = try user.makeNode()
        }
        
        if let disqusName = disqusName {
            parameters["disqusName"] = disqusName.makeNode()
        }
        
        return try drop.view.make("blog/tag", parameters)
    }
}
