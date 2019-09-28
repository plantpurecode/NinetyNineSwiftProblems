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
    func testCharacterAtIndex() {
        let test = "abcdef"
        test.enumerated().forEach {
            XCTAssertEqual(test.character(atIndex: $0.offset), $0.element)
        }

        XCTAssertNil("abcdef".character(atIndex: 10))
    }

    func testSubstring() {
        XCTAssertEqual("abcdef".substring(in: 0..<3), "abc")
        XCTAssertEqual("abcdef".substring(in: 3..<6), "def")
        XCTAssertNil("abcdef".substring(in: 3..<8))
        XCTAssertNil("abcdef".substring(in: -5..<5))
    }

    func testScan() {
        XCTAssertEqual("abcdef".scan(for: { (char) -> Bool in
            return char == "d"
        }), 3)

        XCTAssertNil("abcdef".scan(for: { (char) -> Bool in
            return char == "g"
        }))

        XCTAssertNil("abcdef".scan(for: { (char) -> Bool in
            return char == "a"
        }, fromIndex: 7))

    }
}
