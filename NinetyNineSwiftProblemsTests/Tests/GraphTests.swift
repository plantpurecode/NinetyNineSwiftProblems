//
//  GraphTests.swift
//  NinetyNineSwiftProblemsTests
//
//  Created by Jacob Relkin on 2/5/19.
//  Copyright © 2019 Jacob Relkin. All rights reserved.
//

import XCTest

@testable import NinetyNineSwiftProblems

struct TestGraphEdge<T> {
    let from: String
    let to: String
    let label: T

    init(from: String, to: String, label: T) {
        self.from = from
        self.to = to
        self.label = label
    }
}

class GraphTests : XCTestCase {
    private func _testGraph<T : Equatable>(_ graph: Graph<String, T>, nodes: [String], edges: [TestGraphEdge<T>]) {
        let nodeValues = graph.nodes!.values.map { $0.value }
        let edgeDataTuples = graph.edges!.map({ (from: $0.from.value, to: $0.to.value, value: $0.label) })

        XCTAssertEqual(nodeValues, nodes)
        XCTAssertEqual(edges.count, edgeDataTuples.count)

        zip(edges, edgeDataTuples).forEach { tuple in
            let (expectedEdge, edge) = tuple

            XCTAssertEqual(edge.from, expectedEdge.from)
            XCTAssertEqual(edge.to, expectedEdge.to)
            XCTAssertEqual(edge.value, expectedEdge.label)
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
                    TestGraphEdge(from: "b", to: "c", label: 0),
                    TestGraphEdge(from: "b", to: "f", label: 0),
                    TestGraphEdge(from: "c", to: "f", label: 0),
                    TestGraphEdge(from: "f", to: "k", label: 0),
                    TestGraphEdge(from: "g", to: "h", label: 0)
            ]
        )
    }

    func testGraphTermInitializationWithLabels() {
        let graph = Graph<String, Int>(
            nodes: List("b", "c", "d", "f", "g", "h", "k")!,
            labeledEdges: List(
                ("b", "c", 1),
                ("b", "f", 2),
                ("c", "f", 3),
                ("f", "k", 4),
                ("g", "h", 5),
                ("c", "f", 6), //dupe, won't be included
                ("h", "g", 7), //already exists in opposite direction, won't be included
                ("f", "b", 8)  //already exists in opposite direction, won't be included
            )!
        )

        _testGraph(graph,
                   nodes: ["b", "c", "d", "f", "g", "h", "k"],
                   edges: [
                    TestGraphEdge(from: "b", to: "c", label: 1),
                    TestGraphEdge(from: "b", to: "f", label: 2),
                    TestGraphEdge(from: "c", to: "f", label: 3),
                    TestGraphEdge(from: "f", to: "k", label: 4),
                    TestGraphEdge(from: "g", to: "h", label: 5)
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
                    TestGraphEdge(from: "b", to: "c", label: 0),
                    TestGraphEdge(from: "c", to: "b", label: 0),
                    TestGraphEdge(from: "f", to: "b", label: 0),
                    TestGraphEdge(from: "b", to: "f", label: 0),
                    TestGraphEdge(from: "c", to: "f", label: 0),
                    TestGraphEdge(from: "f", to: "k", label: 0),
                    TestGraphEdge(from: "g", to: "h", label: 0)
            ]
        )
    }

    func testDigraphTermInitializationWithLabels() {
        let graph = Digraph<String, Int>(
            nodes: List("b", "c", "d", "f", "g", "h", "k")!,
            labeledEdges: List(
                ("b", "c", 1),
                ("b", "f", 2),
                ("c", "f", 3),
                ("f", "k", 4),
                ("g", "h", 5),
                ("h", "g", 6),
                ("f", "b", 7),
                ("c", "f", -1) //dupe, won't be included
            )!
        )

        _testGraph(graph,
                   nodes: ["b", "c", "d", "f", "g", "h", "k"],
                   edges: [
                    TestGraphEdge(from: "b", to: "c", label: 1),
                    TestGraphEdge(from: "b", to: "f", label: 2),
                    TestGraphEdge(from: "c", to: "f", label: 3),
                    TestGraphEdge(from: "f", to: "k", label: 4),
                    TestGraphEdge(from: "g", to: "h", label: 5),
                    TestGraphEdge(from: "h", to: "g", label: 6),
                    TestGraphEdge(from: "f", to: "b", label: 7)
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
                    TestGraphEdge(from: "b", to: "c", label: 0),
                    TestGraphEdge(from: "b", to: "f", label: 0),
                    TestGraphEdge(from: "c", to: "f", label: 0),
                    TestGraphEdge(from: "f", to: "k", label: 0),
                    TestGraphEdge(from: "g", to: "h", label: 0)
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
                    TestGraphEdge(from: "b", to: "c", label: 0),
                    TestGraphEdge(from: "b", to: "f", label: 0),
                    TestGraphEdge(from: "c", to: "b", label: 0),
                    TestGraphEdge(from: "c", to: "f", label: 0),
                    TestGraphEdge(from: "f", to: "b", label: 0),
                    TestGraphEdge(from: "f", to: "c", label: 0),
                    TestGraphEdge(from: "f", to: "k", label: 0),
                    TestGraphEdge(from: "g", to: "h", label: 0),
                    TestGraphEdge(from: "h", to: "g", label: 0),
                    TestGraphEdge(from: "k", to: "f", label: 0)
            ]
        )
    }

    func testGraphAdjacencyListInitializationWithLabels() {
        let graph = Graph<String, Int>(adjacentLabeledList: List(
            ("b", List(("c", 1), ("f", 2))),
            ("c", List(("b", 3), ("f", 4))),
            ("d", nil),
            ("f", List(("b", 5), ("c", 6), ("k", 7))),
            ("g", List(("h", 8))),
            ("h", List(("g", 9))),
            ("k", List(("f", 10)))
        )!)

        _testGraph(graph,
                   nodes: ["b", "c", "d", "f", "g", "h", "k"],
                   edges: [
                    TestGraphEdge(from: "b", to: "c", label: 1),
                    TestGraphEdge(from: "b", to: "f", label: 2),
                    TestGraphEdge(from: "c", to: "f", label: 4),
                    TestGraphEdge(from: "f", to: "k", label: 7),
                    TestGraphEdge(from: "g", to: "h", label: 8)
            ]
        )
    }

    func testDigraphAdjacencyListInitializationWithLabels() {
        let graph = Digraph<String, Int>(adjacentLabeledList: List(
            ("b", List(("c", 1), ("f", 2))),
            ("c", List(("b", 3), ("f", 4))),
            ("d", nil),
            ("f", List(("b", 5), ("c", 6), ("k", 7))),
            ("g", List(("h", 8))),
            ("h", List(("g", 9))),
            ("k", List(("f", 10)))
        )!)

        _testGraph(graph,
                   nodes: ["b", "c", "d", "f", "g", "h", "k"],
                   edges: [
                    TestGraphEdge(from: "b", to: "c", label: 1),
                    TestGraphEdge(from: "b", to: "f", label: 2),
                    TestGraphEdge(from: "c", to: "b", label: 3),
                    TestGraphEdge(from: "c", to: "f", label: 4),
                    TestGraphEdge(from: "f", to: "b", label: 5),
                    TestGraphEdge(from: "f", to: "c", label: 6),
                    TestGraphEdge(from: "f", to: "k", label: 7),
                    TestGraphEdge(from: "g", to: "h", label: 8),
                    TestGraphEdge(from: "h", to: "g", label: 9),
                    TestGraphEdge(from: "k", to: "f", label: 10)
            ]
        )
    }

    func testGraphHumanFriendlyTermInitialization() {
        var graph = Graph(string: "[b>c, f>c, g>h, f>b, k>f, h>g, g>h]")

        // Try to initialize a Graph using Digraph separator.. No go.
        XCTAssertNil(graph)

        // Try to initialize a Graph without square brackets.. No go.
        graph = Graph(string: "xx")
        XCTAssertNil(graph)

        graph = Graph(string: "[d]")
        XCTAssertNil(graph?.edges)
        XCTAssertEqual(graph?.nodes!.map { $0.value }, ["d"])

        // Use a string with duplicate and opposite edges to test for correctness.
        graph = Graph(string: "[b-c, f-c, g-h, d, f-b, k-f, h-g, g-h]")
        XCTAssertNotNil(graph)

        _testGraph(graph!, nodes: ["b", "c", "f", "g", "h", "d", "k"],
                   edges: [
                    TestGraphEdge(from: "b", to: "c", label: "0"),
                    TestGraphEdge(from: "f", to: "c", label: "0"),
                    TestGraphEdge(from: "g", to: "h", label: "0"),
                    TestGraphEdge(from: "f", to: "b", label: "0"),
                    TestGraphEdge(from: "k", to: "f", label: "0")
            ]
        )

        graph = Graph(string: "[b-c/1, f-c/2, g-h/3, d, f-b/4, k-f/5, h-g/6, g-h/7]")
        XCTAssertNotNil(graph)

        _testGraph(graph!, nodes: ["b", "c", "f", "g", "h", "d", "k"],
                   edges: [
                    TestGraphEdge(from: "b", to: "c", label: "1"),
                    TestGraphEdge(from: "f", to: "c", label: "2"),
                    TestGraphEdge(from: "g", to: "h", label: "3"),
                    TestGraphEdge(from: "f", to: "b", label: "4"),
                    TestGraphEdge(from: "k", to: "f", label: "5")
            ]
        )
    }

    func testDigraphHumanFriendlyTermInitialization() {
        var graph = Digraph(string: "[b-c, f-c, g-h, f-b, k-f, h-g, g-h]")

        // Try to initialize a Digraph using Graph separator.. No go.
        XCTAssertNil(graph)

        // Try to initialize a Digraph without square brackets.. No go.
        graph = Digraph(string: "xx")
        XCTAssertNil(graph)

        graph = Digraph(string: "[d]")
        XCTAssertNil(graph?.edges)
        XCTAssertEqual(graph?.nodes!.map { $0.value }, ["d"])

        graph = Digraph(string: "[b>c, f>c, g>h, d, f>b, k>f, h>g, g>h]")
        XCTAssertNotNil(graph)

        _testGraph(graph!, nodes: ["b", "c", "f", "g", "h", "d", "k"],
                   edges: [
                    TestGraphEdge(from: "b", to: "c", label: "0"),
                    TestGraphEdge(from: "f", to: "c", label: "0"),
                    TestGraphEdge(from: "g", to: "h", label: "0"),
                    TestGraphEdge(from: "f", to: "b", label: "0"),
                    TestGraphEdge(from: "k", to: "f", label: "0"),
                    TestGraphEdge(from: "h", to: "g", label: "0"),
            ]
        )

        graph = Digraph(string: "[b>c/1, f>c/2, g>h/3, d, f>b/4, k>f/5, h>g/6, g>h/7]")
        XCTAssertNotNil(graph)

        _testGraph(graph!, nodes: ["b", "c", "f", "g", "h", "d", "k"],
                   edges: [
                    TestGraphEdge(from: "b", to: "c", label: "1"),
                    TestGraphEdge(from: "f", to: "c", label: "2"),
                    TestGraphEdge(from: "g", to: "h", label: "3"),
                    TestGraphEdge(from: "f", to: "b", label: "4"),
                    TestGraphEdge(from: "k", to: "f", label: "5"),
                    TestGraphEdge(from: "h", to: "g", label: "6")
            ]
        )
    }

    func testGraphHumanFriendlyDescription() {
        let humanFriendlyString = "[b-c, f-c, g-h, f-b, k-f, h-g, g-h]"
        XCTAssertEqual(Graph(string: humanFriendlyString)?.description, "[b-c, f-c, g-h, f-b, k-f]")
        XCTAssertEqual(Digraph(string: "[d, e]")?.description, "[d, e]")
    }

    func testDigraphHumanFriendlyDescription() {
        let humanFriendlyString = "[b>c, f>c, g>h, d, f>b, k>f, h>g]"
        XCTAssertEqual(Digraph(string: humanFriendlyString)?.description, "[b>c, f>c, g>h, f>b, k>f, h>g, d]")
        XCTAssertEqual(Digraph(string: "[d, e]")?.description, "[d, e]")
    }
}
