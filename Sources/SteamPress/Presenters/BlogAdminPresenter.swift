import Vapor

protocol BlogAdminPresenter {
    func `for`(_ request: Request, pathCreator: BlogPathCreator) -> BlogAdminPresenter
    func createIndexView(posts: [BlogPost], users: [BlogUser], errors: [String]?, pageInformation: BlogAdminPageInformation) -> EventLoopFuture<View>
    func createPostView(errors: [String]?, title: String?, contents: String?, slugURL: String?, tags: [String]?, isEditing: Bool, post: BlogPost?, isDraft: Bool?, titleError: Bool, contentsError: Bool, pageInformation: BlogAdminPageInformation) -> EventLoopFuture<View>
    func createUserView(editing: Bool, errors: [String]?, name: String?, nameError: Bool, username: String?, usernameErorr: Bool, passwordError: Bool, confirmPasswordError: Bool, resetPasswordOnLogin: Bool, userID: Int?, profilePicture: String?, twitterHandle: String?, biography: String?, tagline: String?, pageInformation: BlogAdminPageInformation) -> EventLoopFuture<View>
    func createResetPasswordView(errors: [String]?, passwordError: Bool?, confirmPasswordError: Bool?, pageInformation: BlogAdminPageInformation) -> EventLoopFuture<View>
}

extension ViewBlogAdminPresenter {
    func `for`(_ request: Request, pathCreator: BlogPathCreator) -> BlogAdminPresenter {
        return ViewBlogAdminPresenter(pathCreator: pathCreator, viewRenderer: request.view, eventLoopGroup: request.eventLoop, longDateFormatter: LongPostDateFormatter(), numericDateFormatter: NumericPostDateFormatter())
    }
}

extension Request {
    var adminPresenter: BlogAdminPresenter {
        self.application.adminPresenters.adminPresenter.for(self, pathCreator: self.application.adminPresenters.storage.pathCreator)
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
            let pathCreator: BlogPathCreator
            var makePresenter: ((Application) -> BlogAdminPresenter)?
            init(pathCreator: BlogPathCreator) {
                self.pathCreator = pathCreator
            }
        }

        struct Key: StorageKey {
            typealias Value = Storage
        }

        let application: Application

        var view: ViewBlogAdminPresenter {
            return .init(pathCreator: self.storage.pathCreator, viewRenderer: self.application.views.renderer, eventLoopGroup: self.application.eventLoopGroup, longDateFormatter: LongPostDateFormatter(), numericDateFormatter: NumericPostDateFormatter())
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

        func initialize(pathCreator: BlogPathCreator) {
            self.application.storage[Key.self] = .init(pathCreator: pathCreator)
            self.use(.view)
        }

        var storage: Storage {
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
