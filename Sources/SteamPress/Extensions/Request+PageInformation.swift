import Vapor

extension Request {
    func pageInformation() throws -> BlogGlobalPageInformation {
        return try BlogGlobalPageInformation(disqusName: Environment.get("BLOG_DISQUS_NAME"), siteTwitterHandler: Environment.get("BLOG_SITE_TWITTER_HANDLER"), googleAnalyticsIdentifier: Environment.get("BLOG_GOOGLE_ANALYTICS_IDENTIFIER"), loggedInUser: authenticated(BlogUser.self))
    }
}
