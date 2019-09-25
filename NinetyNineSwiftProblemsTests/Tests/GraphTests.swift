//
//  GraphTests.swift
//  NinetyNineSwiftProblemsTests
//
//  Created by Jacob Relkin on 2/5/19.
//  Copyright © 2019 Jacob Relkin. All rights reserved.
//

import XCTest

@testable import NinetyNineSwiftProblems

struct TestGraphData<T : GraphValueTypeConstraint, U : GraphLabelTypeConstraint & Equatable> {
    typealias EdgeTuple = (from: T, to: T, label: U?)
    typealias EdgeClosure = () -> [EdgeTuple]
    typealias NodeClosure = () -> [T]

    struct Edge {
        let from: T
        let to: T
        let label: U?

        init(from: T, to: T, label: U? = nil) {
            self.from = from
            self.to = to
            self.label = label
        }

        func toTuple() -> EdgeTuple {
            return (from: self.from, to: self.to, label: self.label)
        }
    }

    let edges: EdgeClosure
    let nodes: NodeClosure

    let expectedNodes: [T]
    let expectedEdges: [Edge]

    init(graph: Graph<T, U>,
         edges edgeClosure: EdgeClosure? = nil,
         nodes nodeClosure: NodeClosure? = nil,
         expectedNodes: [T],
         expectedEdges: [Edge]) {
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

typealias StringGraph = Graph<String, String>
typealias StringDigraph = Digraph<String, String>

class GraphTests : XCTestCase {
    func _testGraph<T: GraphValueTypeConstraint, U: GraphLabelTypeConstraint>(_ graph: Graph<T, U>, nodes: [T], edges:[TestGraphData<T, U>.Edge], file: StaticString = #file, line: UInt = #line)  {
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
                    TestGraphData.Edge(from: "b", to: "c"),
                    TestGraphData.Edge(from: "b", to: "f"),
                    TestGraphData.Edge(from: "c", to: "f"),
                    TestGraphData.Edge(from: "f", to: "k"),
                    TestGraphData.Edge(from: "g", to: "h")
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
                    TestGraphData.Edge(from: "b", to: "c", label: 1),
                    TestGraphData.Edge(from: "b", to: "f", label: 2),
                    TestGraphData.Edge(from: "c", to: "f", label: 3),
                    TestGraphData.Edge(from: "f", to: "k", label: 4),
                    TestGraphData.Edge(from: "g", to: "h", label: 5)
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
                    TestGraphData.Edge(from: "b", to: "c"),
                    TestGraphData.Edge(from: "c", to: "b"),
                    TestGraphData.Edge(from: "f", to: "b"),
                    TestGraphData.Edge(from: "b", to: "f"),
                    TestGraphData.Edge(from: "c", to: "f"),
                    TestGraphData.Edge(from: "f", to: "k"),
                    TestGraphData.Edge(from: "g", to: "h")
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
                    TestGraphData.Edge(from: "b", to: "c", label: 1),
                    TestGraphData.Edge(from: "b", to: "f", label: 2),
                    TestGraphData.Edge(from: "c", to: "f", label: 3),
                    TestGraphData.Edge(from: "f", to: "k", label: 4),
                    TestGraphData.Edge(from: "g", to: "h", label: 5),
                    TestGraphData.Edge(from: "h", to: "g", label: 6),
                    TestGraphData.Edge(from: "f", to: "b", label: 7)
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
                    TestGraphData.Edge(from: "b", to: "c"),
                    TestGraphData.Edge(from: "b", to: "f"),
                    TestGraphData.Edge(from: "c", to: "f"),
                    TestGraphData.Edge(from: "f", to: "k"),
                    TestGraphData.Edge(from: "g", to: "h")
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
                    TestGraphData.Edge(from: "b", to: "c"),
                    TestGraphData.Edge(from: "b", to: "f"),
                    TestGraphData.Edge(from: "c", to: "b"),
                    TestGraphData.Edge(from: "c", to: "f"),
                    TestGraphData.Edge(from: "f", to: "b"),
                    TestGraphData.Edge(from: "f", to: "c"),
                    TestGraphData.Edge(from: "f", to: "k"),
                    TestGraphData.Edge(from: "g", to: "h"),
                    TestGraphData.Edge(from: "h", to: "g"),
                    TestGraphData.Edge(from: "k", to: "f")
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
                    TestGraphData.Edge(from: "b", to: "c", label: 1),
                    TestGraphData.Edge(from: "b", to: "f", label: 2),
                    TestGraphData.Edge(from: "c", to: "f", label: 4),
                    TestGraphData.Edge(from: "f", to: "k", label: 7),
                    TestGraphData.Edge(from: "g", to: "h", label: 8)
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
                    TestGraphData.Edge(from: "b", to: "c", label: 1),
                    TestGraphData.Edge(from: "b", to: "f", label: 2),
                    TestGraphData.Edge(from: "c", to: "b", label: 3),
                    TestGraphData.Edge(from: "c", to: "f", label: 4),
                    TestGraphData.Edge(from: "f", to: "b", label: 5),
                    TestGraphData.Edge(from: "f", to: "c", label: 6),
                    TestGraphData.Edge(from: "f", to: "k", label: 7),
                    TestGraphData.Edge(from: "g", to: "h", label: 8),
                    TestGraphData.Edge(from: "h", to: "g", label: 9),
                    TestGraphData.Edge(from: "k", to: "f", label: 10)
            ]
        )
    }

