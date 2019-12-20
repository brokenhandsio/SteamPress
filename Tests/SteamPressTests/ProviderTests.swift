import XCTest
import SteamPress
import Vapor

class ProviderTests: XCTestCase {
    func testUsingProviderSetsCorrectServices() throws {
        var services = Services.default()
        let steampress = SteamPress.Provider()
        try services.register(steampress)
        
        var middlewareConfig = MiddlewareConfig()
        middlewareConfig.use(ErrorMiddleware.self)
        middlewareConfig.use(BlogRememberMeMiddleware.self)
        middlewareConfig.use(SessionsMiddleware.self)
        services.register(middlewareConfig)

        services.register([BlogTagRepository.self, BlogPostRepository.self, BlogUserRepository.self]) { _ in
            return InMemoryRepository()
        }
        
        let app = try Application(services: services)
        
        let numberGenerator = try app.make(SteamPressRandomNumberGenerator.self)
        XCTAssertTrue(type(of: numberGenerator) == RealRandomNumberGenerator.self)
        
        let blogPresenter = try app.make(BlogPresenter.self)
        XCTAssertTrue(type(of: blogPresenter) == ViewBlogPresenter.self)
        
        let blogAdminPresenter = try app.make(BlogAdminPresenter.self)
        XCTAssertTrue(type(of: blogAdminPresenter) == ViewBlogAdminPresenter.self)
    }
}
