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
    private (set) var children: [MTree<T>] = []

    init(_ value: T, _ children: [MTree<T>] = []) {
        self.value = value
        self.children = children
    }
}

// MARK: - Computed Properties
extension MTree {
    var nodeCount: Int {
        children.reduce(1) { $0 + $1.nodeCount }
    }

    var internalPathLength: Int {
        children.reduce(0) { $0 + $1.internalPathLength + $1.nodeCount }
    }

    var postOrder: [T] {
        children.flatMap { $0.postOrder } + [value]
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
                return string[position] == "^" ? -1 : 1
            }

            return nextPosition(fromPosition: position + 1, atNestingLevel: nesting + nextNestingOffset())
        }

        func extractChildren(atPosition position: Int) -> [String] {
            guard position < string.count - 1 else {
                return []
            }

            let endPosition = nextPosition(fromPosition: position + 1, atNestingLevel: 1)
            let substring = string[position..<endPosition - 1]

            return [substring] + extractChildren(atPosition: endPosition)
        }

        let children = extractChildren(atPosition: 1).compactMap { MTree(string: $0) }
        self.init(String(string.prefix(1)), children)
    }
}

// MARK: - Lisp-y String Representations

extension MTree where T: CustomStringConvertible {
    var lispyRepresentation: String {
        guard children.isEmpty == false else {
            return value.description
        }

        return [
            "(",
            value.description,
            " ",
            children.map { $0.lispyRepresentation }.joined(separator: " "),
            ")"
        ].joined()
    }
}

extension MTree where T == String {
    convenience init?(fromLispyRepresentation lispyRepresentation: String) {
        guard lispyRepresentation.isEmpty == false else {
            return nil
        }

        func nextSpace(at position: Int, nestingLevel nesting: Int = 0) -> Int? {
            func nestingOffset(for character: Character) -> Int {
                switch character {
                case "(": return 1
                case ")": return -1
                default: return 0
                }
            }

            guard position < lispyRepresentation.count else {
                return nil
            }

            let character = Character(lispyRepresentation[position])

            switch character {
            case " " where nesting == 0,
                 ")" where nesting == 0:
                return position
            default:
                return nextSpace(at: position + 1, nestingLevel: nesting + nestingOffset(for: character))
            }
        }

        func nextNonSpace(at position: Int) -> Int? {
            return lispyRepresentation.scan(for: { $0 != " " }, fromIndex: position)
        }

        func nextSubstring(at position: Int) -> String? {
            let character = lispyRepresentation[position]

            guard position < lispyRepresentation.count,
                character !=  ")",
                let endPosition = nextSpace(at: position) else {
                return nil
            }

            return lispyRepresentation[position..<endPosition]
        }

        let firstChar = lispyRepresentation[0]

        guard firstChar == "(" else {
            guard firstChar != " ", firstChar != ")" else {
                return nil
            }

            self.init(String(lispyRepresentation.prefix(1)))
            return
        }

        guard
            let nextSpaceIndex = nextSpace(at: 1),
            let nextNonSpaceIndex = nextNonSpace(at: nextSpaceIndex) else {
            return nil
        }

        let value = lispyRepresentation[1..<nextSpaceIndex].trimmingCharacters(in: .whitespaces)

        guard value.isEmpty == false,
            let next = nextSubstring(at: nextNonSpaceIndex) else {
            return nil
        }

        self.init(String(value), [MTree(fromLispyRepresentation: next)].compactMap { $0 })
    }
}

// MARK: - CustomStringConvertible Conformance

extension MTree: CustomStringConvertible where T: CustomStringConvertible {
    var description: String {
        return description()
    }

    private func description(at depth: Int = 0) -> String {
        let suffix = depth == 0 && children.isEmpty == false ? "^" : ""

        return [value.description,
                children.map { $0.description(at: depth + 1) + "^" }.joined(),
                suffix].joined()
    }
}

// MARK: - Equatable Conformance

extension MTree: Equatable where T: Equatable, T: CustomStringConvertible {
    static func == (tree: MTree, otherTree: MTree) -> Bool {
        return tree.description == otherTree.description
    }
}
