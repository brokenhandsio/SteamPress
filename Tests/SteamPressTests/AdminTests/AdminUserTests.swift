import XCTest
import Vapor
import SteamPress

class AdminUserTests: XCTestCase {
    
    // MARK: - allTests
    
    #warning("Rename to __allTests")
    static var allTests = [
        ("testLinuxTestSuiteIncludesAllTests", testLinuxTestSuiteIncludesAllTests),
        ("testUserCanBeCreatedSuccessfully", testUserCanBeCreatedSuccessfully),
        ("testUserMustResetPasswordIfSetToWhenCreatingUser", testUserMustResetPasswordIfSetToWhenCreatingUser),
        ("testUserCannotBeCreatedWithoutName", testUserCannotBeCreatedWithoutName),
        ("testUserCannotBeCreatedWithoutUsername", testUserCannotBeCreatedWithoutUsername),
        ("testUserCannotBeCreatedWithoutPassword", testUserCannotBeCreatedWithoutPassword),
        ("testUserCannotBeCreatedWithoutSpecifyingAConfirmPassword", testUserCannotBeCreatedWithoutSpecifyingAConfirmPassword),
        ("testUserCannotBeCreatedWithPasswordsThatDontMatch", testUserCannotBeCreatedWithPasswordsThatDontMatch),
        ("testUserCannotBeCreatedWithSimplePassword", testUserCannotBeCreatedWithSimplePassword),
        ("testUserCannotBeCreatedWithEmptyName", testUserCannotBeCreatedWithEmptyName),
        ("testUserCannotBeCreatedWithEmptyUsername", testUserCannotBeCreatedWithEmptyUsername),
        ("testUserCannotBeCreatedWithInvalidUsername", testUserCannotBeCreatedWithInvalidUsername),
        ("testUserCanBeUpdated", testUserCanBeUpdated),
        ("testCanDeleteUser", testCanDeleteUser),
        ("testCannotDeleteSelf", testCannotDeleteSelf),
        ("testCannotDeleteLastUser", testCannotDeleteLastUser),
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
            let password = "somepassword"
            let confirmPassword = "somepassword"
            let profilePicture = "https://static.brokenhands.io/images/cat.png"
            let tagline = "The awesome tagline"
            let biography = "The biograhy"
            let twitterHandle = "brokenhandsio"
        }

        let createData = CreateUserData()
        let response = try testWorld.getResponse(to: createUserPath, body: createData, loggedInUser: user)
        
