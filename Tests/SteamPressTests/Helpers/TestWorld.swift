import SteamPress
import Vapor

struct TestWorld {

    static func create(path: String? = nil, postsPerPage: Int = 10, feedInformation: FeedInformation = FeedInformation(), enableAuthorPages: Bool = true, enableTagPages: Bool = true, passwordHasherToUse: PasswordHasherChoice = .plaintext, randomNumberGenerator: StubbedRandomNumberGenerator = StubbedRandomNumberGenerator(numberToReturn: 666)) -> TestWorld {
        let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        let repository = InMemoryRepository(eventLoop: eventLoopGroup.next())
        let blogPresenter = CapturingBlogPresenter(eventLoop: eventLoopGroup.next())
        let blogAdminPresenter = CapturingAdminPresenter(eventLoop: eventLoopGroup.next())
        let application = TestWorld.getSteamPressApp(eventLoopGroup: eventLoopGroup, repository: repository, path: path, postsPerPage: postsPerPage, feedInformation: feedInformation, blogPresenter: blogPresenter, adminPresenter: blogAdminPresenter, enableAuthorPages: enableAuthorPages, enableTagPages: enableTagPages, passwordHasherToUse: passwordHasherToUse, randomNumberGenerator: randomNumberGenerator)
        let context = Context(app: application, repository: repository, blogPresenter: blogPresenter, blogAdminPresenter: blogAdminPresenter, path: path, eventLoopGroup: eventLoopGroup)
        unsetenv("BLOG_GOOGLE_ANALYTICS_IDENTIFIER")
        unsetenv("BLOG_SITE_TWITTER_HANDLE")
        unsetenv("BLOG_DISQUS_NAME")
        unsetenv("WEBSITE_URL")
        try! application.boot()
        return TestWorld(context: context)
    }

    let context: Context

    init(context: Context) {
        self.context = context
    }

    struct Context {
        let app: Application
        let repository: InMemoryRepository
        let blogPresenter: CapturingBlogPresenter
        let blogAdminPresenter: CapturingAdminPresenter
        let path: String?
        let eventLoopGroup: EventLoopGroup
    }
    
    func shutdown() throws {
        context.app.shutdown()
        try context.eventLoopGroup.syncShutdownGracefully()
    }
}
