//
//  GraphTests.swift
//  NinetyNineSwiftProblemsTests
//
//  Created by Jacob Relkin on 2/5/19.
//  Copyright © 2019 Jacob Relkin. All rights reserved.
//

import XCTest

@testable import NinetyNineSwiftProblems

struct TestGraphData<T: GraphValueTypeConstraint, U: GraphLabelTypeConstraint & Equatable> {
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

    init(graph: Graph<T, U>?,
         edges edgeClosure: EdgeClosure? = nil,
         nodes nodeClosure: NodeClosure? = nil,
         expectedNodes: [T],
         expectedEdges: [Edge]) {
        self.edges = edgeClosure ?? {
            graph?.edges.map { (from: $0.from.value, to: $0.to.value, label: $0.label) } ?? []
        }

        self.nodes = nodeClosure ?? { graph?.nodes.map { $0.value } ?? [] }

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

class RejectingLosslessInitialization: LosslessStringConvertible, Hashable {
    static func == (lhs: RejectingLosslessInitialization, rhs: RejectingLosslessInitialization) -> Bool {
        return false
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(["ABCDEFGHIJKLMNOPQRSTUVWXYZ"].randomElement())
    }

    required init?(_ description: String) {
        return nil
    }

    var description: String {
        return "\(type(of: self))"
    }
}

typealias StringGraph = Graph<String, String>
typealias StringDigraph = Digraph<String, String>

class GraphTests: XCTestCase {
    func _testGraph<T: GraphValueTypeConstraint, U: GraphLabelTypeConstraint>(_ graph: Graph<T, U>?, nodes: [T], edges: [TestGraphData<T, U>.Edge], file: StaticString = #file, line: UInt = #line) {
        let data = TestGraphData(graph: graph, expectedNodes: nodes, expectedEdges: edges)
        data.runAssertions(file: file, line: line)
    }

    func testGraphTermInitialization() {
        let graph = Graph<String, Int>(
            nodes: ["b", "c", "d", "f", "g", "h", "k"],
            edges: [("b", "c"), ("b", "f"), ("c", "f"), ("f", "k"), ("g", "h"), ("c", "f"), ("h", "g"), ("f", "b")]
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
            nodes: ["b", "c", "d", "f", "g", "h", "k"],
            labeledEdges: [
                ("b", "c", 1),
                ("b", "f", 2),
                ("c", "f", 3),
                ("f", "k", 4),
                ("g", "h", 5),
                ("c", "f", 6), //dupe, won't be included
                ("h", "g", 7), //already exists in opposite direction, won't be included
                ("f", "b", 8)  //already exists in opposite direction, won't be included
            ]
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
            nodes: ["b", "c", "d", "f", "g", "h", "k"],
            edges: [("b", "c"), ("c", "b"), ("f", "b"), ("b", "f"), ("b", "f"), ("c", "f"), ("f", "k"), ("g", "h"), ("f", "b")]
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
            nodes: ["b", "c", "d", "f", "g", "h", "k"],
            labeledEdges: [
                ("b", "c", 1),
                ("b", "f", 2),
                ("c", "f", 3),
                ("f", "k", 4),
                ("g", "h", 5),
                ("h", "g", 6),
                ("f", "b", 7),
                ("c", "f", -1) //dupe, won't be included
            ]
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
        let graph = Graph<String, Int>(adjacentList: [
            ("b", ["c", "f"]),
            ("c", ["b", "f"]),
            ("d", nil),
            ("f", ["b", "c", "k"]),
            ("g", ["h"]),
            ("h", ["g"]),
            ("k", ["f"])
        ])

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
        let graph = Digraph<String, Int>(adjacentList: [
            ("b", ["c", "f"]),
            ("c", ["b", "f"]),
            ("d", nil),
            ("f", ["b", "c", "k"]),
            ("g", ["h"]),
            ("h", ["g"]),
            ("k", ["f"])
        ])

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
        let graph = Graph<String, Int>(adjacentLabeledList: [
            ("b", [("c", 1), ("f", 2)]),
            ("c", [("b", 3), ("f", 4)]),
            ("d", nil),
            ("f", [("b", 5), ("c", 6), ("k", 7)]),
            ("g", [("h", 8)]),
            ("h", [("g", 9)]),
            ("k", [("f", 10)])
        ])

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
        let graph = Digraph<String, Int>(adjacentLabeledList: [
            ("b", [("c", 1), ("f", 2)]),
            ("c", [("b", 3), ("f", 4)]),
            ("d", nil),
            ("f", [("b", 5), ("c", 6), ("k", 7)]),
            ("g", [("h", 8)]),
            ("h", [("g", 9)]),
            ("k", [("f", 10)])
        ])

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

        XCTAssertNil(Graph<RejectingLosslessInitialization, String>(string: "[b]"))
        XCTAssertNil(Graph<RejectingLosslessInitialization, String>(string: "[b-c]"))
        XCTAssertNotNil(StringGraph(string: "[a-b]"))
        XCTAssertNotNil(StringGraph(string: "[a-b, b-c]"))

        XCTAssertNil(StringGraph(string: ""))
        XCTAssertNil(StringGraph(string: "[]"))

        graph = StringGraph(string: "[d]")
        XCTAssertEmpty(graph?.edges)
        XCTAssertEqual(graph?.nodes.map { $0.value }, ["d"])

        // Use a string with duplicate and opposite edges to test for correctness.
        graph = StringGraph(string: "[b-c, f-c, g-h, d, f-b, k-f, h-g, g-h]")
        XCTAssertNotNil(graph)

        _testGraph(graph,
                   nodes: ["b", "c", "f", "g", "h", "d", "k"],
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

        _testGraph(graph,
                   nodes: ["b", "c", "f", "g", "h", "d", "k"],
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
        XCTAssertEmpty(graph?.edges)
        XCTAssertEqual(graph?.nodes.map { $0.value }, ["d"])

        graph = StringDigraph(string: "[b>c, f>c, g>h, d, f>b, k>f, h>g, g>h]")
        XCTAssertNotNil(graph)

        _testGraph(graph,
                   nodes: ["b", "c", "f", "g", "h", "d", "k"],
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

        _testGraph(intLabeledGraph,
                   nodes: ["b", "c", "f", "g", "h", "d", "k"],
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
        XCTAssertEqual(graphOfSingleNode?.toTermForm().0, ["b"])
        XCTAssertEmpty(graphOfSingleNode?.toTermForm().1)

        let graph = Graph<String, Int>(string: humanFriendlyString)
        let (nodes, edges) = graph?.toTermForm() ?? ([], [])

        let expectedEdges = [
            ("b", "c", 1),
            ("f", "c", 2),
            ("g", "h", 3),
            ("f", "b", 4),
            ("k", "f", 5)
        ].map {
            TestGraphData.Edge(from: $0.0, to: $0.1, label: $0.2)
        }

        let edgeGetter = { edges.map { (from: $0.0, to: $0.1, label: $0.2) } }
        let data = TestGraphData(graph: graph,
                                 edges: edgeGetter,
                                 nodes: { nodes },
                                 expectedNodes: ["b", "c", "f", "g", "h", "k"],
                                 expectedEdges: expectedEdges)
        data.runAssertions()
    }

    func testDigraphToTermForm() {
        let humanFriendlyString = "[b>c/1, f>c/2, g>h/3, f>b/4, k>f/5, h>g/6, g>h/7]"

        let graphOfSingleNode = StringDigraph(string: "[b]")
        XCTAssertEqual(graphOfSingleNode?.toTermForm().0, ["b"])
        XCTAssertEmpty(graphOfSingleNode?.toTermForm().1)

        let graph = Digraph<String, Int>(string: humanFriendlyString)
        let (nodes, edges) = graph?.toTermForm() ?? ([], [])

        let expectedEdges = [
            ("b", "c", 1),
            ("f", "c", 2),
            ("g", "h", 3),
            ("f", "b", 4),
            ("k", "f", 5),
            ("h", "g", 6)
        ].map { TestGraphData.Edge(from: $0.0, to: $0.1, label: $0.2) }

        let edgeGetter = { edges.map { (from: $0.0, to: $0.1, label: $0.2) } }
        let data = TestGraphData(graph: graph,
                                 edges: edgeGetter,
                                 nodes: { nodes },
                                 expectedNodes: ["b", "c", "f", "g", "h", "k"],
                                 expectedEdges: expectedEdges)
        data.runAssertions()
    }

    func testGraphToAdjacentForm() {
        typealias ResultType = [(String, [(String, Int?)]?)]
        func testAdjacentForm(_ expected: ResultType, result: ResultType?, line: UInt = #line) {
            XCTAssertNotNil(result, file: #file, line: line)
            XCTAssertEqual(expected.count, result?.count, file: #file, line: line)

            for (er, r) in zip(expected, result ?? []) {
                XCTAssertEqual(er.0, r.0, file: #file, line: line)
                XCTAssertEqual(er.1?.first?.0, r.1?.first?.0, file: #file, line: line)
                XCTAssertEqual(er.1?.first?.1, r.1?.first?.1, file: #file, line: line)
                XCTAssertEqual(er.1?.last?.0, r.1?.last?.0, file: #file, line: line)
                XCTAssertEqual(er.1?.last?.1, r.1?.last?.1, file: #file, line: line)
            }
        }

        testAdjacentForm([
            ("p", [("q", 9), ("m", 5)]),
            ("m", [("q", 7)]),
            ("k", nil),
            ("q", nil)
        ], result: Graph<String, Int>(string: "[p-q/9, m-q/7, k, p-m/5]")?.toAdjacentForm())

        // No edges? No adjacency list!
        let nodeOnlyGraph = StringGraph(string: "[p,q,r,s]")
        XCTAssertEqual(nodeOnlyGraph?.nodes.count, 4)
        XCTAssertEmpty(nodeOnlyGraph?.toAdjacentForm())
    }

    func testDigraphToAdjacentForm() {
        let expectedResult = [
            ("p", [("q", 9), ("m", 5)]),
            ("m", [("q", 7)]),
            ("k", nil),
            ("q", nil)
        ]

        let result = Digraph<String, Int>(string: "[p>q/9, m>q/7, k, p>m/5]")?.toAdjacentForm()
        XCTAssertNotNil(result)
        XCTAssertEqual(expectedResult.count, result?.count)

        for (er, r) in zip(expectedResult, result ?? []) {
            XCTAssertEqual(er.0, r.0)
            XCTAssertEqual(er.1?.first?.0, r.1?.first?.0)
            XCTAssertEqual(er.1?.first?.1, r.1?.first?.1)
            XCTAssertEqual(er.1?.last?.0, r.1?.last?.0)
            XCTAssertEqual(er.1?.last?.1, r.1?.last?.1)
        }

        // No edges? No adjacency list!
        let nodeOnlyGraph = StringDigraph(string: "[p,q,r,s]")
        XCTAssertEqual(nodeOnlyGraph?.nodes.count, 4)
        XCTAssertEmpty(nodeOnlyGraph?.toAdjacentForm())
    }

    func testOrphanNodes() {
        var graph: Graph<String, Int>? = Digraph<String, Int>(string: "[p>q/9, m>q/7, k, p>m/5]")
        XCTAssertEqual(graph?.orphanNodes.map { $0.value }, ["k", "q"])

        graph = Graph<String, Int>(string: "[p-q, m-q, r, s]")
        XCTAssertEqual(graph?.orphanNodes.map { $0.value }, ["s", "r", "q"])
    }

    // swiftlint:disable force_unwrapping
    func testCustomGraphValueType() {
        let graph = Graph<TestGraphValue, String>(string: "[a-b, c-d, e]")
        XCTAssertNotNil(graph)

        let expectedEdges = [
            ("a", "b"),
            ("c", "d")
        ].map {
            TestGraphData<TestGraphValue, String>.Edge(from: TestGraphValue($0.0)!,
                                                       to: TestGraphValue($0.1)!)
        }

        let data = TestGraphData(graph: graph,
                                 expectedNodes: [TestGraphValue("a"),
                                                 TestGraphValue("b"),
                                                 TestGraphValue("c"),
                                                 TestGraphValue("d"),
                                                 TestGraphValue("e")].compactMap { $0 },
                                 expectedEdges: expectedEdges)
        data.runAssertions()
    }

    func testCustomDigraphValueType() {
        let graph = Digraph<TestGraphValue, String>(string: "[a>b, c>d, d>c, b>a, e]")
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
    // swiftlint:enable force_unwrapping

    func testGraphFindPaths() {
        let graph = StringGraph(string: "[p-q/9, m-q/7, k, p-m/5, p-x, x-y, y-q, q-p]")
        let paths = graph?.findPaths(from: "p", to: "q")

        XCTAssertEqual(paths, [["p", "q"], ["p", "m", "q"], ["p", "x", "y", "q"]])

        let invalidPaths = [graph?.findPaths(from: "p", to: "k"), graph?.findPaths(from: "k", to: "m")]
        invalidPaths.forEach { XCTAssertEmpty($0) }

        let edgelessGraph = StringGraph(string: "[g,h,i]")
        XCTAssertEmpty(edgelessGraph?.findPaths(from: "g", to: "i"))
    }

    func testDigraphFindPaths() {
        let graph = StringDigraph(string: "[p>q/9, m>q/7, k, p>m/5, p>x, x>y, y>q, q>p]") // Purposely add an q>p edge to test acyclic node filtration.
        let paths = graph?.findPaths(from: "p", to: "q")

        XCTAssertEqual(paths, [["p", "q"], ["p", "m", "q"], ["p", "x", "y", "q"]])

        let invalidPaths = [graph?.findPaths(from: "p", to: "k"), graph?.findPaths(from: "k", to: "m")]
        invalidPaths.forEach { XCTAssertEmpty($0) }
    }

    func testGraphFindCycles() {
        let graph = StringGraph(string: "[b-c, f-c, g-h, d, f-b, k-f, h-g]")
        let cycles = graph?.findCycles(from: "f")

        XCTAssertNotNil(cycles)
        XCTAssertEqualCollectionIgnoringOrder(cycles ?? [], [
            ["f", "c", "b", "f"],
            ["f", "b", "c", "f"]
        ])

        let edgelessGraph = StringGraph(string: "[b,c,f]")
        XCTAssertNil(edgelessGraph?.findCycles(from: "f"))

        let uncycledGraph = StringGraph(string: "[b-c, f-c, g-h, d, k-f]")
        XCTAssertEmpty(uncycledGraph?.findCycles(from: "f"))
        XCTAssertNil(uncycledGraph?.findCycles(from: "i"))
    }

    func testDigraphFindCycles() {
        let cycledGraph = StringDigraph(string: "[b>c, f>c, g>h, d, f>b, k>f, h>g, f>k, c>f, k>b]")
        let cycles = cycledGraph?.findCycles(from: "f")

        XCTAssertNotNil(cycles)
        XCTAssertEqualCollectionIgnoringOrder(cycles ?? [], [
            ["f", "k", "b", "c", "f"],
            ["f", "b", "c", "f"]
        ])

        let uncycledGraph = StringDigraph(string: "[b>c, f>c, g>h, d, f>b, k>f, h>g, f>k]")
        XCTAssertTrue(uncycledGraph?.findCycles(from: "f")?.isEmpty ?? false)
        XCTAssertNil(uncycledGraph?.findCycles(from: "i"))
    }

    func testDegreeForNode() {
        let graph = StringGraph(string: "[a-b, b-c, a-c, a-d]")

        XCTAssertEqual(graph?.degree(forNodeWithValue: "a"), 3)
        XCTAssertEqual(graph?.degree(forNodeWithValue: "d"), 1)
        XCTAssertEqual(graph?.degree(forNodeWithValue: "e"), 0)

        // Mathematical fact: Sum of all degrees is always twice the number of edges.
        let sumOfDegrees = graph?.nodes.map { $0.degree }.reduce(0, +)
        XCTAssertEqual(sumOfDegrees, (graph?.edges.count ?? 0) * 2)
    }

    func testNodesByDegree() {
        let graph = StringGraph(string: "[a-b, b-c, a-c, a-d]")

        XCTAssertEqual(graph?.nodesByDegree().map { $0.value }, ["a", "c", "b", "d"])
    }

    func testDepthFirstOrderGraphTraversal() {
        let graph = StringGraph(string: "[a-b, b-c, e, a-c, a-d]")

        XCTAssertEqual(graph?.depthFirstTraversalFrom(node: "d"), ["c", "b", "a", "d"])
        XCTAssertTrue(graph?.depthFirstTraversalFrom(node: "e")?.isEmpty ?? false)
    }

    func testConnectedComponents() {
        let graph = StringGraph(string: "[a-b, c]")
        let split = graph?.split()

        _testGraph(split?.first,
                   nodes: ["a", "b"],
                   edges: [TestGraphData.Edge(from: "a", to: "b")])

        _testGraph(split?.last,
                   nodes: ["c"],
                   edges: [])
    }

    func testColoredNodes() {
        func testColoredNodes(with graph: StringGraph?, expecting expected: [(String, Int)], line: UInt = #line) {
            let coloredNodes = graph?.coloredNodes()?.sorted { $0.0 < $1.0 }

            expected.enumerated().forEach {
                let correspondingTuple = coloredNodes?[$0.offset]
                XCTAssertEqual($0.element.0,
                               correspondingTuple?.0, file: #file, line: line)
                XCTAssertEqual($0.element.1,
                               correspondingTuple?.1, file: #file, line: line)
            }
        }

        testColoredNodes(with: StringGraph(string: "[a-b, b-c, a-c, a-d]"),
                         expecting: [("a", 1), ("b", 2), ("c", 3), ("d", 2)])

        testColoredNodes(with: StringGraph(string: "[a-b, b-c, a-c, a-d, e]"),
                         expecting: [("a", 1), ("b", 2), ("c", 3), ("d", 2), ("e", 1)])
    }

    func testIsBipartite() {
        XCTAssertTrue(StringDigraph(string: "[a>b, c>a, d>b]")?.isBipartite() ?? false)
        XCTAssertTrue(StringGraph(string: "[a-b, b-c, d]")?.isBipartite() ?? false)

        XCTAssertFalse(StringGraph(string: "[a-b, b-c, c-a]")?.isBipartite() ?? false)
        XCTAssertFalse(StringGraph(string: "[a-b, b-c, c-a, d-a, c-d]")?.isBipartite() ?? false)
    }

    func testDOTConversion() {
        let dot1 = StringGraph(string: "[a-b/1, b-c/2, a-c/3]")?.DOTRepresentation()
        XCTAssertEqual(dot1, """
        graph G {
            a -- b [label=1]
            b -- c [label=2]
            a -- c [label=3]
        }
        """)

        let dot2 = StringGraph(string: "[a-b, b-c, a-c/3]")?.DOTRepresentation()
        XCTAssertEqual(dot2, """
        graph G {
            a -- b
            b -- c
            a -- c [label=3]
        }
        """)

        let dot3 = StringGraph(string: "[a-b, b-c, a-c, d]")?.DOTRepresentation()
        XCTAssertEqual(dot3, """
        graph G {
            a -- b
            b -- c
            a -- c
            d
        }
        """)

        let dot4 = StringDigraph(string: "[p>q/9, m>q/7, k, p>m/5]")?.DOTRepresentation()
        XCTAssertEqual(dot4, """
        digraph G {
            p -> q [label=9]
            m -> q [label=7]
            p -> m [label=5]
            k
        }
        """)

        let dot5 = StringDigraph(string: "[p,m]")?.DOTRepresentation()
        XCTAssertEqual(dot5, """
        digraph G {
            p
            m
        }
        """)
    }

    func testEdgePartnerWithUnrelatedNode() {
        let edge = StringDigraph(string: "[p>q/9]")?.edges.first
        XCTAssertNil(edge?.partner(for: Graph.Node(value: "a")))
    }
}

class GraphExtensionTests: XCTestCase {
    func testHashable() {
        let graph = StringGraph(string: "[a-b]")
        let set = Set([graph])
        XCTAssertEqual(set.count, 1)
    }

    func testEquatable() {
        let graph = StringDigraph(string: "[a>b]")
        let otherGraph = StringDigraph(string: "[a>b]")
        XCTAssertTrue(graph == otherGraph)
        XCTAssertEqual(graph?.nodes.first, otherGraph?.nodes.first)
        XCTAssertEqual(graph?.edges.first, otherGraph?.edges.first)
    }
}

struct TestGraphValue: LosslessStringConvertible, Hashable {
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
