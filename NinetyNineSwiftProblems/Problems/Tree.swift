//
//  Tree.swift
//  NinetyNineSwiftProblems
//
//  Created by Jacob Relkin on 12/14/18.
//  Copyright © 2019 Jacob Relkin. All rights reserved.
//

import Foundation

// MARK: Tree Data Structure -

class Tree<T> {
    let value: T
    var left: Tree<T>?
    var right: Tree<T>?

    init(_ value: T, _ left: Tree<T>? = nil, _ right: Tree<T>? = nil) {
        self.value = value
        self.left = left
        self.right = right
    }
}

// MARK: - CustomStringConvertible Conformance

extension Tree: CustomStringConvertible {
    var description: String {
        let joinedChildDescriptions = [left?.description ?? "", right?.description ?? ""].joined(separator: ",")
        let childValueDescription = isLeaf == false ? "(\(joinedChildDescriptions))" : ""
        var selfDescription = "\(value)"
        if let this = self as? PositionedTree {
            selfDescription += "{x: \(this.x), y: \(this.y)}"
        }

        return "\(selfDescription)\(childValueDescription)"
    }
}

// MARK: - Tree Factories

extension Tree {
    class func makeBalancedTrees(nodes n: Int, value: T) -> [Tree<T>] {
        _makeBalancedTrees(nodes: n, value: value)
    }

    class func makeSymmetricBalancedTrees(nodes n: Int, value: T) -> [Tree<T>] {
        _makeBalancedTrees(nodes: n, value: value).filter { $0.symmetric }
    }

    class func makeHeightBalancedTrees(height: Int, value: T) -> [Tree<T>] {
        _makeHeightBalancedTrees(height: height, value: value)
    }

    class func makeHeightBalancedTrees(nodes: Int, value: T) -> [Tree<T>] {
        _makeHeightBalancedTrees(nodes: nodes, value: value)
    }

    class func makeCompleteTree(nodes: Int, value: T) -> Tree<T>? {
        guard nodes > 0 else {
            return nil
        }

        func generate(index: Int) -> Tree<T>? {
            guard index <= nodes else {
                return nil
            }

            return Tree(value, generate(index: 2 * index), generate(index: 2 * index + 1))
        }

        return generate(index: 1)
    }
}

// MARK: - Computed Properties

extension Tree {
    var isLeaf: Bool {
        [left, right].compactMap { $0 }.isEmpty
    }

    var leafCount: Int {
        (isLeaf ? 1 : 0) + (left?.leafCount).orZero + (right?.leafCount).orZero
    }

    var leaves: [T] {
        guard isLeaf == false else {
            return [value]
        }

        return [left, right].compactMap { $0 }.reduce([T]()) {
            $0 + $1.leaves
        }
    }

    var nodeCount: Int {
        1 + (left?.nodeCount ?? 0) + (right?.nodeCount ?? 0)
    }

    var height: Int {
        1 + Swift.max(leftHeight, rightHeight)
    }

    var leftHeight: Int {
        (left?.height).orZero
    }

    var rightHeight: Int {
        (right?.height).orZero
    }

    var heightBalanced: Bool {
        _heightDifferential <= 1
    }

    var completelyBalanced: Bool {
        !(_nodeCountDifferential > 1)
    }

    var symmetric: Bool {
        guard isLeaf == false else {
            return true
        }

        guard let left = left, let right = right else {
            return false
        }

        return left.isMirror(of: right)
    }

    var internalNodes: [T] {
        guard isLeaf == false else {
            return []
        }

        let successorNodes = [left, right].compactMap { $0 }.filter { !$0.isLeaf }
        let prefix = successorNodes.isEmpty == false ? [value] : [T]()
        let internalNodes = prefix +
            successorNodes.map({ $0.value }) +
            successorNodes.flatMap({ $0.internalNodes })

        return internalNodes
    }

    // MARK: Traversal

    var preOrder: [T] {
        _preOrder
    }

    var inOrder: [T] {
        _inOrder
    }

    var postOrder: [T] {
        _postOrder
    }
}

// MARK: - Functions

extension Tree {
    // MARK: Layout

    func layoutBinaryTree() -> PositionedTree<T>? {
        guard isLeaf == false else {
            return nil
        }

        return _layoutBinaryTreeInternal(x: 1, depth: 1).0
    }

    func layoutBinaryTree2() -> PositionedTree<T>? {
        guard isLeaf == false else {
            return nil
        }

        let d = _depth
        let x0 = (2..._leftmostDepth).map { 2 ^^ (d - $0) }.reduce(1, +)

        return _layoutBinaryTree2Internal(x: x0, depth: 1, exp: d - 2)
    }

