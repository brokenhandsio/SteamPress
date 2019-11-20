import SteamPress
import Vapor
import Authentication

extension TestWorld {
    static func getSteamPressApp(repository: InMemoryRepository,
                                 path: String?,
                                 postsPerPage: Int,
                                 feedInformation: FeedInformation,
                                 blogPresenter: CapturingBlogPresenter,
                                 adminPresenter: CapturingAdminPresenter,
                                 enableAuthorPages: Bool,
                                 enableTagPages: Bool,
                                 passwordHasherToUse: PasswordHasherChoice) throws -> Application {
        var services = Services.default()
        let steampress = SteamPress.Provider(
                                             blogPath: path,
                                             feedInformation: feedInformation,
                                             postsPerPage: postsPerPage,
                                             enableAuthorPages: enableAuthorPages,
                                             enableTagPages: enableTagPages,
                                             blogPresenter: blogPresenter,
                                             blogAdminPresenter: adminPresenter)
        try services.register(steampress)

        services.register([BlogTagRepository.self, BlogPostRepository.self, BlogUserRepository.self]) { _ in
            return repository
        }
        
        var middlewareConfig = MiddlewareConfig()
        middlewareConfig.use(ErrorMiddleware.self)
        middlewareConfig.use(BlogRememberMeMiddleware.self)
        middlewareConfig.use(SessionsMiddleware.self)
        services.register(middlewareConfig)
        
        var config = Config.default()
        
        switch passwordHasherToUse {
        case .real:
            config.prefer(BCryptDigest.self, for: PasswordVerifier.self)
            config.prefer(BCryptDigest.self, for: PasswordHasher.self)
        case .plaintext:
            services.register(PasswordHasher.self) { _ in
                return PlaintextHasher()
            }
            config.prefer(PlaintextVerifier.self, for: PasswordVerifier.self)
            config.prefer(PlaintextHasher.self, for: PasswordHasher.self)
        case .reversed:
            services.register([PasswordHasher.self, PasswordVerifier.self]) { _ in
                return ReversedPasswordHasher()
            }
            config.prefer(ReversedPasswordHasher.self, for: PasswordVerifier.self)
            config.prefer(ReversedPasswordHasher.self, for: PasswordHasher.self)
        }
        
        return try Application(config: config, services: services)
    }
}
