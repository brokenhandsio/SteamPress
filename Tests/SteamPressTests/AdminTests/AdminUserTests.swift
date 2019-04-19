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

//    // MARK: - Reset Password tests
//
//    func testUserCannotResetPasswordWithMismatchingPasswords() throws {
//        let user = TestDataBuilder.anyUser()
//        try user.save()
//
//        let request = try createLoggedInRequest(method: .post, path: "resetPassword", for: user)
//        let resetPasswordData = try Node(node: [
//            "inputPassword": "Th3S@m3password",
//            "inputConfirmPassword": "An0th3rPass!"
//            ])
//        request.formURLEncoded = resetPasswordData
//
//        _ = try drop.respond(to: request)
//
//        XCTAssertTrue(capturingViewFactory.resetPasswordErrors?.contains("Your passwords must match!") ?? false)
//    }
//
//    func testUserCanResetPassword() throws {
//        BlogUser.passwordHasher = FakePasswordHasher()
//        let user = TestDataBuilder.anyUser()
//        try user.save()
//        let newPassword = "Th3S@m3password"
//
//        let request = try createLoggedInRequest(method: .post, path: "resetPassword", for: user)
//        let resetPasswordData = try Node(node: [
//            "inputPassword": newPassword,
//            "inputConfirmPassword": newPassword
//            ])
//        request.formURLEncoded = resetPasswordData
//
//        let response = try drop.respond(to: request)
//
//        XCTAssertEqual(user.password, newPassword.makeBytes())
//        XCTAssertEqual(response.status, .seeOther)
//        XCTAssertEqual(response.headers[HeaderKey.location], "/blog/admin/")
//    }
//
//    func testUserCannotResetPasswordWithoutPassword() throws {
//        let user = TestDataBuilder.anyUser()
//        try user.save()
//
//        let request = try createLoggedInRequest(method: .post, path: "resetPassword", for: user)
//        let resetPasswordData = try Node(node: [
//            "inputConfirmPassword": "Th3S@m3password",
//            ])
//        request.formURLEncoded = resetPasswordData
//
//        _ = try drop.respond(to: request)
//
//        XCTAssertTrue(capturingViewFactory.resetPasswordErrors?.contains("You must specify a password") ?? false)
//    }
//
//    func testUserCannotResetPasswordWithoutConfirmPassword() throws {
//        let user = TestDataBuilder.anyUser()
//        try user.save()
//
//        let request = try createLoggedInRequest(method: .post, path: "resetPassword", for: user)
//        let resetPasswordData = try Node(node: [
//            "inputPassword": "Th3S@m3password",
//            ])
//        request.formURLEncoded = resetPasswordData
//
//        _ = try drop.respond(to: request)
//
//        XCTAssertTrue(capturingViewFactory.resetPasswordErrors?.contains("You must confirm your password") ?? false)
//    }
//
//    func testUserCannotResetPasswordWithShortPassword() throws {
//        let user = TestDataBuilder.anyUser()
//        try user.save()
//
//        let request = try createLoggedInRequest(method: .post, path: "resetPassword", for: user)
//        let resetPasswordData = try Node(node: [
//            "inputPassword": "S12$345",
//            "inputConfirmPassword": "S12$345"
//            ])
//        request.formURLEncoded = resetPasswordData
//
//        _ = try drop.respond(to: request)
//
//        XCTAssertTrue(capturingViewFactory.resetPasswordErrors?.contains("Your password must contain a lowercase letter, an upperacase letter, a number and a symbol") ?? false)
//    }
//
//    func testUserIsRedirectedWhenLoggingInAndPasswordResetRequired() throws {
//        let user = TestDataBuilder.anyUser()
//        user.resetPasswordRequired = true
//        try user.save()
//
//        let request = try createLoggedInRequest(method: .get, path: "", for: user)
//
//        let response = try drop.respond(to: request)
//
//        XCTAssertEqual(response.status, .seeOther)
//        XCTAssertEqual(response.headers[HeaderKey.location], "/blog/admin/resetPassword/")
//    }
    
}