        XCTAssertEqual(testWorld.context.repository.users.count, 2)
        let user = testWorld.context.repository.users.last
        XCTAssertNotNil(user)
        XCTAssertEqual(user?.username, createData.username)
        XCTAssertEqual(user?.name, createData.name)
        XCTAssertEqual(user?.profilePicture, createData.profilePicture)
        XCTAssertEqual(user?.tagline, createData.tagline)
        XCTAssertEqual(user?.biography, createData.biography)
        XCTAssertEqual(user?.twitterHandle, createData.twitterHandle)
        XCTAssertEqual(response.http.status, .seeOther)
        XCTAssertEqual(response.http.headers[.location].first, "/admin/")
    }
    
    func testUserMustResetPasswordIfSetToWhenCreatingUser() throws {
        struct CreateUserResetData: Content {
            static let defaultContentType = MediaType.urlEncodedForm
            let name = "Luke"
            let username = "lukes"
            let password = "somepassword"
            let confirmPassword = "somepassword"
            let profilePicture = "https://static.brokenhands.io/images/cat.png"
            let tagline = "The awesome tagline"
            let biography = "The biograhy"
            let twitterHandle = "brokenhandsio"
            let resetPasswordOnLogin = true
        }
        
        let data = CreateUserResetData()
        _ = try testWorld.getResponse(to: createUserPath, body: data, loggedInUser: user)
        
        XCTAssertTrue(testWorld.context.repository.users.filter { $0.username == data.username }.first?.resetPasswordRequired ?? false)
    }
    
    func testUserCannotBeCreatedWithoutName() throws {
        struct CreateUserData: Content {
            static let defaultContentType = MediaType.urlEncodedForm
            let username = "lukes"
            let password = "password"
            let confirmPassword = "password"
        }
        
        let createData = CreateUserData()
        _ = try testWorld.getResponse(to: createUserPath, body: createData, loggedInUser: user)

        XCTAssertTrue(presenter.createUserErrors?.contains("You must specify a name") ?? false)
    }

    func testUserCannotBeCreatedWithoutUsername() throws {
        struct CreateUserData: Content {
            static let defaultContentType = MediaType.urlEncodedForm
            let name = "Luke"
            let password = "password"
            let confirmPassword = "password"
        }
        
        let createData = CreateUserData()
        _ = try testWorld.getResponse(to: createUserPath, body: createData, loggedInUser: user)
        
        XCTAssertTrue(presenter.createUserErrors?.contains("You must specify a username") ?? false)
    }

    func testUserCannotBeCreatedWithoutPassword() throws {
        struct CreateUserData: Content {
            static let defaultContentType = MediaType.urlEncodedForm
            let name = "Luke"
            let username = "lukes"
            let confirmPassword = "password"
        }
        
        let createData = CreateUserData()
        _ = try testWorld.getResponse(to: createUserPath, body: createData, loggedInUser: user)
        
        XCTAssertTrue(presenter.createUserErrors?.contains("You must specify a password") ?? false)
    }

    func testUserCannotBeCreatedWithoutSpecifyingAConfirmPassword() throws {
        struct CreateUserData: Content {
            static let defaultContentType = MediaType.urlEncodedForm
            let name = "Luke"
            let username = "lukes"
            let password = "password"
        }
        
        let createData = CreateUserData()
        _ = try testWorld.getResponse(to: createUserPath, body: createData, loggedInUser: user)
        
        XCTAssertTrue(presenter.createUserErrors?.contains("You must confirm your password") ?? false)
    }

    func testUserCannotBeCreatedWithPasswordsThatDontMatch() throws {
        struct CreateUserData: Content {
            static let defaultContentType = MediaType.urlEncodedForm
            let name = "Luke"
            let username = "lukes"
            let password = "astrongpassword"
            let confirmPassword = "anotherPassword"
        }
        
        let createData = CreateUserData()
        _ = try testWorld.getResponse(to: createUserPath, body: createData, loggedInUser: user)
        
        XCTAssertTrue(presenter.createUserErrors?.contains("Your passwords must match") ?? false)
    }

    func testUserCannotBeCreatedWithSimplePassword() throws {
        struct CreateUserData: Content {
            static let defaultContentType = MediaType.urlEncodedForm
            let name = "Luke"
            let username = "lukes"
            let password = "password"
            let confirmPassword = "password"
        }
        
        let createData = CreateUserData()
        _ = try testWorld.getResponse(to: createUserPath, body: createData, loggedInUser: user)

        XCTAssertTrue(presenter.createUserErrors?.contains("Your password must be at least 10 characters long") ?? false)
    }

    func testUserCannotBeCreatedWithEmptyName() throws {
        struct CreateUserData: Content {
            static let defaultContentType = MediaType.urlEncodedForm
            let mame = ""
            let username = "lukes"
            let password = "password"
            let confirmPassword = "password"
        }
        
        let createData = CreateUserData()
        _ = try testWorld.getResponse(to: createUserPath, body: createData, loggedInUser: user)
        
        XCTAssertTrue(presenter.createUserErrors?.contains("You must specify a name") ?? false)
    }

    func testUserCannotBeCreatedWithEmptyUsername() throws {
        struct CreateUserData: Content {
            static let defaultContentType = MediaType.urlEncodedForm
            let name = "Luke"
            let username = ""
            let password = "password"
            let confirmPassword = "password"
        }
        
        let createData = CreateUserData()
        _ = try testWorld.getResponse(to: createUserPath, body: createData, loggedInUser: user)
        
        XCTAssertTrue(presenter.createUserErrors?.contains("You must specify a username") ?? false)
    }

    func testUserCannotBeCreatedWithInvalidUsername() throws {
        struct CreateUserData: Content {
            static let defaultContentType = MediaType.urlEncodedForm
            let name = "Luke"
            let username = "lukes!"
            let password = "password"
            let confirmPassword = "password"
        }
        
        let createData = CreateUserData()
        _ = try testWorld.getResponse(to: createUserPath, body: createData, loggedInUser: user)

        XCTAssertTrue(presenter.createUserErrors?.contains("The username provided is not valid") ?? false)
    }

    func testUserCanBeUpdated() throws {
        struct EditUserData: Content {
            static let defaultContentType = MediaType.urlEncodedForm
            let name = "Darth Vader"
            let username = "darth_vader"
        }
        
        let editData = EditUserData()
        let response = try testWorld.getResponse(to: "/admin/users/\(user.userID!)/edit", body: editData, loggedInUser: user)
        
        XCTAssertEqual(testWorld.context.repository.users.count, 1)
        let updatedUser = testWorld.context.repository.users.first
        XCTAssertNotNil(updatedUser)
        XCTAssertEqual(updatedUser?.username, editData.username)
        XCTAssertEqual(updatedUser?.name, editData.name)
        XCTAssertEqual(updatedUser?.userID, user.userID)
        XCTAssertEqual(response.http.status, .seeOther)
        XCTAssertEqual(response.http.headers[.location].first, "/admin/")
    }
    
    func testCanDeleteUser() throws {
        let user2 = testWorld.createUser(name: "Han", username: "han")
        
        let response = try testWorld.getResponse(to: "/admin/users/\(user2.userID!)/delete", body: EmptyContent(), loggedInUser: user)

        XCTAssertEqual(response.http.status, .seeOther)
        XCTAssertEqual(response.http.headers[.location].first, "/admin/")
        XCTAssertEqual(testWorld.context.repository.users.count, 1)
        XCTAssertNotEqual(testWorld.context.repository.users.first?.name, "Han")
    }

    func testCannotDeleteSelf() throws {
        let user2 = testWorld.createUser(name: "Han", username: "han")

        _ = try testWorld.getResponse(to: "/admin/users/\(user2.userID!)/delete", body: EmptyContent(), loggedInUser: user2)

        XCTAssertTrue(presenter.adminViewErrors?.contains("You cannot delete yourself whilst logged in") ?? false)
        XCTAssertEqual(testWorld.context.repository.users.count, 2)
    }

    func testCannotDeleteLastUser() throws {
        _ = try testWorld.getResponse(to: "/admin/users/\(user.userID!)/delete", body: EmptyContent(), loggedInUser: user)
        
        XCTAssertTrue(presenter.adminViewErrors?.contains("You cannot delete the last user") ?? false)
        XCTAssertEqual(testWorld.context.repository.users.count, 1)
    }
    
}
