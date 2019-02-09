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
        let value: U

        init(from: Node, to: Node, value: U) {
            self.from = from
            self.to = to
            self.value = value
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
    convenience init(nodes n: List<T>, edges e: List<(T, T)>) {
        self.init()

        nodes = n.map { Node(value: $0) }.toList()

        let nodesKeyedByValues = nodes!.reduce([T:Node]()) { (res, node) -> [T:Node] in
            var r = res
            r[node.value] = node
            return r
        }

        func node(forValue value: T) -> Node? {
            return nodesKeyedByValues[value]
        }

        // To track the edges we've already added to prevent against duplicates
        var allEdges = Set<String>()

        edges = e.compactMap {
            guard let from = node(forValue: $0.0), let to = node(forValue: $0.1) else {
                return nil
            }

            let nodeValues = [from, to].map { "\($0.value)" }
            var edgeStrings = [nodeValues.joined(separator: "-")]
            if type(of: self).direction == .Indirected {
                edgeStrings.append(nodeValues.reversed().joined(separator: "-"))
            }

            guard edgeStrings.allSatisfy({ allEdges.contains($0) == false }) else {
                return nil
            }

            edgeStrings.forEach { allEdges.insert($0) }
            return Edge(from: from, to: to, value: 0)
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
        return "Graph.Edge(from: \(from.description)), to: \(to.description), value: \(value))"
    }
}
