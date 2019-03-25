import Vapor
import Foundation

struct RSSFeedGenerator {

    // MARK: - Properties

    let rfc822DateFormatter: DateFormatter
    let title: String
    let description: String
    let copyright: String?
    let imageURL: String?
    let xmlEnd = "</channel>\n\n</rss>"

    // MARK: - Initialiser

    init(title: String, description: String, copyright: String?, imageURL: String?) {
        self.title = title
        self.description = description
        self.copyright = copyright
        self.imageURL = imageURL

        rfc822DateFormatter = DateFormatter()
        rfc822DateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss z"
        rfc822DateFormatter.locale = Locale(identifier: "en_US_POSIX")
        rfc822DateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
    }

    // MARK: - Route Handler

    func feedHandler(_ request: Request) throws -> Future<HTTPResponse> {

        let blogRepository = try request.make(BlogPostRepository.self)
        return blogRepository.getAllPostsSortedByPublishDate(on: request, includeDrafts: false).flatMap { posts in
            var xmlFeed = try self.getXMLStart(for: request)
            
            if !posts.isEmpty {
                let postDate = posts[0].lastEdited ?? posts[0].created
                xmlFeed += "<pubDate>\(self.rfc822DateFormatter.string(from: postDate))</pubDate>\n"
            }
            
            xmlFeed += "<textinput>\n<description>Search \(self.title)</description>\n<title>Search</title>\n<link>\(self.getRootPath(for: request))/search?</link>\n<name>term</name>\n</textinput>\n"

            var postData: [Future<String>] = []
            for post in posts {
                try postData.append(post.getPostRSSFeed(rootPath: self.getRootPath(for: request), dateFormatter: self.rfc822DateFormatter, for: request))
            }
            
            return postData.flatten(on: request).map { postInformation in
                for post in postInformation {
                    xmlFeed += post
                }
                
                xmlFeed += self.xmlEnd
                var httpResponse = HTTPResponse(body: xmlFeed)
                httpResponse.headers.add(name: .contentType, value: "application/rss+xml")
                return httpResponse
            }
        }
    }

    // MARK: - Private functions

    private func getXMLStart(for request: Request) throws -> String {

        let link = getRootPath(for: request) + "/"

        var start = "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>\n<rss version=\"2.0\">\n\n<channel>\n<title>\(title)</title>\n<link>\(link)</link>\n<description>\(description)</description>\n<generator>SteamPress</generator>\n<ttl>60</ttl>\n"

        if let copyright = copyright {
            start += "<copyright>\(copyright)</copyright>\n"
        }

        if let imageURL = imageURL {
            start += "<image>\n<url>\(imageURL)</url>\n<title>\(title)</title>\n<link>\(link)</link>\n</image>\n"
        }

        return start
    }

    private func getRootPath(for request: Request) -> String {
        return request.urlWithHTTPSIfReverseProxy().descriptionWithoutPort.replacingOccurrences(of: "/rss.xml", with: "")
    }
}

fileprivate extension BlogPost {
    fileprivate func getPostRSSFeed(rootPath: String, dateFormatter: DateFormatter, for request: Request) throws -> Future<String> {
        let link = rootPath + "/posts/\(slugUrl)/"
        var postEntry = "<item>\n<title>\n\(title)\n</title>\n<description>\n\(try description())\n</description>\n<link>\n\(link)\n</link>\n"
        
        let tagRepository = try request.make(BlogTagRepository.self)
        return tagRepository.getTags(for: self, on: request).map { tags in
            for tag in tags {
                if let percentDecodedTag = tag.name.removingPercentEncoding {
                    postEntry += "<category>\(percentDecodedTag)</category>\n"
                }
            }
            postEntry += "<pubDate>\(dateFormatter.string(from: self.lastEdited ?? self.created))</pubDate>\n</item>\n"
            return postEntry
        }
    }
}

