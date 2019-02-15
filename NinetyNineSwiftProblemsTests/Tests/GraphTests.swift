//
//  GraphTests.swift
//  NinetyNineSwiftProblemsTests
//
//  Created by Jacob Relkin on 2/5/19.
//  Copyright © 2019 Jacob Relkin. All rights reserved.
//

import XCTest

@testable import NinetyNineSwiftProblems

struct TestGraphEdge<T, U : Equatable> {
    let from: T
    let to: T
    let label: U

    init(from: T, to: T, label: U) {
        self.from = from
        self.to = to
        self.label = label
    }

    func toTuple() -> (from: T, to: T, label: U) {
        return (from: self.from, to: self.to, label: self.label)
    }
}

struct TestGraphData<T : CustomStringConvertible & Equatable, U : Equatable> {
    typealias EdgeTuple = (from: T, to: T, label: U)
    typealias EdgeClosure = () -> [EdgeTuple]
    typealias NodeClosure = () -> [T]

    let edges: EdgeClosure
    let nodes: NodeClosure

    let expectedNodes: [T]
    let expectedEdges: [TestGraphEdge<T, U>]

    init(graph: Graph<T, U>,
         edges edgeClosure: EdgeClosure? = nil,
         nodes nodeClosure: NodeClosure? = nil,
         expectedNodes: [T],
         expectedEdges: [TestGraphEdge<T, U>]) {
        self.edges = edgeClosure ?? {
            graph.edges?.map { (from: $0.from.value, to: $0.to.value, label: $0.label) } ?? []
        }

        self.nodes = nodeClosure ?? {
            graph.nodes?.map { $0.value } ?? []
        }

        self.expectedNodes = expectedNodes
        self.expectedEdges = expectedEdges
    }

    func runAssertions(file: StaticString = #file, line: UInt = #line) {
        let assertionTuple = (edges: edges(), expectedEdges: expectedEdges.map { $0.toTuple() })

        XCTAssertEqual(nodes(), expectedNodes, file: file, line: line)
        XCTAssertEqual(assertionTuple.edges.count, assertionTuple.expectedEdges.count, file: file, line: line)

        zip(assertionTuple.edges, assertionTuple.expectedEdges).forEach { tuple in
            let (edge, expectedEdge) = tuple

            XCTAssertEqual(edge.from, expectedEdge.from, file: file, line: line)
            XCTAssertEqual(edge.to, expectedEdge.to, file: file, line: line)
            XCTAssertEqual(edge.label, expectedEdge.label, file: file, line: line)
        }
    }
}

class GraphTests : XCTestCase {
    func _testGraph<T:CustomStringConvertible & Equatable, U:Equatable>(_ graph: Graph<T, U>, nodes: [T], edges:[TestGraphEdge<T, U>], file: StaticString = #file, line: UInt = #line)  {
        let data = TestGraphData(graph: graph, expectedNodes: nodes, expectedEdges: edges)
        data.runAssertions(file: file, line: line)
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

    func testGraphToTermForm() {
        let humanFriendlyString = "[b-c/1, f-c/2, g-h/3, f-b/4, k-f/5, h-g/6, g-h/7]"

        let graphOfSingleNode = Graph(string: "[b]")
        XCTAssertEqual(graphOfSingleNode?.toTermForm().0.values, ["b"])
        XCTAssertNil(graphOfSingleNode?.toTermForm().1)

        let graph = Graph(string: humanFriendlyString)!
        let (nodes, edges) = graph.toTermForm()

        let expectedEdges = [
            ("b", "c", "1"),
            ("f", "c", "2"),
            ("g", "h", "3"),
            ("f", "b", "4"),
            ("k", "f", "5")
        ].map {
            TestGraphEdge(from: $0.0, to: $0.1, label: $0.2)
        }

        let edgeGetter = { edges!.values.map { (from: $0.0, to: $0.1, label: $0.2) } }
        let data = TestGraphData(graph: graph,
                                 edges: edgeGetter,
                                 nodes: { nodes.values },
                                 expectedNodes: ["b", "c", "f", "g", "h", "k"],
                                 expectedEdges: expectedEdges)
        data.runAssertions()
    }

    func testDigraphToTermForm() {
        let humanFriendlyString = "[b>c/1, f>c/2, g>h/3, f>b/4, k>f/5, h>g/6, g>h/7]"

        let graphOfSingleNode = Digraph(string: "[b]")
        XCTAssertEqual(graphOfSingleNode?.toTermForm().0.values, ["b"])
        XCTAssertNil(graphOfSingleNode?.toTermForm().1)

        let graph = Digraph(string: humanFriendlyString)!
        let (nodes, edges) = graph.toTermForm()

        let expectedEdges = [
            ("b", "c", "1"),
            ("f", "c", "2"),
            ("g", "h", "3"),
            ("f", "b", "4"),
            ("k", "f", "5"),
            ("h", "g", "6")
        ].map { TestGraphEdge(from: $0.0, to: $0.1, label: $0.2) }

        let edgeGetter = { edges!.values.map { (from: $0.0, to: $0.1, label: $0.2) } }
        let data = TestGraphData(graph: graph,
                                 edges: edgeGetter,
                                 nodes: { nodes.values },
                                 expectedNodes: ["b", "c", "f", "g", "h", "k"],
                                 expectedEdges: expectedEdges)
        data.runAssertions()
    }
}
