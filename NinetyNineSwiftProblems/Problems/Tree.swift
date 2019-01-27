//
//  Tree.swift
//  NinetyNineSwiftProblems
//
//  Created by Jacob Relkin on 12/14/18.
//  Copyright © 2018 Jacob Relkin. All rights reserved.
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

extension Tree : CustomStringConvertible {
    var description: String {
        let joinedChildDescriptions = [left?.description ?? "", right?.description ?? ""].joined(separator: ",")
        let childValueDescription = isLeaf == false ? "(\(joinedChildDescriptions))" : ""
        
        return "\(value)\(childValueDescription)"
    }
}

// MARK: - Tree Factories

extension Tree {
    class func makeBalancedTrees(nodes n: Int, value: T) -> List<Tree<T>>? {
        let result = _makeBalancedTrees(nodes: n, value: value)
        
        guard result.isEmpty == false else {
            return nil
        }
        
        return List(result)
    }
    
    class func makeSymmetricBalancedTrees(nodes n: Int, value: T) -> List<Tree<T>>? {
        let result = _makeBalancedTrees(nodes: n, value: value).filter { $0.symmetric }
        
        guard result.isEmpty == false else {
            return nil
        }
        
        return List(result)
    }
    
    class func makeHeightBalancedTrees(height: Int, value: T) -> List<Tree<T>>? {
        guard let result = _makeHeightBalancedTrees(height: height, value: value) else {
            return nil
        }
        
        return List(result)
    }
    
    class func makeHeightBalancedTrees(nodes: Int, value: T) -> List<Tree<T>>? {
        guard let result = _makeHeightBalancedTrees(nodes: nodes, value: value) else {
            return nil
        }
    
        return List(result)
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
        return [left, right].compactMap { $0 }.count == 0
    }
    
    var leafCount: Int {
        return (isLeaf ? 1 : 0) + (left?.leafCount).orZero + (right?.leafCount).orZero
    }
    
    var leaves: List<T> {
        guard isLeaf == false else {
            return List(value)!
        }
        
        return List([left, right].compactMap { $0 }.reduce([T](), {
            return $0 + $1.leaves.values
        }))!
    }
    
    var nodeCount: Int {
        return 1 + (left?.nodeCount ?? 0) + (right?.nodeCount ?? 0)
    }
    
    var height: Int {
        return 1 + max(leftHeight, rightHeight)
    }
    
    var leftHeight: Int {
        return (left?.height).orZero
    }
    
    var rightHeight: Int {
        return (right?.height).orZero
    }
    
    var heightBalanced: Bool {
        return _heightDifferential <= 1
    }
    
    var completelyBalanced: Bool {
        return !(_nodeCountDifferential > 1)
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
    
    var internalNodes: List<T>? {
        guard isLeaf == false else {
            return nil
        }
        
        let successorNodes = [left, right].compactMap { $0 }.filter { !$0.isLeaf }
        let prefix = successorNodes.count > 0 ? [value] : [T]()
        
        return List(prefix + successorNodes.map ({ $0.value }) + successorNodes.flatMap({ $0.internalNodes?.values ?? [] }))
    }
    
    // MARK: Traversal
    
    var preOrder: List<T> {
        return List(_preOrder)!
    }
    
    var inOrder: List<T> {
        return List(_inOrder)!
    }
    
    var postOrder: List<T> {
        return List(_postOrder)!
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
        
        let x = (_bounds.map { $0.0 }.reduce(Int.max - 1, min) * -1) + 1
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
                guard nodePair.allNotNil() else {
                    return false
                }
                
                return nodePair[0]!.isMirror(of: nodePair[1]!)
            }()
            
            return bothNil || areMirrors
        }
    }
    
    func nodes(atLevel level: Int) -> List<T>? {
        switch level {
        case level where level < 1:
            return nil
        case 1:
            return List(value)
        default:
            let leftNodes = left?.nodes(atLevel: level - 1)?.values ?? [T]()
            let rightNodes = right?.nodes(atLevel: level - 1)?.values ?? [T]()
            
            return List(leftNodes + rightNodes)
        }
    }
}

// MARK: - Comparable

extension Tree where T : Comparable {
    convenience init(list: List<T>!) {
        let tree = Tree<T>(list.value)
        list.dropFirst().forEach {
            let _ = tree.insert(value: $0)
        }
        
        self.init(tree.value, tree.left, tree.right)
    }

