import XCTest
@testable import SteamPress
import Vapor

class ProviderTests: XCTestCase {
    func testSteamPressSetsCorrectServices() throws {
        let app = Application()
        app.middleware.use(BlogRememberMeMiddleware())
        app.middleware.use(SessionsMiddleware(session: app.sessions.driver))

        app.blogRepositories.use { application in
            return InMemoryRepository(eventLoop: application.eventLoopGroup.next())
        }
        
        let numberGenerator = app.randomNumberGenerators.generator
        XCTAssertTrue(type(of: numberGenerator) == RealRandomNumberGenerator.self)
        
        let blogPresenter = app.blogPresenters.blogPresenter
        XCTAssertTrue(type(of: blogPresenter) == ViewBlogPresenter.self)
        
        let blogAdminPresenter = app.adminPresenters.adminPresenter
        XCTAssertTrue(type(of: blogAdminPresenter) == ViewBlogAdminPresenter.self)
        
        app.shutdown()
    }
}
