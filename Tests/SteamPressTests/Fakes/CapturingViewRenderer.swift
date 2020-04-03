import Vapor

class CapturingViewRenderer: ViewRenderer {
    var shouldCache = false
    var eventLoop: EventLoop

    init(eventLoop: EventLoop) {
        self.eventLoop = eventLoop
    }
    
    func `for`(_ request: Request) -> ViewRenderer {
        return CapturingViewRenderer(eventLoop: request.eventLoop)
    }

    private(set) var capturedContext: Encodable?
    private(set) var templatePath: String?
    func render<E>(_ name: String, _ context: E) -> EventLoopFuture<View> where E : Encodable {
        self.capturedContext = context
        self.templatePath = name
        return TestDataBuilder.createFutureView(on: eventLoop)
    }

}
