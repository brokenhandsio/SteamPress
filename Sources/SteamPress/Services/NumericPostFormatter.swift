import Foundation
import Vapor

struct NumericPostDateFormatter: ServiceType {
    static func makeService(for container: Container) throws -> NumericPostDateFormatter {
        return .init()
    }
    
    let formatter: DateFormatter
    
    init() {
        self.formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy HH:mm"
    }
}

