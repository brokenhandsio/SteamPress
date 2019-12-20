import SteamPress
import Vapor

struct TestWorld {

    static func create(path: String? = nil, postsPerPage: Int = 10, feedInformation: FeedInformation = FeedInformation(), enableAuthorPages: Bool = true, enableTagPages: Bool = true, passwordHasherToUse: PasswordHasherChoice = .plaintext, randomNumberGenerator: StubbedRandomNumberGenerator = StubbedRandomNumberGenerator(numberToReturn: 666)) throws -> TestWorld {
        let repository = InMemoryRepository()
        let blogPresenter = CapturingBlogPresenter()
        let blogAdminPresenter = CapturingAdminPresenter()
        let application = try TestWorld.getSteamPressApp(repository: repository, path: path, postsPerPage: postsPerPage, feedInformation: feedInformation, blogPresenter: blogPresenter, adminPresenter: blogAdminPresenter, enableAuthorPages: enableAuthorPages, enableTagPages: enableTagPages, passwordHasherToUse: passwordHasherToUse, randomNumberGenerator: randomNumberGenerator)
        let context = Context(app: application, repository: repository, blogPresenter: blogPresenter, blogAdminPresenter: blogAdminPresenter, path: path)
        unsetenv("BLOG_GOOGLE_ANALYTICS_IDENTIFIER")
        unsetenv("BLOG_SITE_TWITTER_HANDLER")
        unsetenv("BLOG_DISQUS_NAME")
        return TestWorld(context: context)
    }

    var context: Context

    init(context: Context) {
        self.context = context
    }

    struct Context {
        var app: Application?
        let repository: InMemoryRepository
        let blogPresenter: CapturingBlogPresenter
        let blogAdminPresenter: CapturingAdminPresenter
        let path: String?
    }
    
    // To work around Vapor 3 dodgy lifecycle mess
    mutating func tryAsHardAsWeCanToShutdownApplication() throws {
        struct ApplicationDidNotGoAway: Error {
            var description: String
        }
        weak var weakApp: Application? = context.app
        context.app = nil
        var tries = 0
        while weakApp != nil && tries < 10 {
            Thread.sleep(forTimeInterval: 0.1)
            tries += 1
        }
        if weakApp != nil {
            throw ApplicationDidNotGoAway(description: "application leak: \(weakApp.debugDescription)")
        }
    }
}