    func layoutBinaryTree3() -> PositionedTree<T>? {
        guard isLeaf == false else {
            return nil
        }

        let x = (_bounds.map { $0.0 }.reduce(Int.max - 1, Swift.min) * -1) + 1
        return _layoutBinaryTree3Internal(x: x, depth: 1)
    }

    // MARK: -

    func isMirror(of tree: Tree) -> Bool {
        // Are these both leaves?
        if isLeaf, tree.isLeaf {
            return true
        }

        let nodePairs = [
            [left, tree.right],
            [right, tree.left]
        ]

        return nodePairs.allSatisfy { nodePair in
            let bothNil = nodePair.allNil()
            let areMirrors = { () -> Bool in
                guard let (f, l) = nodePair.bookends(), let first = f, let last = l else {
                    return false
                }

                return first.isMirror(of: last)
            }()

            return bothNil || areMirrors
        }
    }

    func nodes(atLevel level: Int) -> [T] {
        switch level {
        case level where level < 1:
            return []
        case 1:
            return [value]
        default:
            let leftNodes = left?.nodes(atLevel: level - 1) ?? []
            let rightNodes = right?.nodes(atLevel: level - 1) ?? []

            return leftNodes + rightNodes
        }
    }
}

// MARK: - Comparable

extension Tree where T: Comparable {
    convenience init?(list: [T]) {
        guard let first = list.first else {
            return nil
        }

        let tree = Tree<T>(first)
        list.dropFirst().forEach {
            _ = tree.insert(value: $0)
        }

        self.init(tree.value, tree.left, tree.right)
    }

    func insert(value v: T) -> Tree {
        if v < value {
            if let left = left {
                _ = left.insert(value: v)
            } else {
                left = Tree(v)
            }
        } else if v > value {
            if let right = right {
                _ = right.insert(value: v)
            } else {
                right = Tree(v)
            }
        }

        return self
    }
}

// MARK: - Equatable

extension Tree: Equatable where T: Equatable {
    static func == (lhs: Tree, rhs: Tree) -> Bool {
        lhs.value == rhs.value && lhs.right == rhs.right && lhs.left == rhs.left
    }
}

// MARK: - String-based Tree Initialization

extension Tree where T == String {
    convenience init?(string: String) {
        guard let first = string.first else {
            return nil
        }

        func extractTreeString(_ s: String, start: Int, end: Character) -> (string: String, commaPosition: Int) {
            func endOfString(position: Int, nesting: Int) -> Int {
                let charAtThisPosition = s[s.index(s.startIndex, offsetBy: position)]

                func nestingOffset() -> Int {
                    switch charAtThisPosition {
                    case "(": return 1
                    case ")": return -1
                    default: return 0
                    }
                }

                if charAtThisPosition == end, nesting == 0 {
                    return position
                }

                return endOfString(position: position + 1, nesting: nesting + nestingOffset())
            }

            let strEnd = endOfString(position: start, nesting: 0)
            let treeString = String(s[s.index(s.startIndex, offsetBy: start)..<s.index(s.startIndex, offsetBy: strEnd)])
            return (treeString, strEnd)
        }

        guard string.count > 1 else {
            self.init(String(first))
            return
        }

        let (left, commaPosition) = extractTreeString(string, start: 2, end: ",")
        let (right, _) = extractTreeString(string, start: commaPosition + 1, end: ")")

        self.init(String(first), Tree(string: left), Tree(string: right))
    }
}

// MARK: - Traversal Based Tree Initialization

extension Tree where T: Comparable {
    convenience init?(preOrder po: [T], inOrder io: [T]) {
        guard po.isEmpty == false, io.isEmpty == false,
            let tree = Tree<T>._makeTraversalBasedTree(preOrder: po, inOrder: io, preStart: 0, preEnd: po.count - 1, inStart: 0, inEnd: io.count - 1) else {
            return nil
        }

        self.init(tree.value, tree.left, tree.right)
    }
}

// MARK: - Dotstring Support

extension Tree where T: CustomStringConvertible {
    var dotString: String {
        [value.description, left?.dotString, right?.dotString].map {
            guard let string = $0 else {
                return "."
            }

            return string
        }.joined()
    }
}

extension Tree where T == Character {
    convenience init?(dotString: String) {
        guard dotString.trimmingCharacters(in: .whitespaces).isEmpty == false else {
            return nil
        }

        func buildTree(atPosition position: Int) -> (Tree<T>?, Int) {
            let character = dotString[position]
            guard character != "." else {
                return (nil, position + 1)
            }

            let (left, leftPosition) = buildTree(atPosition: position + 1)
            let (right, rightPosition) = buildTree(atPosition: leftPosition)

            return (Tree(Character(character), left, right), rightPosition)
        }

        guard let tree = buildTree(atPosition: 0).0 else {
            return nil
        }

        self.init(tree.value, tree.left, tree.right)
    }
}

