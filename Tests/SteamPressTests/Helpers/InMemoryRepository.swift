import Vapor
import SteamPress

class InMemoryRepository: TagRepository, Service {
    
    private var tags: [BlogTag]
    
    init() {
        tags = []
    }
    
    func getAllTags(on req: Request) -> Future<[BlogTag]> {
        return req.future(tags)
    }
    
    func addTag(name: String) {
        let newTag = BlogTag(id: tags.count + 1, name: name)
        tags.append(newTag)
    }
    
}
