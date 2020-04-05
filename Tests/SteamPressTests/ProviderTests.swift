import XCTest
@testable import SteamPress
import Vapor

class ProviderTests: XCTestCase {
    func testUsingProviderSetsCorrectServices() throws {
        let app = Application()
        app.lifecycle.use(SteamPress.SteampressLifecyle())
        app.middleware.use(BlogRememberMeMiddleware())
        app.middleware.use(SessionsMiddleware(session: app.sessions.driver))

        #warning("TODO")
//        services.register([BlogTagRepository.self, BlogPostRepository.self, BlogUserRepository.self]) { _ in
//            return InMemoryRepository()
//        }
        
        let numberGenerator = app.randomNumberGenerators.generator
        XCTAssertTrue(type(of: numberGenerator) == RealRandomNumberGenerator.self)
        
        let blogPresenter = app.blogPresenters.blogPresenter
        XCTAssertTrue(type(of: blogPresenter) == ViewBlogPresenter.self)
        
        let blogAdminPresenter = app.adminPresenters.adminPresenter
        XCTAssertTrue(type(of: blogAdminPresenter) == ViewBlogAdminPresenter.self)
        
        app.shutdown()
    }
}
