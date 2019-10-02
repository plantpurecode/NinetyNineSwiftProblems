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
        XCTAssertEqual(Tree(1).height, 1)
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

        XCTAssertNil(Tree.makeBalancedTrees(nodes: 0, value: "x"))
    }

    func testSymmetricBalancedTreeGeneration() {
        let expected = List(
            Tree("x", Tree("x", nil, Tree("x")), Tree("x", Tree("x"), nil)),
            Tree("x", Tree("x", Tree("x"), nil), Tree("x", nil, Tree("x")))
        )

        XCTAssertEqual(Tree.makeSymmetricBalancedTrees(nodes: 5, value: "x"), expected)
        XCTAssertNil(Tree.makeSymmetricBalancedTrees(nodes: 0, value: "x"))
    }

    func testSymmetric() {
        let testSet = [
            Tree("a"),
            Tree("a", Tree("b", nil, Tree("c")), Tree("d", Tree("e"))),
            Tree("a", Tree("b", Tree("c")), Tree("e", nil, Tree("f")))
        ]

        let negativeTestSet = [
            Tree("a", Tree("b", Tree("d", nil, Tree("e"))), Tree("c")),
            Tree("a", nil, Tree("b", Tree("d"))),
            Tree("a", Tree("b"), Tree("c", nil, Tree("e"))),
            Tree("a", Tree("b", nil, Tree("c", nil, Tree("d")))),
            Tree("a", Tree("b"), nil),
            Tree("a", Tree("b", nil, Tree("c")), nil)
        ]

        testSet.enumerated().forEach {
            XCTAssertTrue($0.1.symmetric, "Tree at index \($0.0) isn't symmetric!")
        }

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
        let tree = Tree(list: List(3, 2, 5, 7, 1))
        XCTAssertEqual(tree, Tree(3, Tree(2, Tree(1), nil), Tree(5, nil, Tree(7))))
    }

    func testHeightBalancedTreeGeneration() {
        let result = Tree.makeHeightBalancedTrees(height: 3, value: "x")
        XCTAssertNotNil(result)
        XCTAssertTrue(result?.values.allSatisfy { $0.heightBalanced } ?? false)

        XCTAssertNil(Tree.makeHeightBalancedTrees(height: 0, value: "a"))
    }

    func testHeightBalancedTreeGenerationReduxWithNodeCount() {
        let result = Tree.makeHeightBalancedTrees(nodes: 15, value: "x")

        guard let res = result else {
            XCTFail("Unexpectedly got a nil tree list")
            return
        }

        XCTAssertTrue(res.values.allSatisfy { $0.heightBalanced })
    }

    func testLeafCount() {
        let elements = [10, 11, 8, 1, 5, 7, 12, 6, 3, 4, 9, 2]

        XCTAssertEqual(Tree(list: List(elements)).leafCount, 5)
        XCTAssertEqual(Tree("x", Tree("x"), nil).leafCount, 1)
    }

    func testLeaves() {
        let elements = [10, 11, 8, 1, 5, 7, 12, 6, 3, 4, 9, 2]
        let tree = Tree(list: List(elements))

        XCTAssertEqual(tree.leaves, List(2, 4, 6, 9, 12))
    }

    func testInternalNodes() {
        let internalNodes = Tree("a", Tree("b"), Tree("c", Tree("d"), Tree("e"))).internalNodes

        XCTAssertEqual(internalNodes, List("a", "c"))

        let leafInternalNodes = Tree("a").internalNodes
        XCTAssertNil(leafInternalNodes)
    }

    func testNodesAtLevel() {
        let test = Tree("a", Tree("b"), Tree("c", Tree("d"), Tree("e"))).nodes(atLevel: 2)

        XCTAssertEqual(test, List("b", "c"))
        XCTAssertNil(Tree("a").nodes(atLevel: 0))
        XCTAssertNil(Tree("a").nodes(atLevel: 2))
    }

    func testMakingCompleteTrees() {
        let expected = Tree("x", Tree("x", Tree("x"), Tree("x")), Tree("x", Tree("x"), nil))
        let result = Tree.makeCompleteTree(nodes: 6, value: "x")

        XCTAssertEqual(result, expected)
        XCTAssertNil(Tree.makeCompleteTree(nodes: 0, value: "x"))
    }

    func testTreeLayout() {
        XCTAssertEqual(Tree("a", Tree("b", nil, Tree("c")), Tree("d")).layoutBinaryTree()?.description,
                       "a{x: 3, y: 1}(b{x: 1, y: 2}(,c{x: 2, y: 3}),d{x: 4, y: 2})")
        XCTAssertNil(Tree("a").layoutBinaryTree())
    }

    func testTreeLayout2() {
        XCTAssertEqual(Tree("a", Tree("b", nil, Tree("c")), Tree("d")).layoutBinaryTree2()?.description,
                       "a{x: 3, y: 1}(b{x: 1, y: 2}(,c{x: 2, y: 3}),d{x: 5, y: 2})")
        XCTAssertNil(Tree("a").layoutBinaryTree2())
    }

    func testTreeLayout3() {
        let test = Tree("a", Tree("b", nil, Tree("c")), Tree("d")).layoutBinaryTree3()
        let test2 = Tree("a", Tree("b", Tree("a"), Tree("c", nil, Tree("e"))), Tree("d")).layoutBinaryTree3()
        let test3 = Tree("a", Tree("b", Tree("a", Tree("e")), Tree("c")), Tree("d")).layoutBinaryTree3()

        XCTAssertEqual(test?.description, "a{x: 2, y: 1}(b{x: 1, y: 2}(,c{x: 2, y: 3}),d{x: 3, y: 2})")
        XCTAssertEqual(test2?.description, "a{x: 3, y: 1}(b{x: 2, y: 2}(a{x: 1, y: 3},c{x: 3, y: 3}(,e{x: 4, y: 4})),d{x: 4, y: 2})")
        XCTAssertEqual(test3?.description, "a{x: 4, y: 1}(b{x: 3, y: 2}(a{x: 2, y: 3}(e{x: 3, y: 4},),c{x: 4, y: 3}),d{x: 5, y: 2})")

        XCTAssertNil(Tree("a").layoutBinaryTree3())
    }

    func testTreeStringRepresentation() {
        let tree = Tree("a", Tree("b", Tree("d"), Tree("e")), Tree("c", nil, Tree("f", Tree("g"), nil)))

        XCTAssertEqual(tree.description, "a(b(d,e),c(,f(g,)))")
        XCTAssertEqual(Tree("a").description, "a")
        XCTAssertEqual(Tree("a", Tree("b")).description, "a(b,)")
        XCTAssertEqual(Tree("a", Tree("b"), Tree("c")).description, "a(b,c)")
    }

    func testTreeStringInitialization() {
        let string = "a(b(d,e),c(,f(g,)))"
        let tree = Tree(string: string)

        XCTAssertEqual(tree?.description, string)
    }

    func testPreOrderTraversal() {
        let tree = Tree(string: "a(b(d,e),c(,f(g,)))")!

        XCTAssertEqual(tree.preOrder, List("a", "b", "d", "e", "c", "f", "g"))
        XCTAssertEqual(Tree("a").preOrder, List("a"))
    }

    func testInOrderTraversal() {
        let tree = Tree(string: "a(b(d,e),c(,f(g,)))")!

        XCTAssertEqual(tree.inOrder, List("d", "b", "e", "a", "c", "g", "f"))
        XCTAssertEqual(Tree("a").inOrder, List("a"))
    }

    func testPostOrderTraversal() {
        let tree = Tree(string: "a(b(d,e),c(,f(g,)))")!

        XCTAssertEqual(tree.postOrder, List("d", "e", "b", "g", "f", "c", "a"))
        XCTAssertEqual(Tree("a").postOrder, List("a"))
    }

    func testPreInOrderTreeInitialization() {
        let tree = Tree(
            preOrder: List("a", "b", "d", "e", "c", "f", "g")!,
            inOrder: List("d", "b", "e", "a", "c", "g", "f")!
        )!

        XCTAssertEqual(tree.description, "a(b(d,e),c(,f(g,)))")

        let treeConstructedFromDuplicateValues = Tree(preOrder: List("a", "b", "a")!, inOrder: List("b", "a", "a")!)!
        XCTAssertEqual(treeConstructedFromDuplicateValues.description, "a(b,a)")

        XCTAssertNil(Tree(preOrder: List("k")!, inOrder: List("a")!))
    }

    func testDotStringGeneration() {
        let dotString = Tree(string: "a(b(d,e),c(,f(g,)))")!.dotString

        XCTAssertEqual(dotString, "abd..e..c.fg...")
    }

    func testDotStringInitialization() {
        let dotString = "abd..e..c.fg..."
        let characterTree = Tree(dotString: dotString)!

        XCTAssertEqual(characterTree.dotString, dotString)

        for invalidString in ["", " ", ".", "..", "..."] {
            XCTAssertNil(Tree(dotString: invalidString))
        }
    }
}

class TreeSequenceTests: XCTestCase {
    let tree = Tree(string: "a(b,c)")!
    let inOrder = ["b", "a", "c"]

    func testContains() {
        inOrder.forEach {
            XCTAssertTrue(tree.contains($0))
        }
    }

    func testDropFirst() {
        XCTAssertEqual(Array(tree.dropFirst()), ["a", "c"])
    }

    func testDropLast() {
        XCTAssertEqual(Array(tree.dropLast()), ["b", "a"])
    }

    func testElementsEqual() {
        XCTAssertTrue(tree.elementsEqual(inOrder))
    }

    func testEnumerated() {
        XCTAssertEqual(inOrder,
                       tree.enumerated().map { $0.element })
    }

    func testFilter() {
        XCTAssertEqual(tree.filter { $0 != "a" }, ["b", "c"])
    }

    func testPreOrder() {
        let iterator = tree.makeIterator(ofKind: .preOrder)
        XCTAssertEqual(iterator.elements, tree.preOrder)
    }

    func testPostOrder() {
        let iterator = tree.makeIterator(ofKind: .postOrder)
        XCTAssertEqual(iterator.elements, tree.postOrder)
    }
}
