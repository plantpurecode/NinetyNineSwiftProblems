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
        let mtree = MTree("x", List(MTree("y")))
        XCTAssertEqual(mtree.value, "x")
        XCTAssertEqual(mtree.children?.value.value, "y")
    }

    func testStringBasedInitialization() {
        let mtree = MTree(string: "afg^^c^bd^e^^^")
        let testMtree = MTree("a", List(MTree("f", List(MTree("g"))), MTree("c"), MTree("b", List(MTree("d"), MTree("e")))))

        XCTAssertEqual(mtree, testMtree)
        XCTAssertEqual(MTree(string: "a"), MTree("a"))

        XCTAssertNil(MTree(string: ""))
    }

    func testNodeCount() {
        let test = MTree("a", List(MTree("b", List(MTree("c")))))

        XCTAssertEqual(test.nodeCount, 3)
    }

    func testDescription() {
        let description = "afg^^c^bd^e^^^"

        XCTAssertEqual(MTree(string: description)!.description, description)
        XCTAssertEqual(MTree("a").description, "a")
    }
    
    func testInternalPathLength() {
        let mtree = MTree(string: "afg^^c^bd^e^^^")!
        
        XCTAssertEqual(mtree.internalPathLength, 9)
        XCTAssertEqual(MTree("a").internalPathLength, 0)
    }

    func testPostOrder() {
        let mtree = MTree(string: "afg^^c^bd^e^^^")!

        XCTAssertEqual(mtree.postOrder, List("g", "f", "c", "d", "e", "b", "a"))
    }

    func testLispyRepresentation() {
        let mtree = MTree("a", List(MTree("b", List(MTree("c")))))

        XCTAssertEqual(mtree.lispyRepresentation, "(a (b c))")
        XCTAssertEqual(MTree("a").lispyRepresentation, "a")
    }

    func testLispyRepresentationInitialization() {
        let lispyRepresentation = "(a (b c))"
        let mtree = MTree(fromLispyRepresentation: lispyRepresentation)!

        XCTAssertEqual(mtree, MTree("a", List(MTree("b", List(MTree("c"))))))
        XCTAssertEqual(mtree.lispyRepresentation, "(a (b c))")
        XCTAssertEqual(MTree(fromLispyRepresentation: "a")?.lispyRepresentation, "a")

        XCTAssertNil(MTree(fromLispyRepresentation: ""))
        XCTAssertNil(MTree(fromLispyRepresentation: " "))
        XCTAssertNil(MTree(fromLispyRepresentation: "("))
        XCTAssertNil(MTree(fromLispyRepresentation: "( )"))
        XCTAssertNil(MTree(fromLispyRepresentation: "( (()) )"))
    }
}
