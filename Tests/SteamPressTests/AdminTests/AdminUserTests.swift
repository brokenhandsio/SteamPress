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
    
    override func tearDown() {
        XCTAssertNoThrow(try testWorld.tryAsHardAsWeCanToShutdownApplication())
    }

    // MARK: - User Creation

    func testPresenterGetsCorrectValuesForCreateUserPage() throws {
        _ = try testWorld.getResponse(to: createUserPath, loggedInUser: user)

        XCTAssertNil(presenter.createUserErrors)
        XCTAssertNil(presenter.createUserName)
        XCTAssertNil(presenter.createUserUsername)
        let passwordError = try XCTUnwrap(presenter.createUserPasswordError)
        XCTAssertFalse(passwordError)
        let confirmPasswordError = try XCTUnwrap(presenter.createUserPasswordError)
        XCTAssertFalse(confirmPasswordError)
        let resetPasswordRequired = try XCTUnwrap(presenter.createUserResetPasswordRequired)
        XCTAssertFalse(resetPasswordRequired)
        XCTAssertNil(presenter.createUserUserID)
        XCTAssertNil(presenter.createUserProfilePicture)
        XCTAssertNil(presenter.createUserTwitterHandle)
        XCTAssertNil(presenter.createUserBiography)
        XCTAssertNil(presenter.createUserTagline)
        let editing = try XCTUnwrap(presenter.createUserEditing)
        XCTAssertFalse(editing)
        let nameError = try XCTUnwrap(presenter.createUserNameError)
        XCTAssertFalse(nameError)
        let usernameError = try XCTUnwrap(presenter.createUserUsernameError)
        XCTAssertFalse(usernameError)
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

        // First is user created in setup, final is one just created
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
    
    func testUserHasNoAdditionalInfoIfEmptyStringsSent() throws {
        struct CreateUserData: Content {
            static let defaultContentType = MediaType.urlEncodedForm
            let name = "Luke"
            let username = "lukes"
            let password = "somepassword"
            let confirmPassword = "somepassword"
            let profilePicture = ""
            let tagline = ""
            let biography = ""
            let twitterHandle = ""
        }

        let createData = CreateUserData()
        _ = try testWorld.getResponse(to: createUserPath, body: createData, loggedInUser: user)

        // First is user created in setup, final is one just created
        XCTAssertEqual(testWorld.context.repository.users.count, 2)
        let user = try XCTUnwrap(testWorld.context.repository.users.last)
        XCTAssertNil(user.profilePicture)
        XCTAssertNil(user.tagline)
        XCTAssertNil(user.biography)
        XCTAssertNil(user.twitterHandle)
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
        let nameError = try XCTUnwrap(presenter.createUserNameError)
        XCTAssertTrue(nameError)
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
        let usernameError = try XCTUnwrap(presenter.createUserUsernameError)
        XCTAssertTrue(usernameError)
    }

    func testUserCannotBeCreatedWithUsernameThatAlreadyExists() throws {
        struct CreateUserData: Content {
            static let defaultContentType = MediaType.urlEncodedForm
            let name = "Luke"
            let password = "password"
            let confirmPassword = "password"
            let username = "lukes"
        }
        
        _ = testWorld.createUser(username: "lukes")

        let createData = CreateUserData()
        _ = try testWorld.getResponse(to: createUserPath, body: createData, loggedInUser: user)

        let viewErrors = try XCTUnwrap(presenter.createUserErrors)
        XCTAssertTrue(viewErrors.contains("Sorry that username has already been taken"))
        let usernameError = try XCTUnwrap(presenter.createUserUsernameError)
        XCTAssertTrue(usernameError)
    }

    func testUserCannotBeCreatedWithUsernameThatAlreadyExistsIgnoringCase() throws {
        struct CreateUserData: Content {
            static let defaultContentType = MediaType.urlEncodedForm
            let name = "Luke"
            let password = "password"
            let confirmPassword = "password"
            let username = "Lukes"
        }
        
        _ = testWorld.createUser(username: "lukes")

        let createData = CreateUserData()
        _ = try testWorld.getResponse(to: createUserPath, body: createData, loggedInUser: user)

        let viewErrors = try XCTUnwrap(presenter.createUserErrors)
        XCTAssertTrue(viewErrors.contains("Sorry that username has already been taken"))
        let usernameError = try XCTUnwrap(presenter.createUserUsernameError)
        XCTAssertTrue(usernameError)
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
        let isEditing = try XCTUnwrap(presenter.createUserEditing)
        XCTAssertFalse(isEditing)
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
        let nameError = try XCTUnwrap(presenter.createUserNameError)
        XCTAssertTrue(nameError)
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
        let usernameError = try XCTUnwrap(presenter.createUserUsernameError)
        XCTAssertTrue(usernameError)
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
        let usernameError = try XCTUnwrap(presenter.createUserUsernameError)
        XCTAssertTrue(usernameError)
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
        XCTAssertNil(presenter.createUserErrors)
        let passwordError = try XCTUnwrap(presenter.createUserPasswordError)
        XCTAssertFalse(passwordError)
        let confirmPasswordError = try XCTUnwrap(presenter.createUserPasswordError)
        XCTAssertFalse(confirmPasswordError)
        let resetPasswordRequired = try XCTUnwrap(presenter.createUserResetPasswordRequired)
        XCTAssertEqual(resetPasswordRequired, user.resetPasswordRequired)
        let editing = try XCTUnwrap(presenter.createUserEditing)
        XCTAssertTrue(editing)
        let nameError = try XCTUnwrap(presenter.createUserNameError)
        XCTAssertFalse(nameError)
        let usernameError = try XCTUnwrap(presenter.createUserUsernameError)
        XCTAssertFalse(usernameError)
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

        XCTAssertEqual(testWorld.context.repository.users.count, 1)
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

        XCTAssertEqual(testWorld.context.repository.users.count, 1)
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

        XCTAssertEqual(testWorld.context.repository.users.count, 1)
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

        XCTAssertEqual(testWorld.context.repository.users.count, 1)
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
        _ = try testWorld.getResponse(to: "/admin/users/\(user.userID!)/edit", body: editData, loggedInUser: user)

        let viewErrors = try XCTUnwrap(presenter.createUserErrors)
        XCTAssertTrue(viewErrors.contains("Your passwords must match"))
        let passwordError = try XCTUnwrap(presenter.createUserPasswordError)
        let confirmPasswordError = try XCTUnwrap(presenter.createUserConfirmPasswordError)
        XCTAssertEqual(presenter.createUserUserID, user.userID)
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
        _ = try testWorld.getResponse(to: "/admin/users/\(user.userID!)/edit", body: editData, loggedInUser: user)

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
            let resetPasswordOnLogin = true
        }

        let editData = EditUserData()
        _ = try testWorld.getResponse(to: "/admin/users/\(user.userID!)/edit", body: editData, loggedInUser: user)

        let viewErrors = try XCTUnwrap(presenter.createUserErrors)
        XCTAssertTrue(viewErrors.contains("You must confirm your password"))
        XCTAssertTrue(viewErrors.contains("You must specify a password"))
        let passwordError = try XCTUnwrap(presenter.createUserPasswordError)
        let confirmPasswordError = try XCTUnwrap(presenter.createUserConfirmPasswordError)
        XCTAssertTrue(passwordError)
        XCTAssertTrue(confirmPasswordError)
        let resetPasswordOnLogin = try XCTUnwrap(presenter.createUserResetPasswordRequired)
        XCTAssertTrue(resetPasswordOnLogin)
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

    func testNameMustBeSetWhenEditingAUser() throws {
        struct EditUserData: Content {
            static let defaultContentType = MediaType.urlEncodedForm
            let name = ""
            let username = "darth_vader"
            let password = "somenewpassword"
            let confirmPassword = "somenewpassword"
        }

        let editData = EditUserData()
        _ = try testWorld.getResponse(to: "/admin/users/\(user.userID!)/edit", body: editData, loggedInUser: user)

        let editErrors = try XCTUnwrap(presenter.createUserErrors)
        XCTAssertTrue(editErrors.contains("You must specify a name"))
        let nameError = try XCTUnwrap(presenter.createUserNameError)
        XCTAssertTrue(nameError)
    }

    func testUsernameMustBeSetWhenEditingAUser() throws {
        struct EditUserData: Content {
            static let defaultContentType = MediaType.urlEncodedForm
            let name = "Darth Vader"
            let username = ""
            let password = "somenewpassword"
            let confirmPassword = "somenewpassword"
        }

        let editData = EditUserData()
        _ = try testWorld.getResponse(to: "/admin/users/\(user.userID!)/edit", body: editData, loggedInUser: user)

        let editErrors = try XCTUnwrap(presenter.createUserErrors)
        XCTAssertTrue(editErrors.contains("You must specify a username"))
        let usernameError = try XCTUnwrap(presenter.createUserUsernameError)
        XCTAssertTrue(usernameError)
    }

    // MARK: - Delete users

    func testCanDeleteUser() throws {
        let user2 = testWorld.createUser(name: "Han", username: "han")

        let response = try testWorld.getResponse(to: "/admin/users/\(user2.userID!)/delete", body: EmptyContent(), loggedInUser: user)

        XCTAssertEqual(response.http.status, .seeOther)
        XCTAssertEqual(response.http.headers[.location].first, "/admin/")
        XCTAssertEqual(testWorld.context.repository.users.count, 1)
        XCTAssertNotEqual(testWorld.context.repository.users.last?.name, "Han")
    }

    func testCannotDeleteSelf() throws {
        let user2 = testWorld.createUser(name: "Han", username: "han")
        let testData = try testWorld.createPost(author: user2)

        _ = try testWorld.getResponse(to: "/admin/users/\(user2.userID!)/delete", body: EmptyContent(), loggedInUser: user2)

        let viewErrors = try XCTUnwrap(presenter.adminViewErrors)
        XCTAssertTrue(viewErrors.contains("You cannot delete yourself whilst logged in"))
        XCTAssertEqual(testWorld.context.repository.users.count, 2)
        
        XCTAssertEqual(presenter.adminViewPosts?.count, 1)
        XCTAssertEqual(presenter.adminViewPosts?.first?.title, testData.post.title)
        XCTAssertEqual(presenter.adminViewUsers?.count, 2)
        XCTAssertEqual(presenter.adminViewUsers?.last?.username, user2.username)
    }

    func testCannotDeleteLastUser() throws {
        testWorld = try TestWorld.create()
        let adminUser = testWorld.createUser(name: "Admin", username: "admin")
        let testData = try testWorld.createPost(author: adminUser)
        _ = try testWorld.getResponse(to: "/admin/users/\(adminUser.userID!)/delete", body: EmptyContent(), loggedInUser: adminUser)

        let viewErrors = try XCTUnwrap(presenter.adminViewErrors)
        XCTAssertTrue(viewErrors.contains("You cannot delete the last user"))
        XCTAssertEqual(testWorld.context.repository.users.count, 1)
        
        XCTAssertEqual(presenter.adminViewPosts?.count, 1)
        XCTAssertEqual(presenter.adminViewPosts?.first?.title, testData.post.title)
        XCTAssertEqual(presenter.adminViewUsers?.count, 1)
        XCTAssertEqual(presenter.adminViewUsers?.first?.username, adminUser.username)
    }

}
