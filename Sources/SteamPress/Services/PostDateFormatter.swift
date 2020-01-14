import Foundation
import Vapor

struct PostDateFormatter: ServiceType {
    static func makeService(for container: Container) throws -> PostDateFormatter {
        return .init()
    }
    
    let formatter: DateFormatter
    
    init() {
        self.formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d, yyyy"
    }
}
