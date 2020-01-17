import Foundation
import Vapor

struct NumericPostDateFormatter: ServiceType {
    static func makeService(for container: Container) throws -> NumericPostDateFormatter {
        return .init()
    }
    
    let formatter: DateFormatter
    
    init() {
        self.formatter = DateFormatter()
        self.formatter.calendar = Calendar(identifier: .iso8601)
        self.formatter.locale = Locale(identifier: "en_US_POSIX")
        self.formatter.timeZone = TimeZone(secondsFromGMT: 0)
        self.formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
    }
}

