import SteamPress
import Vapor

class CapturingAdminPresenter: BlogAdminPresenter {
    
    // MARK: - BlogPresenter
    private(set) var adminViewErrors: [String]?
    func createIndexView(on req: Request, errors: [String]?) -> EventLoopFuture<View> {
        self.adminViewErrors = errors
        return createFutureView(on: req)
    }
    
    private(set) var createPostErrors: [String]?
    func createPostView(on req: Request, errors: [String]?) -> EventLoopFuture<View> {
        self.createPostErrors = errors
        return createFutureView(on: req)
    }
    
    private(set) var createUserErrors: [String]?
    func createUserView(on req: Request, errors: [String]?) -> EventLoopFuture<View> {
        self.createUserErrors = errors
        return createFutureView(on: req)
    }
    
    private(set) var resetPasswordErrors: [String]?
    private(set) var resetPasswordError: Bool?
    private(set) var resetPasswordConfirmError: Bool?
    func createResetPasswordView(on req: Request, errors: [String]?, passwordError: Bool?, confirmPasswordError: Bool?) -> EventLoopFuture<View> {
        self.resetPasswordErrors = errors
        self.resetPasswordError = passwordError
        self.resetPasswordConfirmError = confirmPasswordError
        return createFutureView(on: req)
    }
    
    
    // MARK: - Helpers
    
    func createFutureView(on req: Request) -> Future<View> {
        let data = "some HTML".convertToData()
        let view = View(data: data)
        return req.future(view)
    }
}
