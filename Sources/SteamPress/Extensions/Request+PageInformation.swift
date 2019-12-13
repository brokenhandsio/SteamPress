import Vapor

extension Request {
    func pageInformation() throws -> BlogGlobalPageInformation {
        #warning("Fix website URL")
        return try BlogGlobalPageInformation(disqusName: Environment.get("BLOG_DISQUS_NAME"), siteTwitterHandler: Environment.get("BLOG_SITE_TWITTER_HANDLER"), googleAnalyticsIdentifier: Environment.get("BLOG_GOOGLE_ANALYTICS_IDENTIFIER"), loggedInUser: authenticated(BlogUser.self), websiteURL: self.urlWithHTTPSIfReverseProxy(), currentPageURL: self.urlWithHTTPSIfReverseProxy())
    }

    func adminPageInfomation() throws -> BlogAdminPageInformation {
        return try BlogAdminPageInformation(loggedInUser: requireAuthenticated(BlogUser.self), websiteURL: self.urlWithHTTPSIfReverseProxy().getRootUrl(), currentPageURL: self.urlWithHTTPSIfReverseProxy())
    }
}
