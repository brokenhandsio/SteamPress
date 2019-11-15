import SteamPress
import Vapor

struct TestWorld {
    
    static func create(path: String? = nil, feedInformation: FeedInformation = FeedInformation(), enableAuthorPages: Bool = true, enableTagPages: Bool = true, passwordHasherToUse: PasswordHasherChoice = .plaintext) throws -> TestWorld {
        let repository = InMemoryRepository()
        let blogPresenter = CapturingBlogPresenter()
        let blogAdminPresenter = CapturingAdminPresenter()
        let application = try TestWorld.getSteamPressApp(repository: repository, path: path, feedInformation: feedInformation, blogPresenter: blogPresenter, adminPresenter: blogAdminPresenter, enableAuthorPages: enableAuthorPages, enableTagPages: enableTagPages, passwordHasherToUse: passwordHasherToUse)
        let context = Context(app: application, repository: repository, blogPresenter: blogPresenter, blogAdminPresenter: blogAdminPresenter, path: path)
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
    }
}