// MARK: - Sequence Conformance

extension Tree: Sequence {
    struct TreeIterator: IteratorProtocol {
        typealias Element = T

        enum Kind {
            case preOrder
            case inOrder
            case postOrder
        }

        let elements: [T]

        init(_ tree: Tree, kind: Kind = .inOrder) {
            switch kind {
            case .preOrder:
                elements = tree.preOrder
            case .inOrder:
                elements = tree.inOrder
            case .postOrder:
                elements = tree.postOrder
            }
        }

        var index = 0

        mutating func next() -> T? {
            guard index < elements.endIndex else {
                return nil
            }

            let next = elements[index]
            index += 1
            return next
        }
    }

    func makeIterator() -> TreeIterator {
        TreeIterator(self)
    }

    func makeIterator(ofKind kind: TreeIterator.Kind) -> TreeIterator {
        TreeIterator(self, kind: kind)
    }
}

// MARK: - Layout-Specific Tree Subclass

class PositionedTree<T>: Tree<T> {
    var x: Int
    var y: Int

    init(x: Int, y: Int, value: T, _ left: Tree<T>? = nil, _ right: Tree<T>? = nil) {
        self.x = x
        self.y = y
        super.init(value, left, right)
    }
}

// MARK: - Private

extension Tree {
    // MARK: Traversal

    private var _preOrder: [T] {
        [value] + (left?._preOrder ?? []) + (right?._preOrder ?? [])
    }

    private var _inOrder: [T] {
        (left?._inOrder ?? []) + [value] + (right?._inOrder ?? [])
    }

    private var _postOrder: [T] {
        (left?._postOrder ?? []) + (right?._postOrder ?? []) + [value]
    }

    // MARK: Layout

    private var _depth: Int {
        Swift.max(left?._depth ?? 0, right?._depth ?? 0) + 1
    }

    private var _leftmostDepth: Int {
        (left?._leftmostDepth ?? 0) + 1
    }

    private var _bounds: [(Int, Int)] {
        func fullInnerBounds(lb: [(Int, Int)], rb: [(Int, Int)]) -> [(Int, Int)] {
            let shift = zip(lb, rb).map {
                (($0.0.1 - $0.1.0) / 2) + 1
            }.reduce(0, Swift.max)

            return zipAll(left: lb.map { Optional($0) }, right: rb.map { Optional($0) }, defaultValue: nil).compactMap {
                let tuple = $0

                if let l = tuple.0, let r = tuple.1 {
                    return (l.0 - shift, r.1 + shift)
                } else if let l = tuple.0 {
                    return (l.0 - shift, l.1 - shift)
                } else if let r = tuple.1 {
                    return (r.0 + shift, r.1 + shift)
                }

                return nil
            }
        }

        func lowerBounds() -> [(Int, Int)]? {
            let lb = left?._bounds
            let rb = right?._bounds

            if let lb = lb, let rb = rb {
                return fullInnerBounds(lb: lb, rb: rb)
            }

            if let lb = lb {
                return lb.map { ($0.0 - 1, $0.1 - 1) }
            }

            if let rb = rb {
                return rb.map { ($0.0 + 1, $0.1 + 1) }
            }

            return nil
        }

        return [(0, 0)] + (lowerBounds() ?? [])
    }

    private func _layoutBinaryTreeInternal(x: Int, depth: Int) -> (PositionedTree<T>?, Int) {
        let (_left, _x) = left?._layoutBinaryTreeInternal(x: x, depth: depth + 1) ?? (nil, x)
        let (_right, nextX) = right?._layoutBinaryTreeInternal(x: _x + 1, depth: depth + 1) ?? (nil, x + 1)

        return (PositionedTree(x: _x, y: depth, value: value, _left, _right), nextX)
    }

    private func _layoutBinaryTree2Internal(x: Int, depth: Int, exp: Int) -> PositionedTree<T> {
        PositionedTree<T>(x: x,
                                 y: depth,
                                 value: value,
                                 left?._layoutBinaryTree2Internal(x: x - (2 ^^ exp),
                                                                  depth: depth + 1,
                                                                  exp: exp - 1),
                                 right?._layoutBinaryTree2Internal(x: x + (2 ^^ exp),
                                                                   depth: depth + 1,
                                                                   exp: exp - 1))
    }

    private func _layoutBinaryTree3Internal(x: Int, depth: Int) -> PositionedTree<T> {
        let bounds = _bounds
        let (bl, br) = bounds.count > 2 ? bounds[1] : bounds[0]
        let offset = bounds.count > 2 ? 0 : 1

        return PositionedTree<T>(x: x,
                                 y: depth,
                                 value: value,
                                 left?._layoutBinaryTree3Internal(x: x + bl + offset, depth: depth + 1),
                                 right?._layoutBinaryTree3Internal(x: x + br + offset, depth: depth + 1))
    }

