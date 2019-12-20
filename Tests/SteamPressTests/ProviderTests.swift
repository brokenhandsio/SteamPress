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
        
        let app: Application? = try Application(services: services)
        
        let numberGenerator = try app!.make(SteamPressRandomNumberGenerator.self)
        XCTAssertTrue(type(of: numberGenerator) == RealRandomNumberGenerator.self)
        
        let blogPresenter = try app!.make(BlogPresenter.self)
        XCTAssertTrue(type(of: blogPresenter) == ViewBlogPresenter.self)
        
        let blogAdminPresenter = try app!.make(BlogAdminPresenter.self)
        XCTAssertTrue(type(of: blogAdminPresenter) == ViewBlogAdminPresenter.self)
        
        // Work around Vapor 3 lifecycle mess
        weak var weakApp: Application? = app
        weakApp = nil
        var tries = 0
        while weakApp != nil && tries < 10 {
            Thread.sleep(forTimeInterval: 0.1)
            tries += 1
        }
        XCTAssertNil(weakApp, "application leak: \(weakApp.debugDescription)")
    }
}
