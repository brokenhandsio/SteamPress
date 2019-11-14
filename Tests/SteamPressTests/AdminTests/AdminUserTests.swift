import XCTest
import Vapor
import SteamPress

class AdminUserTests: XCTestCase {
    
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
        let user = try XCTUnwrap(testWorld.context.repository.users.last)
        XCTAssertEqual(user.username, createData.username)
        XCTAssertEqual(user.name, createData.name)
        XCTAssertEqual(user.profilePicture, createData.profilePicture)
        XCTAssertEqual(user.tagline, createData.tagline)
        XCTAssertEqual(user.biography, createData.biography)
        XCTAssertEqual(user.twitterHandle, createData.twitterHandle)
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
        
        let user = try XCTUnwrap(testWorld.context.repository.users.filter { $0.username == data.username }.first)
        XCTAssertTrue(user.resetPasswordRequired)
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

        let viewErrors = try XCTUnwrap(presenter.createUserErrors)
        XCTAssertTrue(viewErrors.contains("You must specify a name"))
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
        
        let viewErrors = try XCTUnwrap(presenter.createUserErrors)
        XCTAssertTrue(viewErrors.contains("You must specify a username"))
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
        
        let viewErrors = try XCTUnwrap(presenter.createUserErrors)
        XCTAssertTrue(viewErrors.contains("You must specify a password"))
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
        
        let viewErrors = try XCTUnwrap(presenter.createUserErrors)
        XCTAssertTrue(viewErrors.contains("You must confirm your password"))
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
        
        let viewErrors = try XCTUnwrap(presenter.createUserErrors)
        XCTAssertTrue(viewErrors.contains("Your passwords must match"))
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

        let viewErrors = try XCTUnwrap(presenter.createUserErrors)
        XCTAssertTrue(viewErrors.contains("Your password must be at least 10 characters long"))
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
        
        let viewErrors = try XCTUnwrap(presenter.createUserErrors)
        XCTAssertTrue(viewErrors.contains("You must specify a name"))
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
        
        let viewErrors = try XCTUnwrap(presenter.createUserErrors)
        XCTAssertTrue(viewErrors.contains("You must specify a username"))
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

        let viewErrors = try XCTUnwrap(presenter.createUserErrors)
        XCTAssertTrue(viewErrors.contains("The username provided is not valid"))
    }
    
    func testPresenterGetsUserInformationOnEditUserPage() throws {
        _ = try testWorld.getResponse(to: "/admin/users/\(user.userID!)/edit", loggedInUser: user)
        XCTAssertEqual(presenter.createUserName, user.name)
        XCTAssertEqual(presenter.createUserUsername, user.username)
        XCTAssertEqual(presenter.createUserUserID, user.userID)
        XCTAssertEqual(presenter.createUserProfilePicture, user.profilePicture)
        XCTAssertEqual(presenter.createUserTwitterHandle, user.twitterHandle)
        XCTAssertEqual(presenter.createUserBiography, user.biography)
        XCTAssertEqual(presenter.createUserTagline, user.tagline)
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
        let updatedUser = try XCTUnwrap(testWorld.context.repository.users.first)
        XCTAssertEqual(updatedUser.username, editData.username)
        XCTAssertEqual(updatedUser.name, editData.name)
        XCTAssertEqual(updatedUser.userID, user.userID)
        XCTAssertEqual(response.http.status, .seeOther)
        XCTAssertEqual(response.http.headers[.location].first, "/admin/")
    }
    
    func testUserCanBeUpdatedWithAllInformation() throws {
        struct EditUserData: Content {
            static let defaultContentType = MediaType.urlEncodedForm
            let name = "Darth Vader"
            let username = "darth_vader"
            let twitterHandle = "darthVader"
            let profilePicture = "https://deathstar.org/pictures/dv.jpg"
            let tagline = "The Sith Lord formally known as Anakin"
            let biography = "Father of one, part cyborg, Sith Lord. Something something dark side."
        }
        
        let editData = EditUserData()
        let response = try testWorld.getResponse(to: "/admin/users/\(user.userID!)/edit", body: editData, loggedInUser: user)
        
        XCTAssertEqual(testWorld.context.repository.users.count, 1)
        let updatedUser = try XCTUnwrap(testWorld.context.repository.users.first)
        XCTAssertEqual(updatedUser.username, editData.username)
        XCTAssertEqual(updatedUser.name, editData.name)
        XCTAssertEqual(updatedUser.twitterHandle, editData.twitterHandle)
        XCTAssertEqual(updatedUser.profilePicture, editData.profilePicture)
        XCTAssertEqual(updatedUser.tagline, editData.tagline)
        XCTAssertEqual(updatedUser.biography, editData.biography)
        XCTAssertEqual(updatedUser.userID, user.userID)
        XCTAssertEqual(response.http.status, .seeOther)
        XCTAssertEqual(response.http.headers[.location].first, "/admin/")
    }
    
    func testWhenEditingUserResetPasswordFlagSetIfRequired() throws {
        struct EditUserData: Content {
            static let defaultContentType = MediaType.urlEncodedForm
            let name = "Luke"
            let username = "lukes"
            let resetPasswordOnLogin = true
        }
        
        let editData = EditUserData()
        let response = try testWorld.getResponse(to: "/admin/users/\(user.userID!)/edit", body: editData, loggedInUser: user)
        
        XCTAssertEqual(testWorld.context.repository.users.count, 1)
        let updatedUser = try XCTUnwrap(testWorld.context.repository.users.first)
        XCTAssertTrue(updatedUser.resetPasswordRequired)
        XCTAssertEqual(updatedUser.userID, user.userID)
        XCTAssertEqual(response.http.status, .seeOther)
        XCTAssertEqual(response.http.headers[.location].first, "/admin/")
    }
    
    func testWhenEditingUserResetPasswordFlagNotSetIfSetToFalse() throws {
        struct EditUserData: Content {
            static let defaultContentType = MediaType.urlEncodedForm
            let name = "Luke"
            let username = "lukes"
            let resetPasswordOnLogin = false
        }
        
        let editData = EditUserData()
        let response = try testWorld.getResponse(to: "/admin/users/\(user.userID!)/edit", body: editData, loggedInUser: user)
        
        XCTAssertEqual(testWorld.context.repository.users.count, 1)
        let updatedUser = try XCTUnwrap(testWorld.context.repository.users.first)
        XCTAssertFalse(updatedUser.resetPasswordRequired)
        XCTAssertEqual(updatedUser.userID, user.userID)
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

        let viewErrors = try XCTUnwrap(presenter.adminViewErrors)
        XCTAssertTrue(viewErrors.contains("You cannot delete yourself whilst logged in"))
        XCTAssertEqual(testWorld.context.repository.users.count, 2)
    }

    func testCannotDeleteLastUser() throws {
        _ = try testWorld.getResponse(to: "/admin/users/\(user.userID!)/delete", body: EmptyContent(), loggedInUser: user)
        
        let viewErrors = try XCTUnwrap(presenter.adminViewErrors)
        XCTAssertTrue(viewErrors.contains("You cannot delete the last user"))
        XCTAssertEqual(testWorld.context.repository.users.count, 1)
    }
    
}
