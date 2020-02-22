public struct PaginationTagInformation: Encodable {
    public let currentPage: Int
    public let totalPages: Int
    public let currentQuery: String?
}
