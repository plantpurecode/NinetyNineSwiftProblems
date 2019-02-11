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
    private func _testGraph(_ graph: Graph<String, Int>, nodes: [String], edges e: [(from: String, to: String)]) {
        let nodeValues = graph.nodes!.values.map { $0.value }
        let edgeDataTuples = graph.edges!.map({ (from: $0.from.value, to: $0.to.value, value: $0.value) })
        let edges = e.map { (from: $0.from, to: $0.to, value: 0) }

        XCTAssertEqual(nodeValues, nodes)
        XCTAssertEqual(edges.count, edgeDataTuples.count)

        zip(edges, edgeDataTuples).forEach { tuple in
            let (expectedEdgeTuple, edge) = tuple

            XCTAssertEqual(edge.from, expectedEdgeTuple.from)
            XCTAssertEqual(edge.to, expectedEdgeTuple.to)
            XCTAssertEqual(edge.value, expectedEdgeTuple.value)
        }
    }

    func testGraphTermInitialization() {
        let graph = Graph<String, Int>(
            nodes: List("b", "c", "d", "f", "g", "h", "k")!,
            edges: List(("b", "c"), ("b", "f"), ("c", "f"), ("f", "k"), ("g", "h"), ("c", "f"), ("h", "g"), ("f", "b"))!
        )

        _testGraph(graph,
                   nodes: ["b", "c", "d", "f", "g", "h", "k"],
                   edges: [
                    (from: "b", to: "c"),
                    (from: "b", to: "f"),
                    (from: "c", to: "f"),
                    (from: "f", to: "k"),
                    (from: "g", to: "h")
            ]
        )
    }

    func testDigraphTermInitialization() {
        let graph = Digraph<String, Int>(
            nodes: List("b", "c", "d", "f", "g", "h", "k")!,
            edges: List(("b", "c"), ("c", "b"), ("f", "b"), ("b", "f"), ("b", "f"), ("c", "f"), ("f", "k"), ("g", "h"), ("f", "b"))!
        )

        _testGraph(graph,
                   nodes: ["b", "c", "d", "f", "g", "h", "k"],
                   edges: [
                    (from: "b", to: "c"),
                    (from: "c", to: "b"),
                    (from: "f", to: "b"),
                    (from: "b", to: "f"),
                    (from: "c", to: "f"),
                    (from: "f", to: "k"),
                    (from: "g", to: "h")
            ]
        )
    }

    func testGraphAdjacencyListInitialization() {
        let graph = Graph<String, Int>(adjacentList: List(
            ("b", List("c", "f")),
            ("c", List("b", "f")),
            ("d", nil),
            ("f", List("b", "c", "k")),
            ("g", List("h")),
            ("h", List("g")),
            ("k", List("f"))
        )!)

        _testGraph(graph,
                   nodes: ["b", "c", "d", "f", "g", "h", "k"],
                   edges: [
                    (from: "b", to: "c"),
                    (from: "b", to: "f"),
                    (from: "c", to: "f"),
                    (from: "f", to: "k"),
                    (from: "g", to: "h")
            ]
        )
    }

    func testDigraphAdjacencyListInitialization() {
        let graph = Digraph<String, Int>(adjacentList: List(
            ("b", List("c", "f")),
            ("c", List("b", "f")),
            ("d", nil),
            ("f", List("b", "c", "k")),
            ("g", List("h")),
            ("h", List("g")),
            ("k", List("f"))
        )!)

        _testGraph(graph,
                   nodes: ["b", "c", "d", "f", "g", "h", "k"],
                   edges: [
                    (from: "b", to: "c"),
                    (from: "b", to: "f"),
                    (from: "c", to: "b"),
                    (from: "c", to: "f"),
                    (from: "f", to: "b"),
                    (from: "f", to: "c"),
                    (from: "f", to: "k"),
                    (from: "g", to: "h"),
                    (from: "h", to: "g"),
                    (from: "k", to: "f")
            ]
        )
    }
}
