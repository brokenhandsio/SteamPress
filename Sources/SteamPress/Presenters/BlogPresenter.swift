import Vapor

protocol BlogPresenter {
    func `for`(_ request: Request) -> BlogPresenter
    func indexView(posts: [BlogPost], tags: [BlogTag], authors: [BlogUser], tagsForPosts: [Int: [BlogTag]], pageInformation: BlogGlobalPageInformation, paginationTagInfo: PaginationTagInformation) -> EventLoopFuture<View>
    func postView(post: BlogPost, author: BlogUser, tags: [BlogTag], pageInformation: BlogGlobalPageInformation) -> EventLoopFuture<View>
    func allAuthorsView(authors: [BlogUser], authorPostCounts: [Int: Int], pageInformation: BlogGlobalPageInformation) -> EventLoopFuture<View>
    func authorView(author: BlogUser, posts: [BlogPost], postCount: Int, tagsForPosts: [Int: [BlogTag]], pageInformation: BlogGlobalPageInformation, paginationTagInfo: PaginationTagInformation) -> EventLoopFuture<View>
    func allTagsView(tags: [BlogTag], tagPostCounts: [Int: Int], pageInformation: BlogGlobalPageInformation) -> EventLoopFuture<View>
    func tagView(tag: BlogTag, posts: [BlogPost], authors: [BlogUser], totalPosts: Int, pageInformation: BlogGlobalPageInformation, paginationTagInfo: PaginationTagInformation) -> EventLoopFuture<View>
    func searchView(totalResults: Int, posts: [BlogPost], authors: [BlogUser], searchTerm: String?, tagsForPosts: [Int: [BlogTag]], pageInformation: BlogGlobalPageInformation, paginationTagInfo: PaginationTagInformation) -> EventLoopFuture<View>
    func loginView(loginWarning: Bool, errors: [String]?, username: String?, usernameError: Bool, passwordError: Bool, rememberMe: Bool, pageInformation: BlogGlobalPageInformation) -> EventLoopFuture<View>
}

extension ViewBlogPresenter {
    func `for`(_ request: Request) -> BlogPresenter {
        return ViewBlogPresenter(viewRenderer: request.view, longDateFormatter: LongPostDateFormatter(), numericDateFormatter: NumericPostDateFormatter(), eventLoopGroup: request.eventLoop)
    }
}

extension Request {
    var blogPresenter: BlogPresenter {
        self.application.blogPresenters.blogPresenter.for(self)
    }
}

extension Application {
    struct BlogPresenters {
        struct Provider {
            static var view: Self {
                .init {
                    $0.blogPresenters.use { $0.blogPresenters.view }
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
            return .init(viewRenderer: self.application.views.renderer, longDateFormatter: LongPostDateFormatter(), numericDateFormatter: NumericPostDateFormatter(), eventLoopGroup: self.application.eventLoopGroup)
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
        .init(application: self)
    }
}
