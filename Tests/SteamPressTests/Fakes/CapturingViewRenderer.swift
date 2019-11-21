import Vapor

class CapturingViewRenderer: ViewRenderer, Service {
    var shouldCache = false
    var worker: Worker

    init(worker: Worker) {
        self.worker = worker
    }

    private(set) var capturedContext: Encodable? = nil
    private(set) var templatePath: String? = nil
    func render<E>(_ path: String, _ context: E, userInfo: [AnyHashable : Any]) -> EventLoopFuture<View> where E : Encodable {
        self.capturedContext = context
        self.templatePath = path
        return Future.map(on: worker) { return View(data: "Test".convertToData()) }
    }
    
}
