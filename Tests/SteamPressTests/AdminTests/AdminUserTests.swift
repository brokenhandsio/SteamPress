import XCTest
import Vapor
import SteamPress

class AdminUserTests: XCTestCase {
    
    // MARK: - allTests
    
    static var allTests = [
        ("testLinuxTestSuiteIncludesAllTests", testLinuxTestSuiteIncludesAllTests),
        ("testUserCanBeCreatedSuccessfully", testUserCanBeCreatedSuccessfully),
        ("testUserCannotBeCreatedWithoutName", testUserCannotBeCreatedWithoutName),
        ("testUserCannotBeCreatedWithoutUsername", testUserCannotBeCreatedWithoutUsername),
        ("testUserCannotBeCreatedWithoutPassword", testUserCannotBeCreatedWithoutPassword),
        ("testUserCannotBeCreatedWithoutSpecifyingAConfirmPassword", testUserCannotBeCreatedWithoutSpecifyingAConfirmPassword),
        ("testUserCannotBeCreatedWithPasswordsThatDontMatch", testUserCannotBeCreatedWithPasswordsThatDontMatch),
        ("testUserCannotBeCreatedWithSimplePassword", testUserCannotBeCreatedWithSimplePassword),
        ("testUserCannotBeCreatedWithEmptyName", testUserCannotBeCreatedWithEmptyName),
        ("testUserCannotBeCreatedWithEmptyUsername", testUserCannotBeCreatedWithEmptyUsername),
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
        _ = try testWorld.getResponse(to: createUserPath, body: createData, loggedInUser: user)
        
        XCTAssertEqual(testWorld.context.repository.users.count, 2)
        let user = testWorld.context.repository.users.last
        XCTAssertNotNil(user)
        XCTAssertEqual(user?.username, createData.username)
        XCTAssertEqual(user?.name, createData.name)
        XCTAssertEqual(user?.profilePicture, createData.profilePicture)
        XCTAssertEqual(user?.tagline, createData.tagline)
        XCTAssertEqual(user?.biography, createData.biography)
        XCTAssertEqual(user?.twitterHandle, createData.twitterHandle)
    }
    
//    func testUserMustResetPasswordIfSetToWhenCreatingUser() throws {
        //        BlogUser.passwordHasher = FakePasswordHasher()
        //        let request = try createLoggedInRequest(method: .post, path: "createUser")
        //        let newName = "Leia"
        //        let password = "AS3cretPassword"
        //        var userData = Node([:], in: nil)
        //        try userData.set("inputName", newName)
        //        try userData.set("inputUsername", "leia")
        //        try userData.set("inputPassword", password)
        //        try userData.set("inputConfirmPassword", password)
        //        try userData.set("inputResetPasswordOnLogin", "true")
        //        request.formURLEncoded = userData
        //
        //        let _ = try drop.respond(to: request)
        //
        //        XCTAssertTrue(try BlogUser.makeQuery().filter("name", newName).all().first?.resetPasswordRequired ?? false)
        //    }
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
            let password = "password"
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

        //    func testUserCannotBeCreatedWithInvalidName() throws {
        //        let request = try createLoggedInRequest(method: .post, path: "createUser")
        //        let password = "AComl3xPass!"
        //        var userData = Node([:], in: nil)
        //        try userData.set("inputName", "An invalid Name!3")
        //        try userData.set("inputUsername", "leia")
        //        try userData.set("inputPassword", password)
        //        try userData.set("inputConfirmPassword", password)
        //        try userData.set("inputResetPasswordOnLogin", "true")
        //        request.formURLEncoded = userData
        //
        //        let _ = try drop.respond(to: request)
        //
        //        XCTAssertTrue(capturingViewFactory.createUserErrors?.contains("The name provided is not valid") ?? false)
        //    }
        //
        //    func testUserCannotBeCreatedWithInvalidUsername() throws {
        //        let request = try createLoggedInRequest(method: .post, path: "createUser")
        //        let password = "AComl3xPass!"
        //        var userData = Node([:], in: nil)
        //        try userData.set("inputName", "Leia")
        //        try userData.set("inputUsername", "LEIA!")
        //        try userData.set("inputPassword", password)
        //        try userData.set("inputConfirmPassword", password)
        //        try userData.set("inputResetPasswordOnLogin", "true")
        //        request.formURLEncoded = userData
        //
        //        let _ = try drop.respond(to: request)
        //
        //        XCTAssertTrue(capturingViewFactory.createUserErrors?.contains("The username provided is not valid") ?? false)
        //    }
        //
        //    // MARK: - Edit User Tests
        //
        //    func testUserCanBeUpdated() throws {
        //        let author = TestDataBuilder.anyUser(name: "Luke", username: "luke")
        //        try author.save()
        //
        //        let request = try createLoggedInRequest(method: .post, path: "users/\(author.id!.string!)/edit", for: author)
        //        let newName = "Darth Vader"
        //        let newUsername = "darth_vader"
        //        var userData = Node([:], in: nil)
        //        try userData.set("inputName", newName)
        //        try userData.set("inputUsername", newUsername)
        //        request.formURLEncoded = userData
        //
        //        let _  = try drop.respond(to: request)
        //
        //        XCTAssertEqual(try BlogUser.count(), 2)
        //        XCTAssertEqual(try BlogUser.all()[1].id, author.id)
        //        XCTAssertEqual(try BlogUser.all()[1].name, newName)
        //        XCTAssertEqual(try BlogUser.all()[1].username, newUsername)
        //    }
    
}
