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

    var postOrder: List<T> {
        return List((children?.values ?? []).flatMap { $0.postOrder.values } + [value])!
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

// MARK: - Lisp-y String Representations

extension MTree where T : CustomStringConvertible {
    var lispyRepresentation: String {
        guard let children = children else {
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
        guard lispyRepresentation.count > 0 else {
            return nil
        }

        func nestingOffset(for character: Character) -> Int {
            switch character {
            case "(": return 1
            case ")": return -1
            default: return 0
            }
        }

        func nextSpace(at position: Int, nestingLevel nesting: Int) -> Int? {
            guard position < lispyRepresentation.count else {
                return nil
            }

            let character = lispyRepresentation.character(atIndex: position)
            switch character {
            case " " where nesting == 0, ")" where nesting == 0:
                return position
            default:
                return nextSpace(at: position + 1, nestingLevel: nesting + nestingOffset(for: character))
            }
        }

        func nextNonSpace(at position: Int) -> Int? {
            guard position < lispyRepresentation.count else {
                return nil
            }

            let character = lispyRepresentation.character(atIndex: position)
            guard character != " " else {
                return nextNonSpace(at: position + 1)
            }

            return position
        }

        func substrings(at position: Int) -> [String] {
            let character = lispyRepresentation.character(atIndex: position)
            if position > lispyRepresentation.count || character == ")" {
                return []
            }

            guard let endPosition = nextSpace(at: position, nestingLevel: 0) else {
                return []
            }

            let startIndex = lispyRepresentation.index(lispyRepresentation.startIndex, offsetBy: position)
            let endIndex = lispyRepresentation.index(lispyRepresentation.startIndex, offsetBy: endPosition)
            let substring = String(lispyRepresentation[startIndex..<endIndex])
            let nextNonSpaceIndex = nextNonSpace(at: endPosition)
            let endCharacter = lispyRepresentation.character(atIndex: endPosition)

            return [substring] + ((endCharacter != ")" && nextNonSpaceIndex != nil) ? substrings(at: nextNonSpaceIndex!) : [])
        }

        guard lispyRepresentation.character(atIndex: 0) == "(" else {
            self.init(String(lispyRepresentation.character(atIndex: 0)))
            return
        }

        guard let nextSpaceIndex = nextSpace(at: 1, nestingLevel: 0), let nextNonSpaaceIndex = nextNonSpace(at: nextSpaceIndex) else {
            return nil
        }

        let value = lispyRepresentation[lispyRepresentation.index(lispyRepresentation.startIndex, offsetBy: 1)..<lispyRepresentation.index(lispyRepresentation.startIndex, offsetBy: nextSpaceIndex)]
        self.init(String(value), List(substrings(at: nextNonSpaaceIndex).compactMap { MTree(fromLispyRepresentation:$0) }))

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

extension String {
    func character(atIndex index: Int) -> Character {
        return self[self.index(startIndex, offsetBy: index)]
    }
}
