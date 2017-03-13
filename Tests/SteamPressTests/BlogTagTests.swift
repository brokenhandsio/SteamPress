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
        let tag = BlogTag(name: "Luke's Tatooine")
        let node = try tag.makeNode()
        XCTAssertEqual(node["url_encoded_name"], "Luke's%20Tatooine")
    }
    
    func testDatabaseNodeDoesNotContainUrlEncodedName() throws {
        let tag = BlogTag(name: "Tatooine")
        let node = try tag.makeNode(context: DatabaseContext(Database(MemoryDriver())))
        XCTAssertNil(node["url_encoded_name"])
    }

}
