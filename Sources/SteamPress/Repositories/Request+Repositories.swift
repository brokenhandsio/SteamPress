import Vapor

public extension Request {
    var blogUserRepository: BlogUserRepository {
        self.application.steampress.blogRepositories.userRepository.for(self)
    }
    
    var blogPostRepository: BlogPostRepository {
        self.application.steampress.blogRepositories.postRepository.for(self)
    }
    
    var blogTagRepository: BlogTagRepository {
        self.application.steampress.blogRepositories.tagRepository.for(self)
    }
}
