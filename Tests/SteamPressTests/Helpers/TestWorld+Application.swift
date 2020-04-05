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
        
        application.blogRepositories.use { _ in
            return repository
        }

        application.randomNumberGenerators.use { _ in randomNumberGenerator }

        application.middleware.use(BlogRememberMeMiddleware())
        application.middleware.use(SessionsMiddleware(session: application.sessions.driver))

        application.blogPresenters.use(.capturing)
        application.adminPresenters.use(.capturing)

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

        return Application(.testing, .shared(eventLoopGroup))
    }
}
