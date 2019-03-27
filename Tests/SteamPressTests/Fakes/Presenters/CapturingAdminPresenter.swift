import SteamPress
import Vapor

class CapturingAdminPresenter: BlogAdminPresenter {
    
    // MARK: - BlogPresenter
    
    func createIndexView(on req: Request) -> EventLoopFuture<View> {
        return createFutureView(on: req)
    }
    
    func createPostView(on req: Request) -> EventLoopFuture<View> {
        return createFutureView(on: req)
    }
    
    // MARK: - Helpers
    
    func createFutureView(on req: Request) -> Future<View> {
        let data = "some HTML".convertToData()
        let view = View(data: data)
        return req.future(view)
    }
}
