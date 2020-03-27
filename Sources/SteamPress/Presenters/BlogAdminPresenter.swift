import Vapor

public protocol BlogAdminPresenter {
    func `for`(_ request: Request) -> BlogAdminPresenter
    func createIndexView(posts: [BlogPost], users: [BlogUser], errors: [String]?, pageInformation: BlogAdminPageInformation) -> EventLoopFuture<View>
    func createPostView(errors: [String]?, title: String?, contents: String?, slugURL: String?, tags: [String]?, isEditing: Bool, post: BlogPost?, isDraft: Bool?, titleError: Bool, contentsError: Bool, pageInformation: BlogAdminPageInformation) -> EventLoopFuture<View>
    func createUserView(editing: Bool, errors: [String]?, name: String?, nameError: Bool, username: String?, usernameErorr: Bool, passwordError: Bool, confirmPasswordError: Bool, resetPasswordOnLogin: Bool, userID: Int?, profilePicture: String?, twitterHandle: String?, biography: String?, tagline: String?, pageInformation: BlogAdminPageInformation) -> EventLoopFuture<View>
    func createResetPasswordView(errors: [String]?, passwordError: Bool?, confirmPasswordError: Bool?, pageInformation: BlogAdminPageInformation) -> EventLoopFuture<View>
}

extension ViewBlogAdminPresenter {
    public func `for`(_ request: Request) -> BlogAdminPresenter {
        #warning("TODO path create")
        return ViewBlogAdminPresenter(pathCreator: BlogPathCreator(blogPath: nil), viewRenderer: request.view, eventLoopGroup: request.eventLoop, longDateFormatter: LongPostDateFormatter(), numericDateFormatter: NumericPostDateFormatter())
    }
}

extension Request {
    var adminPresenter: BlogAdminPresenter {
        self.application.adminPresenters.adminPresenter.for(self)
    }
}

extension Application {
    struct BlogAdminPresenters {
        struct Provider {
            static var view: Self {
                .init {
                    $0.adminPresenters.use { $0.adminPresenters.view }
                }
            }

            let run: (Application) -> ()

            init(_ run: @escaping (Application) -> ()) {
                self.run = run
            }
        }
        
        final class Storage {
            var makePresenter: ((Application) -> BlogAdminPresenter)?
            init() { }
        }

        struct Key: StorageKey {
            typealias Value = Storage
        }

        let application: Application

        var view: ViewBlogAdminPresenter {
            #warning("Sort out Blog Path Creator")
            return .init(pathCreator: BlogPathCreator(blogPath: nil), viewRenderer: self.application.views.renderer, eventLoopGroup: self.application.eventLoopGroup, longDateFormatter: LongPostDateFormatter(), numericDateFormatter: NumericPostDateFormatter())
        }

        var adminPresenter: BlogAdminPresenter {
            guard let makePresenter = self.storage.makePresenter else {
                fatalError("No blog admin presenter configured. Configure with app.adminPresenters.use(...)")
            }
            return makePresenter(self.application)
        }

        func use(_ provider: Provider) {
            provider.run(self.application)
        }

        func use(_ makePresenter: @escaping (Application) -> (BlogAdminPresenter)) {
            self.storage.makePresenter = makePresenter
        }

        func initialize() {
            self.application.storage[Key.self] = .init()
            self.use(.view)
        }

        private var storage: Storage {
            guard let storage = self.application.storage[Key.self] else {
                fatalError("BlogAdminPresenters not configured. Configure with app.adminPresenters.initialize()")
            }
            return storage
        }
    }

    var adminPresenters: BlogAdminPresenters {
        .init(application: self)
    }
}
