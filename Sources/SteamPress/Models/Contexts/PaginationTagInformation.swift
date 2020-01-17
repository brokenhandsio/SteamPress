public struct PaginationTagInformation: Encodable {
    let currentPage: Int
    let totalPages: Int
    let currentQuery: String?
}
