import Vapor

extension Request {
    func getPaginationInformation() -> PaginationInformation {
        if let pageQuery = try? query.get(Int.self, at: "page") {
            guard pageQuery > 0 else {
                return PaginationInformation(page: 1)
            }
            return PaginationInformation(page: pageQuery)
        } else {
            return PaginationInformation(page: 1)
        }
    }
}
