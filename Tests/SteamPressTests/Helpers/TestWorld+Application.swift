import SteamPress
import Vapor

extension TestWorld {
    static func getSteamPressApp(repository: InMemoryRepository,
                                 path: String?,
                                 postsPerPage: Int,
                                 feedInformation: FeedInformation,
                                 blogPresenter: CapturingBlogPresenter,
                                 adminPresenter: CapturingAdminPresenter,
                                 enableAuthorPages: Bool,
                                 enableTagPages: Bool,
                                 passwordHasherToUse: PasswordHasherChoice,
                                 randomNumberGenerator: StubbedRandomNumberGenerator) throws -> Application {
        var services = Services.default()
        let steampress = SteamPress.Provider(
                                             blogPath: path,
                                             feedInformation: feedInformation,
                                             postsPerPage: postsPerPage,
                                             enableAuthorPages: enableAuthorPages,
                                             enableTagPages: enableTagPages)
        try services.register(steampress)

        services.register([BlogTagRepository.self, BlogPostRepository.self, BlogUserRepository.self]) { _ in
            return repository
        }

        services.register(SteamPressRandomNumberGenerator.self) { _ in
            return randomNumberGenerator
        }
        
        services.register(BlogPresenter.self) { _ in
            return blogPresenter
        }
        
        services.register(BlogAdminPresenter.self) { _ in
            return adminPresenter
        }

        var middlewareConfig = MiddlewareConfig()
        middlewareConfig.use(ErrorMiddleware.self)
        middlewareConfig.use(BlogRememberMeMiddleware.self)
        middlewareConfig.use(SessionsMiddleware.self)
        services.register(middlewareConfig)

        var config = Config.default()

        config.prefer(CapturingBlogPresenter.self, for: BlogPresenter.self)
        config.prefer(CapturingAdminPresenter.self, for: BlogAdminPresenter.self)
        config.prefer(StubbedRandomNumberGenerator.self, for: SteamPressRandomNumberGenerator.self)

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
