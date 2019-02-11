//
//  Graph.swift
//  NinetyNineSwiftProblems
//
//  Created by Jacob Relkin on 2/3/19.
//  Copyright © 2019 Jacob Relkin. All rights reserved.
//

import Foundation

class Graph<T, U> {
    class Node {
        let value: T

        init(value: T) {
            self.value = value
        }
    }

    class Edge {
        let from: Node
        let to: Node
        let label: U

        init(from: Node, to: Node, label: U) {
            self.from = from
            self.to = to
            self.label = label
        }
    }

    enum Direction {
        case Indirected
        case Directed
    }

    class var direction: Direction {
        return .Indirected
    }

    var nodes: List<Node>?
    var edges: List<Edge>?
}

extension Graph where U == Int, T : Hashable {
    private struct GraphInitializationHelper {
        enum EdgeGenerationMode {
            case enforcingSymmetry
            case normal

            init(direction: Graph.Direction) {
                switch direction {
                case .Directed: self = .normal
                case .Indirected: self = .enforcingSymmetry
                }
            }
        }

        // For fast access to nodes through their underlying value
        private let _nodeCache: [T: Node]

        // To track the edges we've already added to prevent against duplicates
        private var _allEdges = Set<String>()

        private let _edgeGenerationMode: EdgeGenerationMode

        init(graph: Graph<T, U>, nodes: List<T>) {
            graph.nodes = nodes.map { Node(value: $0) }.toList()

            _edgeGenerationMode = EdgeGenerationMode(direction: type(of: graph).direction)
            _nodeCache = type(of: self)._generateNodeCache(graph.nodes?.values ?? [])
        }

        mutating func generateEdge(`for` nodePair: (T, T), label: U = 0) -> Edge? {
            guard let from = _node(forValue: nodePair.0), let to = _node(forValue: nodePair.1) else {
                return nil
            }

            let nodeValues = [from, to].map { "\($0.value)" }
            var edgeStrings = [nodeValues.joined(separator: "-")]

            if case EdgeGenerationMode.enforcingSymmetry = _edgeGenerationMode {
                edgeStrings.append(nodeValues.reversed().joined(separator: "-"))
            }

            guard edgeStrings.allSatisfy({ _allEdges.contains($0) == false }) else {
                return nil
            }

            edgeStrings.forEach { _allEdges.insert($0) }
            return Edge(from: from, to: to, label: label)
        }

        private func _node(forValue value: T) -> Node? {
            return _nodeCache[value]
        }

        private static func _generateNodeCache(_ nodes: [Node]) -> [T : Node] {
            return nodes.reduce([T:Node]()) { (res, node) -> [T:Node] in
                var r = res
                r[node.value] = node
                return r
            }
        }
    }

    convenience init(nodes n: List<T>, edges e: List<(T, T)>) {
        self.init(nodes: n, labeledEdges: e.map { ($0.0, $0.1, 0) }.toList()!)
    }

    convenience init(nodes n: List<T>, labeledEdges: List<(T, T, U)>) {
        self.init()

        var helper = GraphInitializationHelper(graph: self, nodes: n)
        edges = labeledEdges.compactMap { helper.generateEdge(for: ($0.0, $0.1), label: $0.2) }.toList()
    }

    convenience init(adjacentList list: List<(T, List<T>?)>) {
        self.init(adjacentLabeledList: list.map { ($0.0, $0.1?.map { ($0, 0) }.toList()) }.toList()!)
    }

    convenience init(adjacentLabeledList list: List<(T, List<(T, U)>?)>) {
        self.init()

        var helper = GraphInitializationHelper(graph: self, nodes: list.map { $0.0 }.toList()!)

        // Explicitly specify return type of the closure given to flatMap to signal that we want to use the non-deprecated form of flatMap for concatenating together the mapped collections.
        edges = list.values.flatMap { tuple -> [Edge] in
            let (nodeValue, adjacentNodeValueTuples) = tuple

            return adjacentNodeValueTuples?.values.compactMap {
                return helper.generateEdge(for: (nodeValue, $0.0), label: $0.1)
            } ?? []
        }.toList()
    }
}

class Digraph<T, U> : Graph<T, U> {
    override class var direction: Direction { return .Directed }
}

extension Graph.Node where T : CustomStringConvertible {
    var description: String {
        return "Graph.Node(value: \(value))"
    }
}

extension Graph.Edge where T : CustomStringConvertible, U : CustomStringConvertible {
    var description: String {
        return "Graph.Edge(from: \(from.description)), to: \(to.description), value: \(label))"
    }
}
