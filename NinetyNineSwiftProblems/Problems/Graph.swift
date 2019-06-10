//
//  Graph.swift
//  NinetyNineSwiftProblems
//
//  Created by Jacob Relkin on 2/3/19.
//  Copyright © 2019 Jacob Relkin. All rights reserved.
//

import Foundation

typealias GraphValueTypeConstraint = LosslessStringConvertible & Hashable
typealias GraphLabelTypeConstraint = LosslessStringConvertible

class Graph<T : GraphValueTypeConstraint, U : GraphLabelTypeConstraint> : CustomStringConvertible {
    class Node {
        let value: T
        var adjacentEdges = [Edge]()

        init(value: T) {
            self.value = value
        }
    }

    class Edge {
        let from: Node
        let to: Node
        let label: U?

        init(from: Node, to: Node, label: U?) {
            self.from = from
            self.to = to
            self.label = label
        }

        func partner(for node: Node) -> Node? {
            if from.value == node.value {
                return to
            }

            if to.value == node.value {
                return from
            }

            return nil
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

    final class var isDirected: Bool {
        switch direction {
        case .Directed:
            return true
        case .Indirected:
            return false
        }
    }

    var nodes: List<Node>?
    var edges: List<Edge>?

    var orphanNodes: List<Node>? {
        return nodes?.reversed.filter { node in
            edges?.map { $0.from }.contains {
                return $0.value == node.value
            } == false
        }.toList()
    }

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

    func edgeTarget(_ edge: Edge, node: Node) -> Node? {
        guard type(of: self).isDirected else {
            if edge.from.value == node.value {
                return edge.to
            }

            return nil
        }

        return edge.partner(for: node)
    }

    func toTermForm() -> (List<T>, List<(T, T, U?)>?) {
        return (nodes!.map({ $0.value }).toList()!, edges?.map({ ($0.from.value, $0.to.value, $0.label) }).toList())
    }

    func toAdjacentForm() -> List<(T, List<(T, U?)>?)> {
        var adjacentForm = [(T, [(T, U?)]?)]()

        // Process edges
        for edge in edges?.values ?? [] {
            let edgePairToAdd = (edge.to.value, edge.label)

            // Find the index of the occurrence of this source node, if it exists
            let sourceEdgePairIndex = adjacentForm.firstIndex(where: { $0.0 == edge.from.value })

            // The index of the final nodes to be stored
            var targetNodeIndex = sourceEdgePairIndex

            // The pre-existing nodes for this edge's source
            var existingNodesForSource = [(T, U?)]()

            // Is there an existing pair with this source node?
            if let index = targetNodeIndex {
                let existingPair = adjacentForm[index]

                existingNodesForSource = existingPair.1 ?? []
            } else {
                // Set the index to be the last == append
                targetNodeIndex = adjacentForm.endIndex
            }

            guard let tni = targetNodeIndex else {
                continue
            }

            let concatenatedNodes = existingNodesForSource + [edgePairToAdd]
            let adjacentTuple = (edge.from.value, Optional(concatenatedNodes))
            if tni >= adjacentForm.count {
                adjacentForm.append(adjacentTuple)
            } else {
                adjacentForm[tni] = adjacentTuple
            }
        }

        // Process the orphan nodes
        for orphan in orphanNodes?.values ?? [] {
            adjacentForm.append((orphan.value, nil))
        }

        return adjacentForm.map { ($0.0, $0.1?.toList()) }.toList()!
    }

    func findPaths(from: T, to: T, withEdges filteredEdges: [Edge]? = nil) -> List<List<T>>? {
        var paths = [[T]]()

        let edgesToTraverse = filteredEdges ?? (edges?.values ?? [])

        for edge in edgesToTraverse {
            guard edge.from.value == from else {
                continue
            }

            if edge.to.value == to {
                paths.append([edge.from.value, edge.to.value])
            } else {
                let subAcyclicEdges = edgesToTraverse.filter { $0.to.value != from }
                guard var subpaths = findPaths(from: edge.to.value, to: to, withEdges: subAcyclicEdges)?.values, subpaths.isEmpty == false else {
                    continue
                }

                let first = subpaths.remove(at: 0).values
                guard let insertionList = ([edge.from.value] + first).toList() else {
                    continue
                }

                subpaths.insert(insertionList, at: 0)
                paths += subpaths.map { $0.values }
            }
        }

        return paths.compactMap { $0.toList() }.toList()
    }

    func findCycles(from: T) -> List<List<T>>? {
        guard let node = edges?.first(where: { $0.from.value == from })?.from else {
            return nil
        }

        let targets = Set(node.adjacentEdges.compactMap {
            edgeTarget($0, node: node)?.value
        })

        var paths = targets.flatMap {
            findPaths(from: $0, to: from)?.values ?? []
        }.map { [from] + $0.values }

        if type(of: self).isDirected == false {
            paths += targets.flatMap {
                findPaths(from: from, to: $0)?.values ?? []
            }.map { $0.values + [from] }

            paths += paths.map {
                $0.reversed()
            }
        }

        return paths
            .filter { $0.count > 3 }
            .compactMap { $0.toList() }
            .reversed()
            .toList()
    }
}

extension Graph {
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

        private let _edgeSeparator: String

        // For fast access to nodes through their underlying value
        private let _nodeCache: [T: Node]

        // To track the edges we've already added to prevent against duplicates
        private var _allEdges = Set<String>()

        private let _edgeGenerationMode: EdgeGenerationMode

