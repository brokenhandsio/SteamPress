import SteamPress
import Vapor

extension TestWorld {
    static func getSteamPressApp(eventLoopGroup: EventLoopGroup,
                                 repository: InMemoryRepository,
                                 path: String?,
                                 postsPerPage: Int,
                                 feedInformation: FeedInformation,
                                 blogPresenter: CapturingBlogPresenter,
                                 adminPresenter: CapturingAdminPresenter,
                                 enableAuthorPages: Bool,
                                 enableTagPages: Bool,
                                 passwordHasherToUse: PasswordHasherChoice,
                                 randomNumberGenerator: StubbedRandomNumberGenerator) throws -> Application {
        
        let application = Application(.testing, .shared(eventLoopGroup))
        
        let steampress = SteamPress.SteampressLifecyle(
                                             blogPath: path,
                                             feedInformation: feedInformation,
                                             postsPerPage: postsPerPage,
                                             enableAuthorPages: enableAuthorPages,
                                             enableTagPages: enableTagPages)
        application.lifecycle.use(steampress)

        
        services.register([BlogTagRepository.self, BlogPostRepository.self, BlogUserRepository.self]) { _ in
            return repository
        }

        application.randomNumberGenerators.use { _ in randomNumberGenerator }
        
        services.register(BlogPresenter.self) { _ in
            return blogPresenter
        }
        
        services.register(BlogAdminPresenter.self) { _ in
            return adminPresenter
        }

        application.middleware.use(BlogRememberMeMiddleware())
        application.middleware.use(SessionsMiddleware(session: application.sessions.driver))

        config.prefer(CapturingBlogPresenter.self, for: BlogPresenter.self)
        config.prefer(CapturingAdminPresenter.self, for: BlogAdminPresenter.self)

        switch passwordHasherToUse {
        case .real:
            application.passwordHashers.use(.bcrypt)
            application.passwordVerifiers.use(.bcrypt)
        case .plaintext:
            application.passwordHashers.use(.plaintext)
            application.passwordVerifiers.use(.plaintext)
        case .reversed:
            application.passwordVerifiers.use(.reversed)
            application.passwordHashers.use(.reversed)
        }

        return try Application(config: config, services: services)
    }
}