    func insert(value v: T) -> Tree {
        if v < value {
            if left == nil {
                left = Tree(v)
            } else {
                _ = left!.insert(value: v)
            }
        } else if v > value {
            if right == nil {
                right = Tree(v)
            } else {
                _ = right!.insert(value: v)
            }
        }
        
        return self
    }
}

// MARK: - Equatable

extension Tree : Equatable where T : Equatable {
    static func == (lhs: Tree, rhs: Tree) -> Bool {
        return lhs.value == rhs.value && lhs.right == rhs.right && lhs.left == rhs.left
    }
}

// MARK: - String-based Tree Initialization

extension Tree where T == String {
    convenience init?(string: String) {
        guard string.count > 0 else {
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

        switch string.count {
        case 1:
            self.init(String(string.first!))
        default:
            let (left, commaPosition) = extractTreeString(string, start: 2, end: ",")
            let (right, _) = extractTreeString(string, start: commaPosition + 1, end: ")")

            self.init(String(string.first!), Tree(string: left), Tree(string: right))
        }
    }
}

// MARK: - Traversal Based Tree Initialization

extension Tree where T : Comparable {
    convenience init?(preOrder po: List<T>, inOrder io: List<T>) {
        guard let tree = Tree<T>._makeTraversalBasedTree(preOrder: po.values, inOrder: io.values, preStart: 0, preEnd: po.length - 1, inStart: 0, inEnd: io.length - 1) else {
            return nil
        }

        self.init(tree.value, tree.left, tree.right)
    }
}

// MARK: - Dotstring Support

extension Tree where T : CustomStringConvertible {
    var dotString: String {
        return [value.description, left?.dotString, right?.dotString].map {
            $0 == nil ? "." : $0!
        }.joined()
    }
}

// MARK: - Layout-Specific Tree Subclass

class PositionedTree<T> : Tree<T> {
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
        return [value] + (left?._preOrder ?? []) + (right?._preOrder ?? [])
    }
    
    private var _inOrder: [T] {
        return (left?._inOrder ?? []) + [value] + (right?._inOrder ?? [])
    }
    
    private var _postOrder: [T] {
        return (left?._postOrder ?? []) + (right?._postOrder ?? []) + [value]
    }
    
    // MARK: Layout
    
    private var _depth: Int {
        return max(left?._depth ?? 0, right?._depth ?? 0) + 1
    }
    
    private var _leftmostDepth: Int {
        return (left?._leftmostDepth ?? 0) + 1
    }
    