    // MARK: Differentials

    private var _heightDifferential: Int {
        abs(leftHeight - rightHeight)
    }

    private var _nodeCountDifferential: Int {
        abs((left?.nodeCount).orZero - (right?.nodeCount).orZero)
    }

    // MARK: - Tree Builder Functions

    private class func _makeHeightBalancedTrees(nodes: Int, value: T) -> [Tree<T>] {
        let range = minimumHeightForBalancedTree(withNodeCount: nodes)...maximumHeightForBalancedTree(withNodeCount: nodes)

        return range
            .compactMap { _makeHeightBalancedTrees(height: $0, value: value) }
            .flatMap { $0 }
            .filter { $0.nodeCount == nodes }
    }

    private class func _makeHeightBalancedTrees(height: Int, value: T) -> [Tree<T>] {
        switch height {
        case height where height < 1:
            return []
        case 1:
            return [Tree(value)]
        default:
            let maxHeightSubtree = _makeHeightBalancedTrees(height: height - 1, value: value)
            let minHeightSubtree = _makeHeightBalancedTrees(height: height - 2, value: value)

            return maxHeightSubtree.flatMap { l in
                maxHeightSubtree.map { r in
                    Tree(value, l, r)
                }
            } + maxHeightSubtree.flatMap { full -> [Tree<T>] in
                minHeightSubtree.flatMap {
                    [Tree(value, full, $0), Tree(value, $0, full)]
                }
            }
        }
    }

    private class func _makeBalancedTrees(nodes n: Int, value: T) -> [Tree<T>] {
        switch n {
        case 1:
            return [Tree(value)]
        case 2:
            return [Tree(value, nil, Tree(value)), Tree(value, Tree(value))]
        case n where n % 2 == 1:
            let subtrees = _makeBalancedTrees(nodes: n / 2, value: value)

            return subtrees.reduce([]) { res, left in
                res + subtrees.map { right in
                    Tree(value, left, right)
                }
            }
        case n where n > 0 && n.even:
            let lesser = _makeBalancedTrees(nodes: (n - 1) / 2, value: value)
            let greater = _makeBalancedTrees(nodes: (n - 1) / 2 + 1, value: value)

            return lesser.reduce([]) { res, less in
                res + greater.flatMap { great in
                    [Tree(value, less, great), Tree(value, great, less)]
                }
            }
        default:
            return []
        }
    }
}

extension Tree where T: Comparable {
    private class func _makeTraversalBasedTree(preOrder: [T], inOrder: [T], preStart: Int, preEnd: Int, inStart: Int, inEnd: Int) -> Tree<T>? {
        guard preStart <= preEnd, inStart <= inEnd else {
            return nil
        }

        let preOrderValue = preOrder[preStart]
        guard let indexOfPreOrderElementInInOrder = inOrder.dropFirst(inStart).firstIndex(where: {
            $0 == preOrderValue
        }) else {
            return nil
        }

        let left = _makeTraversalBasedTree(preOrder: preOrder, inOrder: inOrder, preStart: preStart + 1, preEnd: preStart + (indexOfPreOrderElementInInOrder - inStart), inStart: inStart, inEnd: indexOfPreOrderElementInInOrder - 1)
        let right = _makeTraversalBasedTree(preOrder: preOrder, inOrder: inOrder, preStart: preStart + (indexOfPreOrderElementInInOrder - inStart) + 1, preEnd: preEnd, inStart: indexOfPreOrderElementInInOrder + 1, inEnd: inEnd)

        return Tree(preOrderValue, left, right)
    }
}

// MARK: - Utility Functions

private func minimumNodesForBalancedTree(ofHeight height: Int) -> Int {
    switch height {
    case height where height < 1:
        return 0
    case 1:
        return 1
    default:
        return minimumNodesForBalancedTree(ofHeight: height - 1) + minimumNodesForBalancedTree(ofHeight: height - 2) + 1
    }
}

private func minimumHeightForBalancedTree(withNodeCount nodeCount: Int) -> Int {
    guard nodeCount > 0 else {
        return 0
    }

    return minimumHeightForBalancedTree(withNodeCount: nodeCount / 2) + 1
}

private func maximumHeightForBalancedTree(withNodeCount nodeCount: Int) -> Int {
    let heightArray = Array((1...).prefix {
        let nodes = minimumNodesForBalancedTree(ofHeight: $0)
        return nodes <= nodeCount
    })

    return heightArray[heightArray.count - 1]
}
