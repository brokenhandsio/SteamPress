import Vapor
import URI
import HTTP
import SwiftMarkdown
import SwiftSoup
import Foundation
import Fluent

struct ViewFactory {

    public let viewRenderer: ViewRenderer

    let disqusName: String?
    let siteTwitterHandle: String?
    let googleAnalyticsIdentifier: String?
    
    init(viewRenderer: ViewRenderer, disqusName: String?, siteTwitterHandle: String?, googleAnalyticsIdentifier: String?) {
        self.viewRenderer = viewRenderer
        self.disqusName = disqusName
        self.siteTwitterHandle = siteTwitterHandle
        self.googleAnalyticsIdentifier = googleAnalyticsIdentifier
    }

    public func createPublicView(template: String, uri: URI, parameters: [String: NodeRepresentable], user: BlogUser? = nil) throws -> View {
        var viewParameters = parameters

        viewParameters["uri"] = uri.descriptionWithoutPort.makeNode(in: nil)

        if let user = user {
            viewParameters["user"] = try user.makeNode(in: nil)
        }

        if let disqusName = disqusName {
            viewParameters["disqus_name"] = disqusName.makeNode(in: nil)
        }

        if let siteTwitterHandle = siteTwitterHandle {
            viewParameters["site_twitter_handle"] = siteTwitterHandle.makeNode(in: nil)
        }

        if let googleAnalyticsIdentifier = googleAnalyticsIdentifier {
            viewParameters["google_analytics_identifier"] = googleAnalyticsIdentifier.makeNode(in: nil)
        }

        return try viewRenderer.make(template, viewParameters.makeNode(in: nil))
    }
}
