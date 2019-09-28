//
//  CollectionExtensionTests.swift
//  NinetyNineSwiftProblemsTests
//
//  Created by Jacob Relkin on 9/28/19.
//  Copyright © 2019 Jacob Relkin. All rights reserved.
//

import XCTest

@testable import NinetyNineSwiftProblems

class CollectionExtensionTests: XCTestCase {
    func testPadding() {
        var array = [1,2,3]
        array.pad(upTo: 0, with: 1)
        XCTAssertEqual(array, [1,2,3])

        array.pad(upTo: 5, with: 1)
        XCTAssertEqual(array, [1,2,3,1,1,1,1,1])
    }

    func testBookends() {
        let (head, tail) = [1,2,3,4].bookends()!

        XCTAssertEqual(head, 1)
        XCTAssertEqual(tail, 4)

        XCTAssertNil([1].bookends())
        XCTAssertNil([].bookends())
    }

    func testSplitHeadAndTails() {
        XCTAssertNil([].splitHeadAndTails())

        let (head, tails) = [1].splitHeadAndTails()!
        XCTAssertEqual(head, 1)
        XCTAssertEqual(tails, [])

        let (head1, tails1) = [1,2,3,4].splitHeadAndTails()!
        XCTAssertEqual(head1, 1)
        XCTAssertEqual(tails1, [2,3,4])
    }

    func testAllContainedIn() {
        XCTAssertTrue([1,2,3].allContained(in: [3,1,2]))
        XCTAssertTrue([1,2,3].allContained(in: [3,1,2,4]))
        XCTAssertFalse([1,2,3,4].allContained(in: [3,1,2]))
    }

    func testAllNotContainedIn() {
        XCTAssertTrue([1,2,3].allNotContained(in: [4,5,6]))
        XCTAssertFalse([1,2,3,4].allNotContained(in: [3,1,2,5,6]))
    }

    func testRemovingAllContainedIn() {
        XCTAssertEqual([1,2,3].removingAllContained(in: [2,3]), [1])
        XCTAssertEqual([1,2,3].removingAllContained(in: [1]), [2,3])
        XCTAssertEqual([1,2,3].removingAllContained(in: [4,5,6]), [1,2,3])
    }
}
