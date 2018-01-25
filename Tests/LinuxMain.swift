import XCTest

@testable import SteamPressTests

XCTMain([
//    testCase(BlogPostTests.allTests),
//    testCase(BlogControllerTests.allTests),
//    testCase(BlogAdminControllerTests.allTests),
    testCase(BlogTagTests.allTests),
//    testCase(LeafViewFactoryTests.allTests),
    testCase(RSSFeedTests.allTests),
    testCase(AtomFeedTests.allTests),
    testCase(APITagControllerTests.allTests),
])
