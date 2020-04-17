import Vapor

extension Request {
    var blogPresenter: BlogPresenter {
        self.application.steampress.blogPresenters.blogPresenter.for(self)
    }
}

extension Application.SteamPress {
    struct BlogPresenters {
        struct Provider {
            static var view: Self {
                .init {
                    $0.steampress.blogPresenters.use { $0.steampress.blogPresenters.view }
                }
            }

            let run: (Application) -> ()

            public init(_ run: @escaping (Application) -> ()) {
                self.run = run
            }
        }
        
        final class Storage {
            var makePresenter: ((Application) -> BlogPresenter)?
            init() { }
        }

        struct Key: StorageKey {
            typealias Value = Storage
        }

        let application: Application

        var view: ViewBlogPresenter {
            return .init(viewRenderer: self.application.view, longDateFormatter: LongPostDateFormatter(), numericDateFormatter: NumericPostDateFormatter(), eventLoopGroup: self.application.eventLoopGroup)
        }

        var blogPresenter: BlogPresenter {
            guard let makePresenter = self.storage.makePresenter else {
                fatalError("No blog presenter configured. Configure with app.blogPresenters.use(...)")
            }
            return makePresenter(self.application)
        }

        func use(_ provider: Provider) {
            provider.run(self.application)
        }

        func use(_ makePresenter: @escaping (Application) -> (BlogPresenter)) {
            self.storage.makePresenter = makePresenter
        }

        func initialize() {
            self.application.storage[Key.self] = .init()
            self.use(.view)
        }

        private var storage: Storage {
            if self.application.storage[Key.self] == nil {
                self.initialize()
            }
            return self.application.storage[Key.self]!
        }
    }

    var blogPresenters: BlogPresenters {
        .init(application: self.application)
    }
}