    func testGraphHumanFriendlyTermInitialization() {
        var graph = StringGraph(string: "[b>c, f>c, g>h, f>b, k>f, h>g, g>h]")

        // Try to initialize a Graph using Digraph separator.. No go.
        XCTAssertNil(graph)

        // Try to initialize a Graph without square brackets.. No go.
        graph = StringGraph(string: "xx")
        XCTAssertNil(graph)

        // Try to initialize a Graph with invalid syntax.. No go.
        graph = StringGraph(string: "[b-c-d, g-c]")
        XCTAssertNil(graph)

        graph = StringGraph(string: "[d]")
        XCTAssertNil(graph?.edges)
        XCTAssertEqual(graph?.nodes!.map { $0.value }, ["d"])

        // Use a string with duplicate and opposite edges to test for correctness.
        graph = StringGraph(string: "[b-c, f-c, g-h, d, f-b, k-f, h-g, g-h]")
        XCTAssertNotNil(graph)

        _testGraph(graph!, nodes: ["b", "c", "f", "g", "h", "d", "k"],
                   edges: [
                    TestGraphData.Edge(from: "b", to: "c"),
                    TestGraphData.Edge(from: "f", to: "c"),
                    TestGraphData.Edge(from: "g", to: "h"),
                    TestGraphData.Edge(from: "f", to: "b"),
                    TestGraphData.Edge(from: "k", to: "f")
            ]
        )

        graph = StringGraph(string: "[b-c/1, f-c/2, g-h/3, d, f-b/4, k-f/5, h-g/6, g-h/7]")
        XCTAssertNotNil(graph)

        _testGraph(graph!, nodes: ["b", "c", "f", "g", "h", "d", "k"],
                   edges: [
                    TestGraphData.Edge(from: "b", to: "c", label: "1"),
                    TestGraphData.Edge(from: "f", to: "c", label: "2"),
                    TestGraphData.Edge(from: "g", to: "h", label: "3"),
                    TestGraphData.Edge(from: "f", to: "b", label: "4"),
                    TestGraphData.Edge(from: "k", to: "f", label: "5")
            ]
        )
    }

