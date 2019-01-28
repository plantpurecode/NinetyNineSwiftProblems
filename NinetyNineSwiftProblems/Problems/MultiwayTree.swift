//
//  MultiwayTree.swift
//  NinetyNineSwiftProblems
//
//  Created by Jacob Relkin on 1/28/19.
//  Copyright © 2019 Jacob Relkin. All rights reserved.
//

import Foundation

class MTree<T> {
    let value: T
    var children: List<MTree<T>>?

    init(_ value: T, _ children: List<MTree<T>>? = nil) {
        self.value = value
        self.children = children
    }
}

// MARK: - Computed Properties
extension MTree {
    var nodeCount: Int {
        return 1 + (children?.values ?? [MTree<T>]()).reduce(0) { res, child in
            return res + child.nodeCount
        }
    }

    var internalPathLength: Int {
        return (children?.values ?? []).reduce(0) { res, node in
            return res + node.internalPathLength + node.nodeCount
        }
    }
}

// MARK: - Construct an MTree from a string

extension MTree where T == String {
    convenience init?(string: String) {
        guard string.isEmpty == false else {
            return nil
        }

        func nextPosition(fromPosition position: Int, atNestingLevel nesting: Int) -> Int {
            guard nesting > 0, position < string.count else {
                return position
            }

            func nextNestingOffset() -> Int {
                let characterAtPosition = string.suffix(from: string.index(string.startIndex, offsetBy: position)).prefix(1)
                return characterAtPosition == "^" ? -1 : 1
            }

            return nextPosition(fromPosition: position + 1, atNestingLevel: nesting + nextNestingOffset())
        }

        func extractChildren(atPosition position: Int) -> [String] {
            guard position < string.count - 1 else {
                return []
            }

            let endPosition = nextPosition(fromPosition: position + 1, atNestingLevel: 1)
            let substring = String(string[string.index(string.startIndex, offsetBy: position)..<string.index(string.startIndex, offsetBy: endPosition - 1)])

            return [substring] + extractChildren(atPosition: endPosition)
        }

        let children = extractChildren(atPosition: 1).compactMap { MTree(string: $0) }
        self.init(String(string.prefix(1)), List(children))
    }
}

// MARK: - CustomStringConvertible Conformance

extension MTree : CustomStringConvertible where T : CustomStringConvertible {
    var description: String {
        return description()
    }

    private func description(at depth: Int = 0) -> String {
        let suffix = depth == 0 && children?.length ?? 0 > 0 ? "^" : ""

        return [value.description,
                children?.map { $0.description(at: depth + 1) + "^" }.joined() ?? "",
                suffix].joined()
    }
}

// MARK: - Equatable Conformance

extension MTree : Equatable where T : Equatable, T : CustomStringConvertible {
    static func ==(tree: MTree, otherTree: MTree) -> Bool {
        return tree.description == otherTree.description
    }
}
