//
//  TreeTests.swift
//  NinetyNineSwiftProblemsTests
//
//  Created by Jacob Relkin on 12/14/18.
//  Copyright © 2018 Jacob Relkin. All rights reserved.
//

import XCTest

@testable import NinetyNineSwiftProblems

class TreeTests: XCTestCase {
    func testIsCompletelyBalanced() {
        let balancedTrees = [
            Tree(1, Tree(2, Tree(3), Tree(4)), Tree(5, Tree(6), Tree(7))),
            Tree(1, Tree(2), Tree(3)),
            Tree(1, Tree(2), Tree(3, Tree(4)))
        ]
        
        balancedTrees.forEach { tree in
            XCTAssertTrue(tree.isCompletelyBalanced())
        }
        
        XCTAssertEqual(Tree(1, Tree(2), Tree(3, Tree(4))).height, 3)
        XCTAssertFalse(Tree(1, Tree(2, Tree(3, Tree(4)))).isCompletelyBalanced())
    }
    
    func testHeight() {
        XCTAssertEqual(Tree(1, Tree(2, Tree(3)), Tree(4, Tree(5, Tree(6)))).height, 4)
    }
    
    func testBalancedTreeGeneration() {
        let balancedTrees = Tree.makeBalancedTrees(nodes: 4, value: "x")!
        let expected = List(
            Tree("x", Tree("x"), Tree("x", nil, Tree("x"))),
            Tree("x", Tree("x"), Tree("x", Tree("x"), nil)),
            Tree("x", Tree("x", nil, Tree("x")), Tree("x")),
            Tree("x", Tree("x", Tree("x"), nil), Tree("x"))
        )!
        
        XCTAssertEqual(balancedTrees.length, expected.length)
        XCTAssertTrue(balancedTrees.allSatisfy(expected.contains))
    }
}
