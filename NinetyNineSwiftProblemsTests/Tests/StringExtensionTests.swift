//
//  StringExtensionTests.swift
//  NinetyNineSwiftProblemsTests
//
//  Created by Jacob Relkin on 9/29/19.
//  Copyright © 2019 Jacob Relkin. All rights reserved.
//

import XCTest

@testable import NinetyNineSwiftProblems

class StringExtensionTests: XCTestCase {
    func testSubscriptCharacter() {
        let test = "abcdef"
        XCTAssertEqual(test[0], "a")
        XCTAssertEqual(test[5], "f")
    }

    func testSubscriptingWithRange() {
        let test = "abcdef"
        XCTAssertEqual(test[0..<2], "ab")
        XCTAssertEqual(test[3..<6], "def")
    }

    func testSubscriptingWithClosedRange() {
        let test = "abcdef"
        XCTAssertEqual(test[0...4], "abcde")
        XCTAssertEqual(test[3...5], "def")
    }

    func testScan() {
        XCTAssertEqual("abcdef".scan(for: { char -> Bool in
            char == "d"
        }), 3)

        XCTAssertNil("abcdef".scan(for: { char -> Bool in
            char == "g"
        }))

        XCTAssertNil("abcdef".scan(for: { char -> Bool in
            char == "a"
        }, fromIndex: 7))

    }
}
