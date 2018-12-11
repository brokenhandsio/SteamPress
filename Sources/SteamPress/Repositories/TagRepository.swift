import Vapor

public protocol TagRepository {
    func getAllTags(on req: Request) -> Future<[BlogTag]>
}
