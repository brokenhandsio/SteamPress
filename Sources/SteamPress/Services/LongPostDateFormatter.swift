import Foundation
import Vapor

struct LongPostDateFormatter {    
    let formatter: DateFormatter
    
    init() {
        self.formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d, yyyy"
    }
}
