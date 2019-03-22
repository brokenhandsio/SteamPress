import SteamPress
import Vapor

struct TestWorld {
    
    static func create(path: String? = nil, feedInformation: FeedInformation = FeedInformation(), enableAuthorPages: Bool = true) throws -> TestWorld {
        let repository = InMemoryRepository()
        let blogPresenter = CapturingBlogPresenter()
        let application = try TestDataBuilder.getSteamPressApp(repository: repository, path: path, feedInformation: feedInformation, blogPresenter: blogPresenter, enableAuthorPages: enableAuthorPages)
        let context = Context(app: application, repository: repository, blogPresenter: blogPresenter)
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
    }
}