    func testDigraphHumanFriendlyTermInitialization() {
        var graph = StringDigraph(string: "[b-c, f-c, g-h, f-b, k-f, h-g, g-h]")

        // Try to initialize a Digraph using Graph separator.. No go.
        XCTAssertNil(graph)

        // Try to initialize a Digraph without square brackets.. No go.
        graph = StringDigraph(string: "xx")
        XCTAssertNil(graph)

        // Try to initialize a Digraph with invalid syntax.. No go.
        graph = StringDigraph(string: "[b>c>d, g>c]")
        XCTAssertNil(graph)

        graph = StringDigraph(string: "[d]")
        XCTAssertNil(graph?.edges)
        XCTAssertEqual(graph?.nodes!.map { $0.value }, ["d"])

        graph = StringDigraph(string: "[b>c, f>c, g>h, d, f>b, k>f, h>g, g>h]")
        XCTAssertNotNil(graph)

        _testGraph(graph!, nodes: ["b", "c", "f", "g", "h", "d", "k"],
                   edges: [
                    TestGraphData.Edge(from: "b", to: "c"),
                    TestGraphData.Edge(from: "f", to: "c"),
                    TestGraphData.Edge(from: "g", to: "h"),
                    TestGraphData.Edge(from: "f", to: "b"),
                    TestGraphData.Edge(from: "k", to: "f"),
                    TestGraphData.Edge(from: "h", to: "g")
            ]
        )

        let intLabeledGraph = Digraph<String, Int>(string: "[b>c/1, f>c/2, g>h/3, d, f>b/4, k>f/5, h>g/6, g>h/7]")
        XCTAssertNotNil(intLabeledGraph)

        _testGraph(intLabeledGraph!, nodes: ["b", "c", "f", "g", "h", "d", "k"],
                   edges: [
                    TestGraphData.Edge(from: "b", to: "c", label: 1),
                    TestGraphData.Edge(from: "f", to: "c", label: 2),
                    TestGraphData.Edge(from: "g", to: "h", label: 3),
                    TestGraphData.Edge(from: "f", to: "b", label: 4),
                    TestGraphData.Edge(from: "k", to: "f", label: 5),
                    TestGraphData.Edge(from: "h", to: "g", label: 6)
            ]
        )
    }

    func testGraphHumanFriendlyDescription() {
        let humanFriendlyString = "[b-c, f-c, g-h, f-b, k-f, h-g, g-h]"
        XCTAssertEqual(StringGraph(string: humanFriendlyString)?.description, "[b-c, f-c, g-h, f-b, k-f]")
        XCTAssertEqual(StringGraph(string: "[a]")?.description, "[a]")
        XCTAssertEqual(StringDigraph(string: "[d, e]")?.description, "[d, e]")
    }

    func testDigraphHumanFriendlyDescription() {
        let humanFriendlyString = "[b>c, f>c, g>h, d, f>b, k>f, h>g]"
        XCTAssertEqual(StringDigraph(string: humanFriendlyString)?.description, "[b>c, f>c, g>h, f>b, k>f, h>g, d]")
        XCTAssertEqual(StringDigraph(string: "[a]")?.description, "[a]")
        XCTAssertEqual(StringDigraph(string: "[d, e]")?.description, "[d, e]")
    }

