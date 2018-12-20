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
    
    func testSymmetric() {
        let testSet = [
            Tree("a"),
            Tree("a", Tree("b"), Tree("c")),
            Tree("a", Tree("b", nil, Tree("c")), Tree("d", Tree("e"), nil)),
            Tree("a", Tree("b", Tree("c"), nil), Tree("d", nil, Tree("f")))
        ]
        
        let negativeTestSet = [
            Tree("a", Tree("b", Tree("d", nil, Tree("e"))), Tree("c")),
            Tree("a", nil, Tree("b", Tree("d"))),
            Tree("a", Tree("b"), Tree("c", nil, Tree("e"))),
            Tree("a", Tree("b", nil, Tree("c", nil, Tree("d")))),
            Tree("a", Tree("b"), nil),
            Tree("a", Tree("b", nil, Tree("c")), nil),
        ]
        
        testSet.forEach { XCTAssertTrue($0.symmetric) }
        negativeTestSet.forEach { XCTAssertFalse($0.symmetric) }
        
        XCTAssertTrue(Tree(list: List(5, 3, 18, 1, 4, 12, 21)).symmetric)
        XCTAssertFalse(Tree(list: List(3, 2, 5, 7, 4)).symmetric)
    }
    
    func testInsertion() {
        XCTAssertEqual(Tree(2, nil, Tree(3)).insert(value: 0), Tree(2, Tree(0), Tree(3)))
        XCTAssertEqual(Tree(4, Tree(2)).insert(value: 0), Tree(4, Tree(2, Tree(0))))
        XCTAssertEqual(Tree(4, Tree(3, Tree(2))).insert(value: 1), Tree(4, Tree(3, Tree(2, Tree(1)))))
        XCTAssertEqual(Tree(4, nil, Tree(5, nil, Tree(7, Tree(6)))).insert(value: 8), Tree(4, nil, Tree(5, nil, Tree(7, Tree(6), Tree(8)))))
        
        XCTAssertNotEqual(Tree(4, nil, Tree(5)).insert(value: 1), Tree(4, nil, Tree(5, Tree(1))))
    }
    
    func testListInitializer() {
        let tree = Tree(list: List(3,2,5,7,1))
        XCTAssertEqual(tree, Tree(3, Tree(2, Tree(1), nil), Tree(5, nil, Tree(7))))
    }
}