    private var _bounds: [(Int, Int)] {
        func fullInnerBounds(lb: [(Int, Int)], rb: [(Int, Int)]) -> [(Int, Int)] {
            let shift = zip(lb, rb).map {
                (($0.0.1 - $0.1.0) / 2) + 1
            }.reduce(0, max)
            
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
        let (_left, myX) = left?._layoutBinaryTreeInternal(x: x, depth: depth + 1) ?? (nil, x)
        let (_right, nextX) = right?._layoutBinaryTreeInternal(x: myX + 1, depth: depth + 1) ?? (nil, x + 1)
        
        return (PositionedTree(x: myX, y: depth, value: value, _left, _right), nextX)
    }

    private func _layoutBinaryTree2Internal(x: Int, depth: Int, exp: Int) -> PositionedTree<T> {
        return PositionedTree<T>(x: x,
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
        return abs(leftHeight - rightHeight)
    }

    private var _nodeCountDifferential: Int {
        return abs((left?.nodeCount).orZero - (right?.nodeCount).orZero)
    }

    // MARK: - Tree Builder Functions

    private class func _makeHeightBalancedTrees(nodes: Int, value: T) -> [Tree<T>]? {
        let range = minimumHeightForBalancedTree(withNodeCount: nodes)...maximumHeightForBalancedTree(withNodeCount: nodes)
        
        guard range.count > 0 else {
            return nil
        }
        
        return range
            .compactMap { _makeHeightBalancedTrees(height: $0, value: value) }
            .flatMap { $0 }
            .filter { $0.nodeCount == nodes }
    }

    private class func _makeHeightBalancedTrees(height: Int, value: T) -> [Tree<T>]? {
        switch height {
        case height where height < 1:
            return nil
        case 1:
            return [Tree(value)]
        default:
            let maxHeightSubtree = _makeHeightBalancedTrees(height: height - 1, value: value)!
            let minHeightSubtree = _makeHeightBalancedTrees(height: height - 2, value: value) ?? Array(repeating: nil, count: maxHeightSubtree.count / 2)
            
            return maxHeightSubtree.flatMap { l in
                return maxHeightSubtree.map { r in
                    Tree(value, l, r)
                }
            } + maxHeightSubtree.flatMap { full in
                return minHeightSubtree.flatMap { short in
                    [Tree(value, full, short), Tree(value, short, full)]
                }
            }
        }
    }

    private class func _makeBalancedTrees(nodes n: Int, value: T) -> [Tree<T>] {
        switch n {
        case 0:
            return []
        case 1:
            return [Tree(value)]
        case 2:
            return [Tree(value, nil, Tree(value)), Tree(value, Tree(value))]
        case n where n % 2 == 1:
            let subtrees = _makeBalancedTrees(nodes: n / 2, value: value)
            
            return subtrees.reduce([Tree<T>]()) { res, left in
                return res + subtrees.map { right in
                    return Tree(value, left, right)
                }
            }
        case n where n.even:
            let lesser = _makeBalancedTrees(nodes: (n - 1) / 2, value: value)
            let greater = _makeBalancedTrees(nodes: (n - 1) / 2 + 1, value: value)

            return lesser.reduce([Tree<T>]()) { res, less in
                return res + greater.flatMap { great in
                    return [Tree(value, less, great), Tree(value, great, less)]
                }
            }
        default:
            return []
        }
    }
}

extension Tree where T : Comparable {
    private class func _makeTraversalBasedTree(preOrder: [T], inOrder:[T], preStart: Int, preEnd: Int, inStart: Int, inEnd: Int) -> Tree<T>? {
        guard preStart <= preEnd, inStart <= inEnd else {
            return nil
        }

        let preOrderValue = preOrder[preStart]
        guard let indexOfPreOrderElementInInOrder = inOrder.dropFirst(inStart).firstIndex(where: {
            return $0 == preOrderValue
        }) else {
            return nil
        }

        let left = _makeTraversalBasedTree(preOrder: preOrder, inOrder: inOrder, preStart: preStart + 1, preEnd: preStart + (indexOfPreOrderElementInInOrder - inStart), inStart: inStart, inEnd: indexOfPreOrderElementInInOrder - 1)
        let right = _makeTraversalBasedTree(preOrder: preOrder, inOrder: inOrder, preStart: preStart + (indexOfPreOrderElementInInOrder - inStart) + 1, preEnd: preEnd, inStart: indexOfPreOrderElementInInOrder + 1, inEnd: inEnd)

        return Tree(preOrderValue, left, right)
    }
}


// MARK: - Utility Functions

fileprivate func minimumNodesForBalancedTree(ofHeight height: Int) -> Int {
    switch height {
    case height where height < 1:
        return 0
    case 1:
        return 1
    default:
        return minimumNodesForBalancedTree(ofHeight: height - 1) + minimumNodesForBalancedTree(ofHeight: height - 2) + 1
    }
}

fileprivate func maximumNodesForBalancedTree(ofHeight height: Int) -> Int {
     return 2 * height - 1
}

fileprivate func minimumHeightForBalancedTree(withNodeCount nodeCount: Int) -> Int {
    guard nodeCount > 0 else {
        return 0
    }
    
    return minimumHeightForBalancedTree(withNodeCount: nodeCount / 2) + 1
}

fileprivate func maximumHeightForBalancedTree(withNodeCount nodeCount: Int) -> Int {
    return Array((1...).prefix {
        let nodes = minimumNodesForBalancedTree(ofHeight: $0)
        return nodes <= nodeCount
    }).last ?? 0
}


func zipAll<T>(left: [T], right: [T], defaultValue: T) -> [(T, T)] {
    return zipAll(left: left, right: right, leftShorterDefault: defaultValue, rightShorterDefault: defaultValue)
}

func zipAll<T>(left: [T], right: [T], leftShorterDefault: T, rightShorterDefault: T) -> [(T, T)] {
    let maxCount = max(left.count, right.count)
    
    var l = left, r = right
    
    l.pad(upTo: maxCount, with: leftShorterDefault)
    r.pad(upTo: maxCount, with: rightShorterDefault)
    
    return zip(l, r).map { $0 }
}
