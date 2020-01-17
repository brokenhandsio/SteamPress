import Vapor
import XCTest
import SteamPress

class AdminPageTests: XCTestCase {
    
    func testAdminPagePassesCorrectInformationToPresenter() throws {
        var testWorld  = try TestWorld.create()
        let user = testWorld.createUser(username: "leia")
        let testData1 = try testWorld.createPost(author: user)
        let testData2 = try testWorld.createPost(title: "A second post", author: user)
        
        _ = try testWorld.getResponse(to: "/admin/", loggedInUser: user)
        
        let presenter = testWorld.context.blogAdminPresenter
        XCTAssertNil(presenter.adminViewErrors)
        XCTAssertEqual(presenter.adminViewPosts?.count, 2)
        XCTAssertEqual(presenter.adminViewPosts?.first?.title, testData2.post.title)
        XCTAssertEqual(presenter.adminViewPosts?.last?.title, testData1.post.title)
        XCTAssertEqual(presenter.adminViewUsers?.count, 1)
        XCTAssertEqual(presenter.adminViewUsers?.last?.username, user.username)
        
        XCTAssertEqual(presenter.adminViewPageInformation?.loggedInUser.username, user.username)
        XCTAssertEqual(presenter.adminViewPageInformation?.websiteURL.absoluteString, "/")
        XCTAssertEqual(presenter.adminViewPageInformation?.currentPageURL.absoluteString, "/admin")
        
        XCTAssertNoThrow(try testWorld.tryAsHardAsWeCanToShutdownApplication())
    }
}
