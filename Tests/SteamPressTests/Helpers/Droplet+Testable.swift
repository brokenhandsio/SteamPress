import Vapor
@testable import SteamPress

//extension Droplet {
//    static func prepare(database: Database) throws {
//        BlogUser.database = database
//        BlogPost.database = database
//        BlogTag.database = database
//        Pivot<BlogPost, BlogTag>.database = database
//        try BlogUser.prepare(database)
//        try BlogPost.prepare(database)
//        try BlogTag.prepare(database)
//        try BlogPostDraft.prepare(database)
//        try BlogUserExtraInformation.prepare(database)
//        try Pivot<BlogPost, BlogTag>.prepare(database)
//    }
//
//    static func teardown(database: Database) throws {
//        try Pivot<BlogPost, BlogTag>.revert(database)
//        try BlogTag.revert(database)
//        try BlogPost.revert(database)
//        try BlogUser.revert(database)
//    }
//}