    func testGraphToTermForm() {
        let humanFriendlyString = "[b-c/1, f-c/2, g-h/3, f-b/4, k-f/5, h-g/6, g-h/7]"

        let graphOfSingleNode = StringGraph(string: "[b]")
        XCTAssertEqual(graphOfSingleNode?.toTermForm().0.values, ["b"])
        XCTAssertNil(graphOfSingleNode?.toTermForm().1)

        let graph = Graph<String, Int>(string: humanFriendlyString)!
        let (nodes, edges) = graph.toTermForm()

        let expectedEdges = [
            ("b", "c", 1),
            ("f", "c", 2),
            ("g", "h", 3),
            ("f", "b", 4),
            ("k", "f", 5)
        ].map {
            TestGraphData.Edge(from: $0.0, to: $0.1, label: $0.2)
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

        let graphOfSingleNode = StringDigraph(string: "[b]")
        XCTAssertEqual(graphOfSingleNode?.toTermForm().0.values, ["b"])
        XCTAssertNil(graphOfSingleNode?.toTermForm().1)

        let graph = Digraph<String, Int>(string: humanFriendlyString)!
        let (nodes, edges) = graph.toTermForm()

        let expectedEdges = [
            ("b", "c", 1),
            ("f", "c", 2),
            ("g", "h", 3),
            ("f", "b", 4),
            ("k", "f", 5),
            ("h", "g", 6)
        ].map { TestGraphData.Edge(from: $0.0, to: $0.1, label: $0.2) }

        let edgeGetter = { edges!.values.map { (from: $0.0, to: $0.1, label: $0.2) } }
        let data = TestGraphData(graph: graph,
                                 edges: edgeGetter,
                                 nodes: { nodes.values },
                                 expectedNodes: ["b", "c", "f", "g", "h", "k"],
                                 expectedEdges: expectedEdges)
        data.runAssertions()
    }

    func testGraphToAdjacentForm() {
        let expectedResult:List<(String, List<(String, Int?)>?)> = [
            ("p", List<(String, Int?)>(("q", 9), ("m", 5))),
            ("m", List<(String, Int?)>(("q", 7))),
            ("k", nil),
            ("q", nil)
        ].toList()!

        let result = Graph<String, Int>(string: "[p-q/9, m-q/7, k, p-m/5]")!.toAdjacentForm()
        XCTAssertEqual(expectedResult.length, result.length)

        for (er, r) in zip(expectedResult, result) {
            XCTAssertEqual(er.0, r.0)
            XCTAssertEqual(er.1?.values.first?.0, r.1?.values.first?.0)
            XCTAssertEqual(er.1?.values.first?.1, r.1?.values.first?.1)
            XCTAssertEqual(er.1?.values.last?.0, r.1?.values.last?.0)
            XCTAssertEqual(er.1?.values.last?.1, r.1?.values.last?.1)
        }
    }

    func testDigraphToAdjacentForm() {
        let expectedResult:List<(String, List<(String, Int?)>?)> = [
            ("p", List<(String, Int?)>(("q", 9), ("m", 5))),
            ("m", List<(String, Int?)>(("q", 7))),
            ("k", nil),
            ("q", nil)
        ].toList()!

        let result = Digraph<String, Int>(string: "[p>q/9, m>q/7, k, p>m/5]")!.toAdjacentForm()
        XCTAssertEqual(expectedResult.length, result.length)

        for (er, r) in zip(expectedResult, result) {
            XCTAssertEqual(er.0, r.0)
            XCTAssertEqual(er.1?.values.first?.0, r.1?.values.first?.0)
            XCTAssertEqual(er.1?.values.first?.1, r.1?.values.first?.1)
            XCTAssertEqual(er.1?.values.last?.0, r.1?.values.last?.0)
            XCTAssertEqual(er.1?.values.last?.1, r.1?.values.last?.1)
        }
    }

    func testOrphanNodes() {
        guard var graph:Graph<String, Int> = Digraph<String, Int>(string: "[p>q/9, m>q/7, k, p>m/5]") else {
            XCTFail("Expected non-nil graph")
            return
        }

        XCTAssertEqual(graph.orphanNodes?.values.map { $0.value }, ["k", "q"])

        graph = Graph<String, Int>(string: "[p-q, m-q, r, s]")!
        XCTAssertEqual(graph.orphanNodes?.values.map { $0.value }, ["s", "r", "q"])
    }

    func testCustomGraphValueType() {
        let graph = Graph<TestGraphValue, String>.init(string: "[a-b, c-d, e]")
        XCTAssertNotNil(graph)

        let expectedEdges = [
            ("a", "b"),
            ("c", "d")
        ].map {
            TestGraphData<TestGraphValue, String>.Edge(from: TestGraphValue($0.0)!,
                                                       to: TestGraphValue($0.1)!)
        }

        let data = TestGraphData(graph: graph!,
                                 expectedNodes: [TestGraphValue("a"),
                                                 TestGraphValue("b"),
                                                 TestGraphValue("c"),
                                                 TestGraphValue("d"),
                                                 TestGraphValue("e")].compactMap { $0 },
                                 expectedEdges: expectedEdges)
        data.runAssertions()
    }

    func testCustomDigraphValueType() {
        let graph = Digraph<TestGraphValue, String>.init(string: "[a>b, c>d, d>c, b>a, e]")
        XCTAssertNotNil(graph)

        let expectedEdges = [
            ("a", "b"),
            ("c", "d"),
            ("d", "c"),
            ("b", "a")
        ].map {
            TestGraphData<TestGraphValue, String>.Edge(from: TestGraphValue($0.0)!,
                                                       to: TestGraphValue($0.1)!)
        }

        let data = TestGraphData(graph: graph!,
                                 expectedNodes: [TestGraphValue("a"),
                                                 TestGraphValue("b"),
                                                 TestGraphValue("c"),
                                                 TestGraphValue("d"),
                                                 TestGraphValue("e")].compactMap { $0 },
                                 expectedEdges: expectedEdges)
        data.runAssertions()
    }

    func testGraphFindPaths() {
        let graph = StringGraph(string: "[p-q/9, m-q/7, k, p-m/5, p-x, x-y, y-q, q-p]")
        let paths = graph?.findPaths(from: "p", to: "q")

        XCTAssertEqual(paths?.values.map { $0.values }, [["p", "q"], ["p", "m", "q"], ["p", "x", "y", "q"]])

        let invalidPaths = [graph?.findPaths(from: "p", to: "k"), graph?.findPaths(from: "k", to: "m")]
        invalidPaths.forEach { XCTAssertNil($0) }
    }

    func testDigraphFindPaths() {
        let graph = StringDigraph(string: "[p>q/9, m>q/7, k, p>m/5, p>x, x>y, y>q, q>p]") // Purposely add an q>p edge to test acyclic node filtration.
        let paths = graph?.findPaths(from: "p", to: "q")

        XCTAssertEqual(paths?.values.map { $0.values }, [["p", "q"], ["p", "m", "q"], ["p", "x", "y", "q"]])

        let invalidPaths = [graph?.findPaths(from: "p", to: "k"), graph?.findPaths(from: "k", to: "m")]
        invalidPaths.forEach { XCTAssertNil($0) }
    }

    func testGraphFindCycles() {
        let graph = StringGraph(string: "[b-c, f-c, g-h, d, f-b, k-f, h-g]")!
        let cycles = graph.findCycles(from: "f")

        XCTAssertNotNil(cycles)
        XCTAssertEqualCollectionIgnoringOrder(cycles!.values.compactMap { $0.values }, [
            ["f", "c", "b", "f"],
            ["f", "b", "c", "f"]
        ])

        let uncycledGraph = StringGraph(string: "[b-c, f-c, g-h, d, k-f]")!
        XCTAssertNil(uncycledGraph.findCycles(from: "f"))
        XCTAssertNil(uncycledGraph.findCycles(from: "i"))
    }

    func testDigraphFindCycles() {
        let cycledGraph = StringDigraph(string: "[b>c, f>c, g>h, d, f>b, k>f, h>g, f>k, c>f, k>b]")!
        let cycles = cycledGraph.findCycles(from: "f")

        XCTAssertNotNil(cycles)
        XCTAssertEqualCollectionIgnoringOrder(cycles!.values.compactMap { $0.values }, [
            ["f", "k", "b", "c", "f"],
            ["f", "b", "c", "f"]
        ])

        let uncycledGraph = StringDigraph(string: "[b>c, f>c, g>h, d, f>b, k>f, h>g, f>k]")!
        XCTAssertNil(uncycledGraph.findCycles(from: "f"))
        XCTAssertNil(uncycledGraph.findCycles(from: "i"))
    }

    func testDegreeForNode() {
        let graph = StringGraph(string: "[a-b, b-c, a-c, a-d]")!

        XCTAssertEqual(graph.degree(forNodeWithValue: "a"), 3)
        XCTAssertEqual(graph.degree(forNodeWithValue: "d"), 1)
        XCTAssertEqual(graph.degree(forNodeWithValue: "e"), 0)

        // Mathematical fact: Sum of all degrees is always twice the number of edges.
        let sumOfDegrees = graph.nodes!.map { $0.degree }.reduce(0, +)
        XCTAssertEqual(sumOfDegrees, graph.edges!.length * 2)
    }

    func testNodesByDegree() {
        let graph = StringGraph(string: "[a-b, b-c, a-c, a-d]")!

        XCTAssertEqual(graph.nodesByDegree().map { $0.value }, ["a", "c", "b", "d"])
    }

    func testDepthFirstOrderGraphTraversal() {
        let graph = StringGraph(string: "[a-b, b-c, e, a-c, a-d]")!

        XCTAssertEqual(graph.depthFirstTraversalFrom(node: "d"), List("c", "b", "a", "d"))
        XCTAssertNil(graph.depthFirstTraversalFrom(node: "e"))
    }

    func testConnectedComponents() {
        let graph = StringGraph(string: "[a-b, c]")!
        let split = graph.split()!.values

        _testGraph(split.first!,
                   nodes: ["a", "b"],
                   edges: [TestGraphData.Edge(from: "a", to: "b")])

        _testGraph(split.last!,
                   nodes: ["c"],
                   edges: [])
    }

    func testColoredNodes() {
        let graph = StringGraph(string: "[a-b, b-c, a-c, a-d]")!

        let coloredNodes = graph.coloredNodes()!.values.sorted { (one, two) -> Bool in
            return one.0 < two.0
        }

        let expected = [("a", 1), ("b", 2), ("c", 3), ("d", 2)]

        print("\(expected) -> \(coloredNodes)")

        expected.enumerated().forEach {
            let correspondingTuple = coloredNodes[$0.offset]
            XCTAssertEqual($0.element.0,
                           correspondingTuple.0)
            XCTAssertEqual($0.element.1,
                           correspondingTuple.1)
        }
    }

    func testIsBipartite() {
        XCTAssertTrue(StringDigraph(string: "[a>b, c>a, d>b]")!.isBipartite())
        XCTAssertTrue(StringGraph(string: "[a-b, b-c, d]")!.isBipartite())

        XCTAssertFalse(StringGraph(string: "[a-b, b-c, c-a]")!.isBipartite())
        XCTAssertFalse(StringGraph(string: "[a-b, b-c, d, e-f, f-g, g-e, h]")!.isBipartite())
    }

    func testDOTConversion() {
        let dot1 = StringGraph(string: "[a-b/1, b-c/2, a-c/3]")!.toDOT()!
        XCTAssertEqual(dot1, """
        graph G {
            a -- b [label=1]
            b -- c [label=2]
            a -- c [label=3]
        }
        """)

        let dot2 = StringGraph(string: "[a-b, b-c, a-c/3]")!.toDOT()!
        XCTAssertEqual(dot2, """
        graph G {
            a -- b
            b -- c
            a -- c [label=3]
        }
        """)

        let dot3 = StringGraph(string: "[a-b, b-c, a-c]")!.toDOT()!
        XCTAssertEqual(dot3, """
        graph G {
            a -- b
            b -- c
            a -- c
        }
        """)

        let dot4 = StringDigraph(string: "[p>q/9, m>q/7, k, p>m/5]")!.toDOT()!
        XCTAssertEqual(dot4, """
        digraph G {
            p -> q [label=9]
            m -> q [label=7]
            p -> m [label=5]
        }
        """)
    }
}


struct TestGraphValue : LosslessStringConvertible, Hashable {
    let internalValue: String?
    init?(_ description: String) {
        guard description.isEmpty == false else {
            return nil
        }

        internalValue = description
    }

    var description: String {
        return "TestGraphValue(internalValue: \(internalValue ?? ""))"
    }

    func hash(with hasher: inout Hasher) {
        hasher.combine(internalValue)
    }

    static func == (lhs: TestGraphValue, rhs: TestGraphValue) -> Bool {
        return lhs.internalValue == rhs.internalValue
    }
}

func XCTAssertEqualCollectionIgnoringOrder<A: Collection, B: Collection>(_ a: A, _ b: B, file: StaticString = #file, line: UInt = #line) where A.Element : Hashable, A.Element == B.Element {
    let aSet = Set(a)
    let bSet = Set(b)

    XCTAssertEqual(aSet, bSet, file: file, line: line)
}
