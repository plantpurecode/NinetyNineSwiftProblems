//
//  MultiwayTreeTests.swift
//  NinetyNineSwiftProblemsTests
//
//  Created by Jacob Relkin on 1/28/19.
//  Copyright © 2019 Jacob Relkin. All rights reserved.
//

import XCTest

@testable import NinetyNineSwiftProblems

class MultiwayTreeTests: XCTestCase {
    func testInitialization() {
        let mtree = MTree("x", List([MTree("y")]))
        XCTAssertEqual(mtree.value, "x")
        XCTAssertEqual(mtree.children?[0]?.value.value, "y")
    }

    func testNodeCount() {
        let test = MTree("a", List(MTree("b", List(MTree("c")))))

        XCTAssertEqual(test.nodeCount, 3)
    }
}
