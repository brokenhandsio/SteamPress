//
//  BlogTagTests.swift
//  SteamPress
//
//  Created by Tim Condon on 13/03/2017.
//
//

import XCTest
@testable import SteamPress
import Fluent
import Vapor

class BlogTagTests: XCTestCase {

    static var allTests = [
        ("testNonDatabaseContextNodeContainsUrlEncodedName", testNonDatabaseContextNodeContainsUrlEncodedName),
        ("testDatabaseNodeDoesNotContainUrlEncodedName", testDatabaseNodeDoesNotContainUrlEncodedName),
    ]

    func testNonDatabaseContextNodeContainsUrlEncodedName() throws {
        XCTFail()
    }
    
    func testDatabaseNodeDoesNotContainUrlEncodedName() throws {
        XCTFail()
    }
//
//    func setupDatabase(preparations: [Preparation.Type]) {
//        let database = Database(MemoryDriver())
//        BlogPost.database = database
//        let printConsole = PrintConsole()
//        let prepare = Prepare(console: printConsole, preparations: preparations, database: database)
//        do {
//            try prepare.run(arguments: [])
//        }
//        catch {
//            XCTFail("failed to prepapre DB")
//        }
//    }
//    
}
