import XCTest
@testable import SteamPress
import Vapor

class ProviderTests: XCTestCase {
    func testSteamPressSetsCorrectServices() throws {
        let app = Application()
        app.middleware.use(BlogRememberMeMiddleware())
        app.middleware.use(SessionsMiddleware(session: app.sessions.driver))

        app.steampress.blogRepositories.use { application in
            return InMemoryRepository(eventLoop: application.eventLoopGroup.next())
        }
        
        let numberGenerator = app.steampress.randomNumberGenerators.generator
        XCTAssertTrue(type(of: numberGenerator) == RealRandomNumberGenerator.self)
        
        let blogPresenter = app.steampress.blogPresenters.blogPresenter
        XCTAssertTrue(type(of: blogPresenter) == ViewBlogPresenter.self)
        
        let blogAdminPresenter = app.steampress.adminPresenters.adminPresenter
        XCTAssertTrue(type(of: blogAdminPresenter) == ViewBlogAdminPresenter.self)
        
        app.shutdown()
    }
}
