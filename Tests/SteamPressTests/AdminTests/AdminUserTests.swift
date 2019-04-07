import XCTest
import Vapor
import SteamPress

class AdminUserTests: XCTestCase {
    
    // MARK: - allTests
    
    static var allTests = [
        ("testLinuxTestSuiteIncludesAllTests", testLinuxTestSuiteIncludesAllTests),
        ("testUserCanBeCreatedSuccessfully", testUserCanBeCreatedSuccessfully)
    ]
    
    // MARK: - Properties
    private var app: Application!
    private var testWorld: TestWorld!
    private let createUserPath = "/admin/createUser/"
    private var user: BlogUser!
    private var presenter: CapturingAdminPresenter {
        return testWorld.context.blogAdminPresenter
    }
    
    // MARK: - Overrides
    
    override func setUp() {
        testWorld = try! TestWorld.create()
        user = testWorld.createUser(name: "Leia", username: "leia")
    }
    
    // MARK: - Tests
    
    func testLinuxTestSuiteIncludesAllTests() {
        #if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
        let thisClass = type(of: self)
        let linuxCount = thisClass.allTests.count
        let darwinCount = Int(thisClass
            .defaultTestSuite.testCaseCount)
        XCTAssertEqual(linuxCount, darwinCount,
                       "\(darwinCount - linuxCount) tests are missing from allTests")
        #endif
    }
    
    func testUserCanBeCreatedSuccessfully() throws {
        struct CreateUserData: Content {
            static let defaultContentType = MediaType.urlEncodedForm
            let name = "Luke"
            let username = "lukes"
            let password = "password"
            let confirmPassword = "password"
        }
        
//        let profilePicture = "https://static.brokenhands.io/images/cat.png"
//        let tagline = "The awesome tagline"
//        let biography = "The biograhy"
//        let twitterHandle = "brokenhandsio"

        let createData = CreateUserData()
        _ = try testWorld.getResponse(to: createUserPath, body: createData, loggedInUser: user)
        
        XCTAssertEqual(testWorld.context.repository.users.count, 2)
        let user = testWorld.context.repository.users.last
        XCTAssertNotNil(user)
        XCTAssertEqual(user?.username, createData.username)
        XCTAssertEqual(user?.name, createData.name)
//        XCTAssertEqual(user?.profilePicture, profilePicture)
//        XCTAssertEqual(user?.tagline, tagline)
//        XCTAssertEqual(user?.biography, biography)
//        XCTAssertEqual(user?.twitterHandle, twitterHandle)
    }
    
}
