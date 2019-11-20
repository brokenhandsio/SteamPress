import Vapor

extension Request {
    func getPaginationInformation() -> PaginationInformation {
        if let pageQuery = try? query.get(Int.self, at: "page") {
            return PaginationInformation(page: pageQuery)
        } else {
            return PaginationInformation(page: 1)
        }
    }
}
