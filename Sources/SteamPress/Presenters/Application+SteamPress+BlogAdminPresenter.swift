import Vapor

extension Request {
    var adminPresenter: BlogAdminPresenter {
        self.application.steampress.adminPresenters.adminPresenter.for(self, pathCreator: self.application.steampress.adminPresenters.storage.pathCreator)
    }
}

extension Application.SteamPress {
    struct BlogAdminPresenters {
        struct Provider {
            static var view: Self {
                .init {
                    $0.steampress.adminPresenters.use { $0.steampress.adminPresenters.view }
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
            return .init(pathCreator: self.storage.pathCreator, viewRenderer: self.application.view, eventLoopGroup: self.application.eventLoopGroup, longDateFormatter: LongPostDateFormatter(), numericDateFormatter: NumericPostDateFormatter())
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
            if self.application.storage[Key.self] == nil {
                let pathCreator = BlogPathCreator(blogPath: self.application.steampress.configuration.blogPath)
                initialize(pathCreator: pathCreator)
            }
            return self.application.storage[Key.self]!
        }
    }

    var adminPresenters: BlogAdminPresenters {
        .init(application: self.application)
    }
}
