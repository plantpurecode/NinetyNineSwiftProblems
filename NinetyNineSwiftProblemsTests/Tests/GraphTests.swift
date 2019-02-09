//
//  GraphTests.swift
//  NinetyNineSwiftProblemsTests
//
//  Created by Jacob Relkin on 2/5/19.
//  Copyright © 2019 Jacob Relkin. All rights reserved.
//

import XCTest

@testable import NinetyNineSwiftProblems

class GraphTests : XCTestCase {
    func testGraphTermInitialization() {
        let graph = Graph<String, Int>(
            nodes: List("b", "c", "d", "f", "g", "h", "k")!,
            edges: List(("b", "c"), ("b", "f"), ("c", "f"), ("f", "k"), ("g", "h"), ("c", "f"), ("h", "g"), ("f", "b"))!
        )

        let expectedNodeValues = ["b", "c", "d", "f", "g", "h", "k"]
        let expectedEdges = [
            (from: "b", to: "c"),
            (from: "b", to: "f"),
            (from: "c", to: "f"),
            (from: "f", to: "k"),
            (from: "g", to: "h"),
        ].map { (from: $0.from, to: $0.to, value: 0) }

        let nodeValues = graph.nodes!.values.map { $0.value }
        let edgeDataTuples = graph.edges!.map({ (from: $0.from.value, to: $0.to.value, value: $0.value) })

        XCTAssertEqual(nodeValues, expectedNodeValues)
        XCTAssertEqual(expectedEdges.count, edgeDataTuples.count)

        zip(expectedEdges, edgeDataTuples).forEach { tuple in
            let (expectedEdgeTuple, edge) = tuple

            XCTAssertEqual(edge.from, expectedEdgeTuple.from)
            XCTAssertEqual(edge.to, expectedEdgeTuple.to)
            XCTAssertEqual(edge.value, expectedEdgeTuple.value)
        }
    }

    func testDigraphTermInitialization() {
        let graph = Digraph<String, Int>(
            nodes: List("b", "c", "d", "f", "g", "h", "k")!,
            edges: List(("b", "c"), ("c", "b"), ("f", "b"), ("b", "f"), ("b", "f"), ("c", "f"), ("f", "k"), ("g", "h"), ("f", "b"))!
        )

        let expectedNodeValues = ["b", "c", "d", "f", "g", "h", "k"]
        let expectedEdges = [
            (from: "b", to: "c"),
            (from: "c", to: "b"),
            (from: "f", to: "b"),
            (from: "b", to: "f"),
            (from: "c", to: "f"),
            (from: "f", to: "k"),
            (from: "g", to: "h")
        ].map { (from: $0.from, to: $0.to, value: 0) }

        let nodeValues = graph.nodes!.values.map { $0.value }
        let edgeDataTuples = graph.edges!.map({ (from: $0.from.value, to: $0.to.value, value: $0.value) })

        XCTAssertEqual(nodeValues, expectedNodeValues)
        XCTAssertEqual(expectedEdges.count, edgeDataTuples.count)

        zip(expectedEdges, edgeDataTuples).forEach { tuple in
            let (expectedEdgeTuple, edge) = tuple

            XCTAssertEqual(edge.from, expectedEdgeTuple.from)
            XCTAssertEqual(edge.to, expectedEdgeTuple.to)
            XCTAssertEqual(edge.value, expectedEdgeTuple.value)
        }
    }
}
