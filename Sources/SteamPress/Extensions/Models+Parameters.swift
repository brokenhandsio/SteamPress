import Vapor

extension BlogUser: ParameterModel {
//    typealias Repository = BlogUserRepository
    public static let parameterKey = "blogUserID"
    public static let parameter = PathComponent(stringLiteral: ":\(BlogPost.parameterKey)")
    
//    public typealias ResolvedParameter = EventLoopFuture<BlogUser>
//    public static func resolveParameter(_ parameter: String, on container: Container) throws -> BlogUser.ResolvedParameter {
//        let userRepository = try container.make(BlogUserRepository.self)
//        guard let userID = Int(parameter) else {
//            throw SteamPressError(identifier: "Invalid-ID-Type", "Unable to convert \(parameter) to a User ID")
//        }
//        return userRepository.getUser(id: userID, on: container).unwrap(or: Abort(.notFound))
//    }
}

extension BlogPost: ParameterModel {
//    typealias Repository = BlogPostRepository
    public static let parameterKey = "blogPostID"
    public static let parameter = PathComponent(stringLiteral: ":\(BlogPost.parameterKey)")
    
//    public typealias ResolvedParameter = EventLoopFuture<BlogPost>
//    public static func resolveParameter(_ parameter: String, on container: Container) throws -> EventLoopFuture<BlogPost> {
//        let postRepository = try container.make(BlogPostRepository.self)
//        guard let postID = Int(parameter) else {
//            throw SteamPressError(identifier: "Invalid-ID-Type", "Unable to convert \(parameter) to a Post ID")
//        }
//        return postRepository.getPost(id: postID, on: container).unwrap(or: Abort(.notFound))
//    }
}

extension BlogTag: ParameterModel {
//    typealias Repository = BlogTagRepository
    public static let parameterKey = "blogTagName"
    public static let parameter = PathComponent(stringLiteral: ":\(BlogPost.parameterKey)")
    
//    public typealias ResolvedParameter = EventLoopFuture<BlogTag>
//    public static func resolveParameter(_ parameter: String, on container: Container) throws -> EventLoopFuture<BlogTag> {
//        let tagRepository = try container.make(BlogTagRepository.self)
//        return tagRepository.getTag(parameter, on: container).unwrap(or: Abort(.notFound))
//    }
}

protocol ParameterModel {
    static var parameterKey: String { get }
    static var parameter: PathComponent { get }
//    associatedtype Repository: SteamPressRepository
}
//
//extension Parameters {
//    func find<T>(on req: Request, repository: SteamPressRepository) -> EventLoopFuture<T> where T: ParameterModel {
//        guard let idString = req.parameters.get(T.parameterKey), let id = Int(idString) else {
//            return req.eventLoop.makeFailedFuture(Abort(.badRequest))
//        }
//        return repository.get(id, on: req.eventLoop)
//    }
//}

extension Parameters {
    func find<T>(_ type: T.Type, on req: Request) -> EventLoopFuture<T> where T: ParameterModel {
        guard let idString = req.parameters.get(T.parameterKey), let id = Int(idString) else {
            return req.eventLoop.makeFailedFuture(Abort(.badRequest))
        }
        return req.blogUserRepository.getUser(id: id, on: req).unwrap(or: Abort(.notFound))
    }
}
