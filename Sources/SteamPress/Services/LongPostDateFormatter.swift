import Foundation
import Vapor

struct LongPostDateFormatter: ServiceType {
    static func makeService(for container: Container) throws -> LongPostDateFormatter {
        return .init()
    }
    
    let formatter: DateFormatter
    
    init() {
        self.formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d, yyyy"
    }
}
