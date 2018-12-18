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
    func testCompletelyBalanced() {
        let balancedTrees = [
            Tree(1, Tree(2, Tree(3), Tree(4)), Tree(5, Tree(6), Tree(7))),
            Tree(1, Tree(2), Tree(3)),
            Tree(1, Tree(2), Tree(3, Tree(4)))
        ]
        
        balancedTrees.forEach { tree in
            XCTAssertTrue(tree.completelyBalanced)
        }
        
        XCTAssertEqual(Tree(1, Tree(2), Tree(3, Tree(4))).height, 3)
        XCTAssertFalse(Tree(1, Tree(2, Tree(3, Tree(4)))).completelyBalanced)
    }
    
    func testHeight() {
        XCTAssertEqual(Tree(1, Tree(2, Tree(3)), Tree(4, Tree(5, Tree(6)))).height, 4)
    }
    
    func testBalancedTreeGeneration() {
        let balancedTrees = Tree.makeBalancedTrees(nodes: 4, value: "x")
        let expected = List(
            Tree("x", Tree("x"), Tree("x", nil, Tree("x"))),
            Tree("x", Tree("x"), Tree("x", Tree("x"), nil)),
            Tree("x", Tree("x", nil, Tree("x")), Tree("x")),
            Tree("x", Tree("x", Tree("x"), nil), Tree("x"))
        )!
        
        XCTAssertNotNil(balancedTrees)
        
        if let trees = balancedTrees {
            XCTAssertEqual(trees.length, expected.length)
            XCTAssertTrue(trees.allSatisfy(expected.contains))
        }
    }
    
    func testIsSymmetric() {
        let testSet = [
            Tree("a", Tree("b"), Tree("c")),
            Tree("a", Tree("b", nil, Tree("c")), Tree("d", Tree("e"), nil))
        ]
        
        let negativeTestSet = [
            Tree("a", nil, Tree("b")),
            Tree("a", Tree("b"), nil),
            Tree("a", Tree("b", nil, Tree("c")), nil)
        ]
        
        testSet.forEach { XCTAssertTrue($0.isSymmetric()) }
        negativeTestSet.forEach { XCTAssertFalse($0.isSymmetric()) }
    }
}
