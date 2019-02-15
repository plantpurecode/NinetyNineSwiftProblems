//
//  Graph.swift
//  NinetyNineSwiftProblems
//
//  Created by Jacob Relkin on 2/3/19.
//  Copyright © 2019 Jacob Relkin. All rights reserved.
//

import Foundation

class Graph<T : CustomStringConvertible & Equatable, U> : CustomStringConvertible {
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

    class var humanFriendlyEdgeSeparator: String {
        return "-"
    }

    var nodes: List<Node>?
    var edges: List<Edge>?

    var description: String {
        let separator = type(of: self).humanFriendlyEdgeSeparator
        let orphanNodes = nodes?.filter { node in
            return (edges?.values ?? []).allSatisfy { (edge) -> Bool in
                return edge.from.value != node.value && edge.to.value != node.value
            }
        }.map { String(describing: $0.value) } ?? []

        let allEdges = edges?.values.reduce([String](), { res, edge in
            return res + [[edge.from.value, edge.to.value].map { $0.description }.joined(separator: separator)]
        }) ?? [String]()

        return "[\((allEdges + orphanNodes).joined(separator: ", "))]"
    }

    func toTermForm() -> (List<T>, List<(T, T, U)>?) {
        return (nodes!.map({ $0.value }).toList()!, edges?.map({ ($0.from.value, $0.to.value, $0.label) }).toList())
    }
}

extension Graph where T : Hashable {
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

        mutating func generateEdge(`for` nodePair: (T, T), label: U) -> Edge? {
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
}

extension Graph where U == Int, T : Hashable {
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

extension Graph where T == String, U == String {
    private func parseEdgeComponents(_ edgeComponents: [String]) -> [(T, T?, U)] {
        return edgeComponents.compactMap { edgeComponent -> (T, T?, U)? in
            let separator = type(of: self).humanFriendlyEdgeSeparator

            func findLabel(`in` string: String) -> (String, Int?) {
                var label = ""
                var position:Int?

                if let labelPosition = string.scan(for: { $0 == "/" }),
                    let foundLabel = string.substring(in: labelPosition + 1..<string.count) {
                    label = foundLabel
                    position = labelPosition
                }

                return (label, position)
            }

            // Parse separators.
            guard let _ = edgeComponent.scan(for: { $0 == Character(separator) }) else {
                let otherSeparator = type(of: self) == Graph.self ? Digraph<T, U>.humanFriendlyEdgeSeparator : Graph<T, U>.humanFriendlyEdgeSeparator
                if edgeComponent.isEmpty || edgeComponent.contains(otherSeparator) {
                    return nil
                }

                return (from: edgeComponent.trimmingCharacters(in: .whitespaces), to: nil, label: findLabel(in: edgeComponent).0)
            }

            let components = edgeComponent.components(separatedBy: separator).map {
                $0.trimmingCharacters(in: .whitespaces)
            }

            guard components.isEmpty == false else {
                return nil
            }

            guard components.count == 2 else {
                if let first = components.first {
                    let (label, labelPositionOptional) = findLabel(in: first)
                    let nodeValueEndPosition = (labelPositionOptional ?? first.count)
                    guard let nodeValue = first.substring(in: 0..<nodeValueEndPosition) else {
                        return nil
                    }

                    return (from: nodeValue, to: nil, label)
                }

                return nil
            }

            var toNodeValue = components.last!
            let (label, labelPositionOptional) = findLabel(in: toNodeValue)

            if let position = labelPositionOptional {
                toNodeValue = toNodeValue.substring(in: 0..<position) ?? toNodeValue
            }

            return (from: components.first!, to: toNodeValue, label: label)
        }
    }

    convenience init?(string: String) {
        self.init()

        guard string.first == "[", string.last == "]" else {
            return nil
        }

        // Create a string without the leading and trailing brackets.
        let truncatedEdgeString = string
            .suffix(from: string.index(after: string.startIndex))
            .prefix(upTo: string.index(before: string.endIndex))

        let edgeComponents = truncatedEdgeString.components(separatedBy: ",")
        guard edgeComponents.isEmpty == false else {
            return nil
        }

        let edgeInfoTuples = parseEdgeComponents(edgeComponents)
        guard edgeInfoTuples.isEmpty == false else {
            return nil
        }

        let nodes = edgeInfoTuples.reduce([T]()) { array, tuple in
            var a = array

            [tuple.0, tuple.1]
                // Filter out nil (i.e. when there is only one node in the component.)
                .compactMap { $0 }
                // Ensure we don't have duplicate nodes
                .filter { a.contains($0) == false }
                .forEach { a.append($0) }

            return a
        }.toList()!

        var helper = GraphInitializationHelper(graph: self, nodes: nodes)
        edges = edgeInfoTuples
            .filter { $0.1 != nil }
            .compactMap { helper.generateEdge(for: ($0.0, $0.1!), label: $0.2) }.toList()
    }
}

class Digraph<T : CustomStringConvertible & Equatable, U> : Graph<T, U> {
    override class var direction: Direction { return .Directed }
    override class var humanFriendlyEdgeSeparator: String { return ">" }
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
