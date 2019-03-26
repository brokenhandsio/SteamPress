import Vapor
import Foundation

struct AtomFeedGenerator {
    
    // MARK: - Properties
    let title: String
    let description: String
    let copyright: String?
    let imageURL: String?
    
    let xmlDeclaration = "<?xml version=\"1.0\" encoding=\"utf-8\"?>"
    let feedStart = "<feed xmlns=\"http://www.w3.org/2005/Atom\">"
    let feedEnd = "</feed>"
    let iso8601Formatter = DateFormatter()
    
    // MARK: - Initialiser
    init(title: String, description: String, copyright: String?, imageURL: String?) {
        self.title = title
        self.description = description
        self.copyright = copyright
        self.imageURL = imageURL
        
        iso8601Formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        iso8601Formatter.locale = Locale(identifier: "en_US_POSIX")
        iso8601Formatter.timeZone = TimeZone(secondsFromGMT: 0)
    }
    
    // MARK: - Route Handler
    
    func feedHandler(_ request: Request) throws -> Future<HTTPResponse> {
        
        let blogRepository = try request.make(BlogPostRepository.self)
        return blogRepository.getAllPostsSortedByPublishDate(on: request, includeDrafts: false).flatMap { posts in
            var feed = self.getFeedStart(for: request)
            
            if !posts.isEmpty {
                let postDate = posts[0].lastEdited ?? posts[0].created
                feed += "<updated>\(self.iso8601Formatter.string(from: postDate))</updated>\n"
            } else {
                feed += "<updated>\(self.iso8601Formatter.string(from: Date()))</updated>\n"
            }
            
            if let copyright = self.copyright {
                feed += "<rights>\(copyright)</rights>\n"
            }
            
            if let imageURL = self.imageURL {
                feed += "<logo>\(imageURL)</logo>\n"
            }
            
            var postData: [Future<String>] = []
            for post in posts {
                try postData.append(post.getPostAtomFeed(blogPath: self.getRootPath(for: request), dateFormatter: self.iso8601Formatter, for: request))
            }
            
            return postData.flatten(on: request).map { postsInformation in
                for postInformation in postsInformation {
                    feed += postInformation
                }
                
                feed += self.feedEnd
                var httpResponse = HTTPResponse(body: feed)
                httpResponse.headers.add(name: .contentType, value: "application/atom+xml")
                return httpResponse
            }
        }
    }
    
    // MARK: - Private functions
    
    private func getFeedStart(for request: Request) -> String {
        let blogLink = getRootPath(for: request) + "/"
        let feedLink = blogLink + "atom.xml"
        return "\(xmlDeclaration)\n\(feedStart)\n\n<title>\(title)</title>\n<subtitle>\(description)</subtitle>\n<id>\(blogLink)</id>\n<link rel=\"alternate\" type=\"text/html\" href=\"\(blogLink)\"/>\n<link rel=\"self\" type=\"application/atom+xml\" href=\"\(feedLink)\"/>\n<generator uri=\"https://www.steampress.io/\">SteamPress</generator>\n"
    }
    
    private func getRootPath(for request: Request) -> String {
        return request.urlWithHTTPSIfReverseProxy().descriptionWithoutPort.replacingOccurrences(of: "/atom.xml", with: "")
    }
}

fileprivate extension BlogPost {
    func getPostAtomFeed(blogPath: String, dateFormatter: DateFormatter, for request: Request) throws -> Future<String> {
        let updatedTime = lastEdited ?? created
        let authorRepository = try request.make(BlogUserRepository.self)
        return authorRepository.getUser(author, on: request).flatMap { user in
            guard let user = user else {
                throw SteamPressError(identifier: "Invalid-relationship", "Blog user with ID \(self.author) not found")
            }
            guard let postID = self.blogID else {
                throw SteamPressError(identifier: "ID-required", "Blog Post has no ID")
            }
            var postEntry = "<entry>\n<id>\(blogPath)/posts-id/\(postID)/</id>\n<title>\(self.title)</title>\n<updated>\(dateFormatter.string(from: updatedTime))</updated>\n<published>\(dateFormatter.string(from: self.created))</published>\n<author>\n<name>\(user.name)</name>\n<uri>\(blogPath)/authors/\(user.username)/</uri>\n</author>\n<summary>\(try self.description())</summary>\n<link rel=\"alternate\" href=\"\(blogPath)/posts/\(self.slugUrl)/\" />\n"
            
            let tagRepository = try request.make(BlogTagRepository.self)
            return tagRepository.getTags(for: self, on: request).map { tags in
                for tag in tags {
                    if let percentDecodedTag = tag.name.removingPercentEncoding {
                        postEntry += "<category term=\"\(percentDecodedTag)\"/>\n"
                    }
                }
                
                postEntry += "</entry>\n"
                return postEntry
            }
        }
    }
}

