//
//  Graph.swift
//  NinetyNineSwiftProblems
//
//  Created by Jacob Relkin on 2/3/19.
//  Copyright © 2019 Jacob Relkin. All rights reserved.
//

import Foundation

typealias GraphValueTypeConstraint = LosslessStringConvertible & Hashable
typealias GraphLabelTypeConstraint = LosslessStringConvertible & Comparable

class Graph<T: GraphValueTypeConstraint, U: GraphLabelTypeConstraint>: CustomStringConvertible {
    class Node: Hashable {
        // MARK: Hashable
        func hash(into hasher: inout Hasher) {
            hasher.combine(value)
            hasher.combine(degree)
        }

        // MARK: -
        let value: T

        init(value: T) {
            self.value = value
        }

        var degree: Int {
            return adjacentEdges.count
        }

        var neighbors: [Node] {
            return adjacentEdges.compactMap {
                $0.partner(for: self)
            }
        }

        var adjacentEdges = [Edge]()
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

        func connects(to nodes: [Node]) -> Bool {
            return !(nodes.contains(from) == nodes.contains(to))  // xor
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

    fileprivate(set) var nodes: [Node] = []
    fileprivate(set) var edges: [Edge] = []

    required init() {

    }

    typealias AdjacencyList = [(T, [(T, U?)]?)]
    required init(adjacentLabeledList list: AdjacencyList) {
        var helper = GraphInitializationHelper(graph: self, nodes: list.map { $0.0 })

        edges = list.compactMap { tuple -> [Edge]? in
            let (node, adjacentNodeValueTuples) = tuple

            return adjacentNodeValueTuples?.compactMap {
                helper.generateEdge(for: (node, $0.0), label: $0.1)
            }
        }.flatMap { $0 }
    }

    var orphanNodes: [Node] {
        return nodes.reversed().filter { node in
            edges.map { $0.from }.contains {
                $0.value == node.value
            } == false
        }
    }

    var description: String {
        let separator = type(of: self).humanFriendlyEdgeSeparator
        let orphanNodes = nodes.filter { node in
            edges.allSatisfy { edge -> Bool in
                edge.from.value != node.value && edge.to.value != node.value
            }
        }.map { String(describing: $0.value) }

        let allEdges = edges.reduce([String](), { res, edge in
            var edgeComponents = [edge.from.value, edge.to.value].map { $0.description }.joined(separator: separator)
            if let label = edge.label {
                edgeComponents += "/\(label.description)"
            }

            return res + [edgeComponents]
        })

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

    func toTermForm() -> ([T], [(T, T, U?)]) {
        return (nodes.map({ $0.value }), edges.map({ ($0.from.value, $0.to.value, $0.label) }))
    }

    func toAdjacentForm() -> [(T, [(T, U?)]?)] {
        guard edges.isEmpty == false else {
            return []
        }

        var adjacentForm = [(T, [(T, U?)]?)]()

        // Process edges
        for edge in edges {
            let edgePairToAdd = (edge.to.value, edge.label)
            let targetNodeIndex = adjacentForm.firstIndex(where: { $0.0 == edge.from.value }) ?? adjacentForm.endIndex

            // The pre-existing nodes for this edge's source
            var existingNodesForSource = [(T, U?)]()

            // Is there an existing pair with this source node?
            if adjacentForm.isEmpty == false, targetNodeIndex < adjacentForm.count, let existingPairAdjacencyList = adjacentForm[targetNodeIndex].1 {
                existingNodesForSource.append(contentsOf: existingPairAdjacencyList)
            }

            let concatenatedNodes = existingNodesForSource + [edgePairToAdd]
            let adjacentTuple = (edge.from.value, Optional(concatenatedNodes))
            if targetNodeIndex >= adjacentForm.count {
                adjacentForm.append(adjacentTuple)
            } else {
                adjacentForm[targetNodeIndex] = adjacentTuple
            }
        }

        // Process the orphan nodes
        adjacentForm.append(contentsOf: orphanNodes.map { ($0.value, nil) })
        return adjacentForm.map { ($0.0, $0.1) }
    }

    func findPaths(from: T, to: T, withEdges filteredEdges: [Edge]? = nil) -> [[T]] {
        var paths = [[T]]()

        let edgesToTraverse = filteredEdges ?? edges

        for edge in edgesToTraverse {
            guard edge.from.value == from else {
                continue
            }

            if edge.to.value == to {
                paths.append([edge.from.value, edge.to.value])
            } else {
                let subAcyclicEdges = edgesToTraverse.filter { $0.to.value != from }
                var subpaths = findPaths(from: edge.to.value, to: to, withEdges: subAcyclicEdges)
                guard subpaths.isEmpty == false else {
                    continue
                }

                let first = subpaths.remove(at: 0)
                let insertionList = [edge.from.value] + first
                subpaths.insert(insertionList, at: 0)
                paths += subpaths
            }
        }

        return paths.filter { !$0.isEmpty }
    }

    func findCycles(from: T) -> [[T]]? {
        guard let node = edges.first(where: { $0.from.value == from })?.from else {
            return nil
        }

        let targets = Set(node.adjacentEdges.compactMap {
            edgeTarget($0, node: node)?.value
        })

        var paths = targets.flatMap { findPaths(from: $0, to: from) }.map { [from] + $0 }

        if type(of: self).isDirected == false {
            paths += targets
            .compactMap { findPaths(from: from, to: $0) }
            .flatMap { $0 }
            .map { $0 + [from] }

            paths += paths.map {
                $0.reversed()
            }
        }

        return paths
            .filter { $0.count > 3 }
            .reversed()
    }

    func degree(forNodeWithValue value: T) -> Int {
        return nodes.first(where: {
            $0.value == value
        })?.degree ?? 0
    }

    func nodesByDegree(strict: Bool = false) -> [Node] {
        return nodes.sorted(by: { one, two -> Bool in
            if strict {
                return one.degree > two.degree
            }

            return one.degree >= two.degree
        })
    }

    func depthFirstTraversalFrom(node: T) -> [T]? {
        return nodes.first(where: { $0.value == node })?.nodesByDepth(Set()).map { $0.value }.reversed()
    }

    func split() -> [Graph<T, U>] {
        func findConnected(within potentials: [Node], cache: [Node]) -> [Node] {
            guard let (head, tails) = potentials.splitHeadAndTails() else {
                return cache
            }

            let tail = Set(tails)
            let new = head.partners.subtracting(cache + [head])
            let union = tail.union(new)

            return findConnected(within: Array(union), cache: cache + [head])
        }

        func splitRecursive(remaining: [Node]) -> [Graph<T, U>] {
            guard let head = remaining.first else {
                return []
            }

            let connectedNodes = findConnected(within: [head], cache: [])
            let adjacent = adjacentForm(from: connectedNodes)

            return [adjacent] + splitRecursive(remaining: remaining.removingAllContained(in: connectedNodes))
        }

        return splitRecursive(remaining: nodes)
    }

    func spanningTrees() -> [Graph<T, U>] {
        func spanningTreesRecursive(edges _edges: [Edge], nodes _nodes: [Node], treeEdges: [Edge] = []) -> [Graph<T, U>] {
            guard _nodes.isEmpty == false else {
                return [Graph<T, U>(nodes: nodes.map { $0.value }, edges: treeEdges.map { ($0.from.value, $0.to.value) })]
            }

            guard _edges.isEmpty == false else {
                return []
            }

            let connectedEdges = _edges.filter { $0.connects(to: _nodes) }
            return connectedEdges.flatMap { edge -> [Graph<T, U>] in
                spanningTreesRecursive(edges: _edges.removingAllContained(in: [edge]).reversed(),
                                       nodes: Array(_nodes.dropLast()),
                                       treeEdges: [edge] + treeEdges)
            }
        }

        guard type(of: self).isDirected == false else {
            // No spanning trees for directed graphs.
            return []
        }

        return spanningTreesRecursive(edges: edges.reversed(), nodes: Array(nodes.dropLast()))
    }

    func minimalSpanningTree() -> Graph<T, U>? {
        func minimalSpanningTreeRecursive(nodes gNodes: [Node], edges gEdges: [Edge], treeEdges: [Edge] = []) -> Graph<T, U>? {
            guard gNodes.isEmpty == false else {
                return Graph<T, U>(nodes: nodes.map { $0.value }, labeledEdges: treeEdges.map { ($0.from.value, $0.to.value, $0.label) })
            }

            let connectedEdges = gEdges.filter { $0.connects(to: gNodes) }
            guard let firstConnectedEdge = connectedEdges.first else {
                return nil
            }

            let nEdge = connectedEdges.reduce(firstConnectedEdge) {
                // swiftlint:disable force_unwrapping
                let (first, second) = ($0.label!, $1.label!)
                // swiftlint:enable force_unwrapping
                return first < second ? $0 : $1
            }

            return minimalSpanningTreeRecursive(nodes: gNodes.filter { edgeTarget(nEdge, node: $0) != nil },
                                                edges: gEdges.removingAllContained(in: [nEdge]),
                                                treeEdges: [nEdge].compactMap { $0 } + treeEdges)
        }

        guard edges.map({ $0.label }).allNotNil() else {
            // Provided a graph with edges that do not all have labels -- invalid
            return nil
        }

        return minimalSpanningTreeRecursive(nodes: Array(nodes.dropLast()), edges: edges)
    }

    func coloredNodes() -> [(T, Int)]? {
        func computeColor(_ color: Int, uncolored: [Node], colored: [(Node, Int)], adjacent: Set<Node> = Set()) -> [(Node, Int)] {
            guard let current = uncolored.first else {
                return colored
            }

            let newAdjacent = adjacent.union(current.neighbors)

            return computeColor(color,
                                uncolored: uncolored.dropFirst().removingAllContained(in: newAdjacent),
                                colored: [(current, color)] + colored,
                                adjacent: newAdjacent)
        }

        func coloredNodesRecursive(_ color: Int, uncolored: [Node], colored: [(Node, Int)] = []) -> [(Node, Int)] {
            guard uncolored.isEmpty == false else {
                return colored
            }

            let newColored = computeColor(color, uncolored: uncolored, colored: colored)
            let newUncolored = uncolored.removingAllContained(in: newColored.map { $0.0 })

            return coloredNodesRecursive(color + 1, uncolored: newUncolored, colored: newColored)
        }

        return coloredNodesRecursive(1, uncolored: nodesByDegree(strict: true)).map { ($0.value, $1) }
    }

    func isBipartite() -> Bool {
        return split().allSatisfy { $0.isGraphBipartite() }
    }

    func DOTRepresentation() -> String {
        let directed = type(of: self).isDirected
        let spacer = "    "
        let identifier = "\(directed ? "di" : "")graph"
        let edgeJoiner = directed ? "->" : "--"
        let edgeDescriptions = edges.map { edge -> String in
            var components = [
                edge.from.value.description,
                edgeJoiner,
                edge.to.value.description
            ]

            if let label = edge.label {
                components.append("[label=\(label.description)]")
            }

            return spacer + components.joined(separator: " ")
        }

        var dotDataComponents = edgeDescriptions
        let completelyOrphaned = completelyOrphanedNodes
        if completelyOrphaned.isEmpty == false {
            dotDataComponents.append(completelyOrphaned.map { spacer + $0.value.description }.joined(separator: "\n"))
        }

        return """
        \(identifier) G {
        \(dotDataComponents.joined(separator: "\n"))
        }
        """
    }

    // MARK: Private Functions
    // MARK: -

    private var completelyOrphanedNodes: [Node] {
        let edgeNodes = edges.flatMap { [$0.from, $0.to] }
        return nodes.filter { edgeNodes.contains($0) == false }
    }

    private func isGraphBipartite() -> Bool {
        func isBipartiteRecursive(oddPending: [Node],
                                  evenPending: [Node],
                                  oddVisited: Set<Node> = Set(),
                                  evenVisited: Set<Node> = Set()) -> Bool {
            switch (evenPending, oddPending) {
            case (_, let odd) where !odd.isEmpty:
                let oddHead = odd[0]

                return oddHead.partners.allNotContained(in: oddVisited) &&
                    isBipartiteRecursive(oddPending: Array(odd.dropFirst()),
                                         evenPending: oddHead.partners.removingAllContained(in: evenVisited),
                                         oddVisited: oddVisited.union([oddHead]),
                                         evenVisited: evenVisited.union(oddHead.partners))
            case (let even, _) where !even.isEmpty:
                let evenHead = even[0]

                return evenHead.partners.allNotContained(in: evenVisited) &&
                    isBipartiteRecursive(oddPending: evenHead.partners.removingAllContained(in: oddVisited),
                                         evenPending: Array(even.dropFirst()),
                                         oddVisited: oddVisited.union(evenHead.partners),
                                         evenVisited: evenVisited.union([evenHead]))
            default:
                return oddPending.isEmpty && evenPending.isEmpty
            }
        }

        return isBipartiteRecursive(oddPending: [], evenPending: nodesByDegree())
    }

    private func adjacentForm(from nodes: [Node]) -> Self {
        return .init(adjacentLabeledList: nodes.map { n in
            (n.value, n.adjacentEdges.compactMap { e in
                guard let target = edgeTarget(e, node: n) else {
                    return nil
                }

                return (target.value, e.label)
            })
        })
    }
}

extension Graph.Node {
    var partners: Set<Graph.Node> {
        return Set(adjacentEdges.compactMap {
            $0.partner(for: self)
        })
    }

    func nodesByDepth(_ seen: Set<Graph.Node>) -> [Graph.Node] {
        func nodesByDepthRecursive(neighbors: [Graph.Node], set: Set<Graph.Node>) -> [Graph.Node] {
            guard let head = neighbors.first else {
                return []
            }

            let tail = Array(neighbors.dropFirst())

            guard set.contains(head) == false else {
                return nodesByDepthRecursive(neighbors: tail, set: set).reversed()
            }

            let subnodes = head.nodesByDepth(set)
            return subnodes + nodesByDepthRecursive(neighbors: tail, set: set.union(subnodes))
        }

        let neighbors = self.neighbors
        guard neighbors.isEmpty == false else {
            return []
        }

        let newSet = Set([self]).union(seen)
        return [self] + nodesByDepthRecursive(neighbors: neighbors, set: newSet)
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
        private var _nodeCache: [T: Node]

        // To track the edges we've already added to prevent against duplicates
        private var _allEdges = Set<String>()

        private let _edgeGenerationMode: EdgeGenerationMode

        init(graph: Graph, nodes: [T]) {
            graph.nodes = nodes.map { Node(value: $0) }

            _edgeSeparator = type(of: graph).humanFriendlyEdgeSeparator
            _edgeGenerationMode = EdgeGenerationMode(direction: type(of: graph).direction)
            _nodeCache = type(of: self)._generateNodeCache(graph.nodes)
        }

        mutating func generateEdge(`for` nodePair: (T, T), label: U?) -> Edge? {
            let (from, to) = (_node(forValue: nodePair.0), _node(forValue: nodePair.1))
            let nodeValues = [from, to].map { "\($0.value)" }
            var edgeStrings = [nodeValues.joined(separator: _edgeSeparator)]

            // Generate the reverse edge as well in an indirected graph.
            if case EdgeGenerationMode.enforcingSymmetry = _edgeGenerationMode {
                edgeStrings.append(nodeValues.reversed().joined(separator: _edgeSeparator))
            }

            guard _allEdges.isDisjoint(with: edgeStrings) else {
                return nil
            }

            edgeStrings.forEach { _allEdges.insert($0) }

            let edge = Edge(from: from, to: to, label: label)
            from.adjacentEdges = [edge] + from.adjacentEdges
            to.adjacentEdges = [edge] + to.adjacentEdges

            return edge
        }

        private mutating func _node(forValue value: T) -> Node {
            // swiftlint:disable force_unwrapping
            return _nodeCache[value]!
            // swiftlint:enable force_unwrapping
        }

        private static func _generateNodeCache(_ nodes: [Node]) -> [T: Node] {
            return nodes.reduce([T: Node]()) { res, node -> [T: Node] in
                var r = res
                r[node.value] = node
                return r
            }
        }
    }

    convenience init(nodes n: [T], edges e: [(T, T)]) {
        self.init(nodes: n, labeledEdges: e.map { ($0.0, $0.1, nil) })
    }

    convenience init(nodes n: [T], labeledEdges: [(T, T, U?)]) {
        self.init()

        var helper = GraphInitializationHelper(graph: self, nodes: n)
        edges = labeledEdges.compactMap { helper.generateEdge(for: ($0.0, $0.1), label: $0.2) }
    }

    convenience init(adjacentList list: [(T, [T]?)]) {
        self.init(adjacentLabeledList: list.map { ($0.0, $0.1?.map { ($0, nil) }) })
    }

    convenience init?(string: String) {
        self.init()

        guard string.first == "[", string.last == "]" else {
            return nil
        }

        // Create a string without the leading and trailing brackets.
        let truncatedEdgeString = string.dropFirst().dropLast().trimmingCharacters(in: .whitespaces)
        let edgeComponents = truncatedEdgeString.components(separatedBy: ",")
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
                .removingAllContained(in: a)
                .forEach { a.append($0) }

            return a
        }

        var helper = GraphInitializationHelper(graph: self, nodes: nodes)
        edges = edgeInfoTuples
            .filter { $0.1 != nil }
            .compactMap { helper.generateEdge(for: ($0.0, $0.1!), label: $0.2) }
    }

    private func _parseEdgeComponent(_ edgeComponent: String) -> (T, T?, U?)? {
        let separator = type(of: self).humanFriendlyEdgeSeparator

        func findLabel(`in` string: String) -> (U?, Int?) {
            var label: U?
            var position: Int?

            if let labelPosition = string.scan(for: { $0 == "/" }) {
                let foundLabel = string[labelPosition + 1..<string.count]

                if let createdLabel = U(foundLabel) {
                    label = createdLabel
                    position = labelPosition
                }
            }

            return (label, position)
        }

        // Parse separators.
        guard edgeComponent.scan(for: { $0 == Character(separator) }) != nil else {
            let otherGraphType = type(of: self).isDirected ? Graph<T, U>.self : Digraph<T, U>.self
            let otherSeparator = otherGraphType.humanFriendlyEdgeSeparator
            if edgeComponent.isEmpty || edgeComponent.contains(otherSeparator) {
                return nil
            }

            guard let from = T(edgeComponent.trimmingCharacters(in: .whitespaces)) else {
                return nil
            }

            return (from: from, to: nil, label: findLabel(in: edgeComponent).0)
        }

        let components = edgeComponent.components(separatedBy: separator).map {
            $0.trimmingCharacters(in: .whitespaces)
        }

        guard components.count == 2, let bookends = components.bookends() else {
            return nil
        }

        var (fromNodeValue, toNodeValue) = bookends
        let (label, labelPositionOptional) = findLabel(in: toNodeValue)

        if let position = labelPositionOptional {
            toNodeValue = toNodeValue[0..<position]
        }

        guard let concreteFromValue = T(fromNodeValue) else {
            return nil
        }

        let concreteToValue = T(toNodeValue)
        return (from: concreteFromValue, to: concreteToValue, label: label)
    }

    private func _parseEdgeComponents(_ edgeComponents: [String]) -> [(T, T?, U?)] {
        let results = edgeComponents.map { _parseEdgeComponent($0) }

        guard results.allNotNil() else {
            return []
        }

        return results.compactMap { $0 }
    }
}

class Digraph<T: GraphValueTypeConstraint, U: GraphLabelTypeConstraint>: Graph<T, U> {
    override class var direction: Direction { return .Directed }
    override class var humanFriendlyEdgeSeparator: String { return ">" }
}

extension Graph: Equatable where T: Equatable {
    static func == (lhs: Graph, rhs: Graph) -> Bool {
        return lhs.description == rhs.description
    }
}

extension Graph: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(Set(nodes))
        hasher.combine(Set(edges))
    }
}

extension Graph.Node: Equatable where T: Equatable {
    static func == (lhs: Graph.Node, rhs: Graph.Node) -> Bool {
        return lhs.value == rhs.value && lhs.degree == rhs.degree
    }
}

extension Graph.Edge: Equatable where T: Equatable, U: Equatable {
    static func == (lhs: Graph.Edge, rhs: Graph.Edge) -> Bool {
        return lhs.from.value == rhs.from.value && lhs.to.value == rhs.to.value && lhs.label == rhs.label
    }
}

extension Graph.Edge: Hashable where U: Equatable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(description)
    }
}

extension Graph.Node: CustomStringConvertible {
    var description: String {
        return "Graph.Node(value: \(value))"
    }
}

extension Graph.Edge: CustomStringConvertible {
    var description: String {
        let components = [
            "from": Optional(from.description),
            "to": Optional(to.description),
            "label": label?.description]
            .compactMapValues { $0 }
            .map { "\($0.key): \($0.value)" }
        return "Graph.Edge(\(components.joined(separator: ", ")))"
    }
}