        init(graph: Graph<T, U>, nodes: List<T>) {
            graph.nodes = nodes.map { Node(value: $0) }.toList()

            _edgeSeparator = type(of: graph).humanFriendlyEdgeSeparator
            _edgeGenerationMode = EdgeGenerationMode(direction: type(of: graph).direction)
            _nodeCache = type(of: self)._generateNodeCache(graph.nodes?.values ?? [])
        }

        mutating func generateEdge(`for` nodePair: (T, T), label: U?) -> Edge? {
            guard let from = _node(forValue: nodePair.0), let to = _node(forValue: nodePair.1) else {
                return nil
            }

            let nodeValues = [from, to].map { "\($0.value)" }
            var edgeStrings = [nodeValues.joined(separator: _edgeSeparator)]

            // Generate the reverse edge as well in an indirected graph.
            if case EdgeGenerationMode.enforcingSymmetry = _edgeGenerationMode {
                edgeStrings.append(nodeValues.reversed().joined(separator: _edgeSeparator))
            }

            guard _allEdges.intersection(Set(edgeStrings)).count == 0 else {
                return nil
            }

            edgeStrings.forEach { _allEdges.insert($0) }

            let edge = Edge(from: from, to: to, label: label)
            from.adjacentEdges = [edge] + from.adjacentEdges
            to.adjacentEdges = [edge] + to.adjacentEdges

            return edge
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
        self.init(nodes: n, labeledEdges: e.map { ($0.0, $0.1, nil) }.toList()!)
    }

    convenience init(nodes n: List<T>, labeledEdges: List<(T, T, U?)>) {
        self.init()

        var helper = GraphInitializationHelper(graph: self, nodes: n)
        edges = labeledEdges.compactMap { helper.generateEdge(for: ($0.0, $0.1), label: $0.2) }.toList()
    }

    convenience init(adjacentList list: List<(T, List<T>?)>) {
        self.init(adjacentLabeledList: list.map { ($0.0, $0.1?.map { ($0, nil) }.toList()) }.toList()!)
    }

    convenience init(adjacentLabeledList list: List<(T, List<(T, U?)>?)>) {
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

        let edgeInfoTuples = _parseEdgeComponents(edgeComponents)
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

    private func _parseEdgeComponent(_ edgeComponent: String) -> (T, T?, U?)? {
        let separator = type(of: self).humanFriendlyEdgeSeparator

        func findLabel(`in` string: String) -> (U?, Int?) {
            var label:U? = nil
            var position:Int?

            if let labelPosition = string.scan(for: { $0 == "/" }),
                let foundLabel = string.substring(in: labelPosition + 1..<string.count),
                let createdLabel = U(foundLabel) {
                label = createdLabel
                position = labelPosition
            }

            return (label, position)
        }

        // Parse separators.
        guard let _ = edgeComponent.scan(for: { $0 == Character(separator) }) else {
            let otherGraphType = type(of: self).isDirected ? Graph<T, U>.self : Digraph<T, U>.self
            let otherSeparator = otherGraphType.humanFriendlyEdgeSeparator
            if edgeComponent.isEmpty || edgeComponent.contains(otherSeparator) {
                return nil
            }

            guard let from = T.init(edgeComponent.trimmingCharacters(in: .whitespaces)) else {
                return nil
            }

            return (from: from, to: nil, label: findLabel(in: edgeComponent).0)
        }

        let components = edgeComponent.components(separatedBy: separator).map {
            $0.trimmingCharacters(in: .whitespaces)
        }

        guard components.count == 2 else {
            if let first = components.first, components.count < 2 {
                let (label, labelPositionOptional) = findLabel(in: first)
                let nodeValueEndPosition = (labelPositionOptional ?? first.count)
                guard
                    let nodeValue = first.substring(in: 0..<nodeValueEndPosition),
                    let concreteNodeValue = T.init(nodeValue) else {
                    return nil
                }

                return (from: concreteNodeValue, to: nil, label)
            }

            return nil
        }

        var (fromNodeValue, toNodeValue) = (components.first!, components.last!)
        let (label, labelPositionOptional) = findLabel(in: toNodeValue)

        if let position = labelPositionOptional {
            toNodeValue = toNodeValue.substring(in: 0..<position) ?? toNodeValue
        }

        guard let concreteFromValue = T.init(fromNodeValue) else {
            return nil
        }

        let concreteToValue = T.init(toNodeValue)
        return (from: concreteFromValue, to: concreteToValue, label: label)
    }

    private func _parseEdgeComponents(_ edgeComponents: [String]) -> [(T, T?, U?)] {
        let results = edgeComponents.map { _parseEdgeComponent($0) }

        guard results.contains(where: { $0 == nil }) == false else {
            return []
        }

        return results.compactMap { $0 }
    }
}

class Digraph<T : GraphValueTypeConstraint, U : GraphLabelTypeConstraint> : Graph<T, U> {
    override class var direction: Direction { return .Directed }
    override class var humanFriendlyEdgeSeparator: String { return ">" }
}

extension Graph.Node : CustomStringConvertible {
    var description: String {
        return "Graph.Node(value: \(value))"
    }
}

extension Graph.Edge : CustomStringConvertible {
    var description: String {
        let components = ["from": Optional(from.description), "to": Optional(to.description), "label" : label?.description].filter { $0.value != nil }.map {
            "\($0.key): \($0.value!)"
        }

        return "Graph.Edge(\(components.joined(separator: ", ")))"
    }
}
