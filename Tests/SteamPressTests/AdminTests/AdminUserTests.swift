import XCTest
import Vapor
@testable import SteamPress

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
    
    // MARK: - User Creation
    
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
        
        // First is admin user, next is user created in setup, final is one just created
        XCTAssertEqual(testWorld.context.repository.users.count, 3)
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
    
    func testUserCannotBeCreatedWithUsernameThatAlreadyExists() throws {
        struct CreateUserData: Content {
            static let defaultContentType = MediaType.urlEncodedForm
            let name = "Luke"
            let password = "password"
            let confirmPassword = "password"
            let username = "admin"
        }
        
        let createData = CreateUserData()
        _ = try testWorld.getResponse(to: createUserPath, body: createData, loggedInUser: user)
        
        let viewErrors = try XCTUnwrap(presenter.createUserErrors)
        XCTAssertTrue(viewErrors.contains("Sorry that username has already been taken"))
    }
    
    func testUserCannotBeCreatedWithUsernameThatAlreadyExistsIgnoringCase() throws {
        struct CreateUserData: Content {
            static let defaultContentType = MediaType.urlEncodedForm
            let name = "Luke"
            let password = "password"
            let confirmPassword = "password"
            let username = "Admin"
        }
        
        let createData = CreateUserData()
        _ = try testWorld.getResponse(to: createUserPath, body: createData, loggedInUser: user)
        
        let viewErrors = try XCTUnwrap(presenter.createUserErrors)
        XCTAssertTrue(viewErrors.contains("Sorry that username has already been taken"))
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
        let passwordError = try XCTUnwrap(presenter.createUserPasswordError)
        XCTAssertTrue(passwordError)
    }
    
    func testUserCannotBeCreatedWithEmptyPassword() throws {
        struct CreateUserData: Content {
            static let defaultContentType = MediaType.urlEncodedForm
            let name = "Luke"
            let username = "lukes"
            let password = ""
            let confirmPassword = ""
        }
        
        let createData = CreateUserData()
        _ = try testWorld.getResponse(to: createUserPath, body: createData, loggedInUser: user)
        
        let viewErrors = try XCTUnwrap(presenter.createUserErrors)
        XCTAssertTrue(viewErrors.contains("You must specify a password"))
        let passwordError = try XCTUnwrap(presenter.createUserPasswordError)
        XCTAssertTrue(passwordError)
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
        let confirmPasswordError = try XCTUnwrap(presenter.createUserConfirmPasswordError)
        XCTAssertTrue(confirmPasswordError)
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
        
        let passwordError = try XCTUnwrap(presenter.createUserPasswordError)
        let confirmPasswordError = try XCTUnwrap(presenter.createUserConfirmPasswordError)
        XCTAssertTrue(passwordError)
        XCTAssertTrue(confirmPasswordError)
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
        let passwordError = try XCTUnwrap(presenter.createUserPasswordError)
        XCTAssertTrue(passwordError)
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
    
    func testPasswordIsActuallyHashedWhenCreatingAUser() throws {
        testWorld = try! TestWorld.create(passwordHasherToUse: .reversed)
        let usersPassword = "password"
        let hashedPassword = String(usersPassword.reversed())
        user = testWorld.createUser(name: "Leia", username: "leia", password: hashedPassword)
        
        struct CreateUserData: Content {
            static let defaultContentType = MediaType.urlEncodedForm
            let name = "Luke"
            let username = "lukes"
            let password = "somepassword"
            let confirmPassword = "somepassword"
        }

        let createData = CreateUserData()
        _ = try testWorld.getResponse(to: createUserPath, body: createData, loggedInUser: user, passwordToLoginWith: usersPassword)
        
        let newUser = try XCTUnwrap(testWorld.context.repository.users.last)
        XCTAssertEqual(newUser.password, String(createData.password.reversed()))
    }
    
    // MARK: - Edit Users
    
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
        
        XCTAssertEqual(testWorld.context.repository.users.count, 2)
        let updatedUser = try XCTUnwrap(testWorld.context.repository.users.last)
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
        
        XCTAssertEqual(testWorld.context.repository.users.count, 2)
        let updatedUser = try XCTUnwrap(testWorld.context.repository.users.last)
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
        
        XCTAssertEqual(testWorld.context.repository.users.count, 2)
        let updatedUser = try XCTUnwrap(testWorld.context.repository.users.last)
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
        
        XCTAssertEqual(testWorld.context.repository.users.count, 2)
        let updatedUser = try XCTUnwrap(testWorld.context.repository.users.last)
        XCTAssertFalse(updatedUser.resetPasswordRequired)
        XCTAssertEqual(updatedUser.userID, user.userID)
        XCTAssertEqual(response.http.status, .seeOther)
        XCTAssertEqual(response.http.headers[.location].first, "/admin/")
    }
    
    func testPasswordIsUpdatedWhenNewPasswordProvidedWhenEditingUser() throws {
        struct EditUserData: Content {
            static let defaultContentType = MediaType.urlEncodedForm
            let name = "Luke"
            let username = "lukes"
            let password = "anewpassword"
            let confirmPassword = "anewpassword"
        }
        
        let editData = EditUserData()
        let response = try testWorld.getResponse(to: "/admin/users/\(user.userID!)/edit", body: editData, loggedInUser: user)
        
        XCTAssertEqual(testWorld.context.repository.users.count, 2)
        let updatedUser = try XCTUnwrap(testWorld.context.repository.users.last)
        XCTAssertEqual(updatedUser.password, editData.password)
        XCTAssertEqual(updatedUser.userID, user.userID)
        XCTAssertEqual(response.http.status, .seeOther)
        XCTAssertEqual(response.http.headers[.location].first, "/admin/")
    }
    
    func testErrorShownWhenUpdatingUsersPasswordWithNonMatchingPasswords() throws {
        struct EditUserData: Content {
            static let defaultContentType = MediaType.urlEncodedForm
            let name = "Luke"
            let username = "lukes"
            let password = "anewpassword"
            let confirmPassword = "someotherpassword"
        }
        
        let editData = EditUserData()
        let _ = try testWorld.getResponse(to: "/admin/users/\(user.userID!)/edit", body: editData, loggedInUser: user)
        
        let viewErrors = try XCTUnwrap(presenter.createUserErrors)
        XCTAssertTrue(viewErrors.contains("Your passwords must match"))
        let passwordError = try XCTUnwrap(presenter.createUserPasswordError)
        let confirmPasswordError = try XCTUnwrap(presenter.createUserConfirmPasswordError)
        XCTAssertTrue(passwordError)
        XCTAssertTrue(confirmPasswordError)
    }
    
    func testErrorShownWhenChangingUsersPasswordWithShortPassword() throws {
        struct EditUserData: Content {
            static let defaultContentType = MediaType.urlEncodedForm
            let name = "Luke"
            let username = "lukes"
            let password = "a"
            let confirmPassword = "a"
        }
        
        let editData = EditUserData()
        let _ = try testWorld.getResponse(to: "/admin/users/\(user.userID!)/edit", body: editData, loggedInUser: user)
        
        let viewErrors = try XCTUnwrap(presenter.createUserErrors)
        XCTAssertTrue(viewErrors.contains("Your password must be at least 10 characters long"))
        let passwordError = try XCTUnwrap(presenter.createUserPasswordError)
        XCTAssertTrue(passwordError)
    }
    
    func testErrorShownWhenTryingToChangeUsersPasswordWithEmptyString() throws {
        struct EditUserData: Content {
            static let defaultContentType = MediaType.urlEncodedForm
            let name = "Luke"
            let username = "lukes"
            let password = ""
            let confirmPassword = ""
        }
        
        let editData = EditUserData()
        let _ = try testWorld.getResponse(to: "/admin/users/\(user.userID!)/edit", body: editData, loggedInUser: user)
        
        let viewErrors = try XCTUnwrap(presenter.createUserErrors)
        XCTAssertTrue(viewErrors.contains("You must confirm your password"))
        XCTAssertTrue(viewErrors.contains("You must specify a password"))
        let passwordError = try XCTUnwrap(presenter.createUserPasswordError)
        let confirmPasswordError = try XCTUnwrap(presenter.createUserConfirmPasswordError)
        XCTAssertTrue(passwordError)
        XCTAssertTrue(confirmPasswordError)
    }
    
    func testPasswordIsActuallyHashedWhenEditingAUser() throws {
        testWorld = try! TestWorld.create(passwordHasherToUse: .reversed)
        let usersPassword = "password"
        let hashedPassword = String(usersPassword.reversed())
        user = testWorld.createUser(name: "Leia", username: "leia", password: hashedPassword)
        
        struct EditUserData: Content {
            static let defaultContentType = MediaType.urlEncodedForm
            let name = "Darth Vader"
            let username = "darth_vader"
            let password = "somenewpassword"
            let confirmPassword = "somenewpassword"
        }
        
        let editData = EditUserData()
        _ = try testWorld.getResponse(to: "/admin/users/\(user.userID!)/edit", body: editData, loggedInUser: user, passwordToLoginWith: usersPassword)
        
        let updatedUser = try XCTUnwrap(testWorld.context.repository.users.last)
        XCTAssertEqual(updatedUser.password, String(editData.password.reversed()))
    }
    
    // MARK: - Delete users
    
    func testCanDeleteUser() throws {
        let user2 = testWorld.createUser(name: "Han", username: "han")
        
        let response = try testWorld.getResponse(to: "/admin/users/\(user2.userID!)/delete", body: EmptyContent(), loggedInUser: user)

        XCTAssertEqual(response.http.status, .seeOther)
        XCTAssertEqual(response.http.headers[.location].first, "/admin/")
        XCTAssertEqual(testWorld.context.repository.users.count, 2)
        XCTAssertNotEqual(testWorld.context.repository.users.last?.name, "Han")
    }

    func testCannotDeleteSelf() throws {
        let user2 = testWorld.createUser(name: "Han", username: "han")

        _ = try testWorld.getResponse(to: "/admin/users/\(user2.userID!)/delete", body: EmptyContent(), loggedInUser: user2)

        let viewErrors = try XCTUnwrap(presenter.adminViewErrors)
        XCTAssertTrue(viewErrors.contains("You cannot delete yourself whilst logged in"))
        XCTAssertEqual(testWorld.context.repository.users.count, 3)
    }

    func testCannotDeleteLastUser() throws {
        testWorld = try TestWorld.create()
        let adminUser = try XCTUnwrap(testWorld.context.repository.users.first)
        _ = try testWorld.getResponse(to: "/admin/users/\(adminUser.userID!)/delete", body: EmptyContent(), loggedInUser: adminUser)
        
        let viewErrors = try XCTUnwrap(presenter.adminViewErrors)
        XCTAssertTrue(viewErrors.contains("You cannot delete the last user"))
        XCTAssertEqual(testWorld.context.repository.users.count, 1)
    }
    
}
