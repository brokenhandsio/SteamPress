import Vapor

extension Request {
    func getPaginationInformation(postsPerPage: Int) -> PaginationInformation {
        if let pageQuery = try? query.get(Int.self, at: "page") {
            guard pageQuery > 0 else {
                return PaginationInformation(page: 1, offset: 0, postsPerPage: postsPerPage)
            }
            let offset = (pageQuery - 1) * postsPerPage
            return PaginationInformation(page: pageQuery, offset: offset, postsPerPage: postsPerPage)
        } else {
            return PaginationInformation(page: 1, offset: 0, postsPerPage: postsPerPage)
        }
    }
}
