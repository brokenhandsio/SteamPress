import Vapor

extension Request {
    func pageInformation() throws -> BlogGlobalPageInformation {
        return try BlogGlobalPageInformation(disqusName: Environment.get("BLOG_DISQUS_NAME"), siteTwitterHandle: Environment.get("BLOG_SITE_TWITTER_HANDLE"), googleAnalyticsIdentifier: Environment.get("BLOG_GOOGLE_ANALYTICS_IDENTIFIER"), loggedInUser: authenticated(BlogUser.self), websiteURL: self.urlWithHTTPSIfReverseProxy().getRootUrl(), currentPageURL: self.urlWithHTTPSIfReverseProxy())
    }

    func adminPageInfomation() throws -> BlogAdminPageInformation {
        return try BlogAdminPageInformation(loggedInUser: requireAuthenticated(BlogUser.self), websiteURL: self.urlWithHTTPSIfReverseProxy().getRootUrl(), currentPageURL: self.urlWithHTTPSIfReverseProxy())
    }
}
