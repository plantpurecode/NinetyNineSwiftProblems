//
//  Tree.swift
//  NinetyNineSwiftProblems
//
//  Created by Jacob Relkin on 12/14/18.
//  Copyright © 2018 Jacob Relkin. All rights reserved.
//

import Foundation

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

extension Tree : CustomDebugStringConvertible {
    var debugDescription: String {
        return "(\(isLeaf ? "Leaf" : "Node") \(self.value)\(left != nil ? ", l: \(left!.debugDescription)" : "")\(right != nil ? ", r: " + right!.debugDescription : ""))"
    }
}

extension Tree {
    class func makeBalancedTrees(nodes n: Int, value: T) -> List<Tree<T>>? {
        guard let result = _makeBalancedTrees(nodes: n, value: value) else {
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
    
    var isLeaf: Bool {
        return [left, right].compactMap { $0 }.count == 0
    }
    
    var leafCount: Int {
        return (isLeaf ? 1 : 0) + (left?.leafCount).orZero + (right?.leafCount).orZero
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
        return heightDifferential <= 1
    }
    
    var completelyBalanced: Bool {
        return !(nodeCountDifferential > 1)
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
    
    // MARK: - Private
    
    private var heightDifferential: Int {
        return abs(leftHeight - rightHeight)
    }
    
    private var nodeCountDifferential: Int {
        return abs((left?.nodeCount).orZero - (right?.nodeCount).orZero)
    }
    
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
                minHeightSubtree.flatMap { short in
                    [Tree(value, full, short), Tree(value, short, full)]
                }
            }
        }
    }

    private class func _makeBalancedTrees(nodes n: Int, value: T) -> [Tree<T>]? {
        let leaf = Tree(value)
        
        switch n {
        case 0:
            return nil
        case 1:
            return [leaf]
        case 2:
            return [Tree(value, leaf), Tree(value, nil, leaf)]
        default:
            func generateSubtrees(leftCount: Int, rightCount: Int) -> [Tree<T>] {
                var left = _makeBalancedTrees(nodes: leftCount, value: value) ?? [Tree<T>?]()
                var right = _makeBalancedTrees(nodes: rightCount, value: value) ?? [Tree<T>?]()
                
                left.pad(upTo: right.count - left.count, with: leaf)
                right.pad(upTo: left.count - right.count, with: leaf)
                
                return zip(left, right).map { Tree(value, $0, $1) }
            }
            
            if n.even {
                return generateSubtrees(leftCount: (n / 2) - 1, rightCount: n / 2) +
                    generateSubtrees(leftCount: n / 2, rightCount: (n / 2) - 1)
            } else {
                return generateSubtrees(leftCount: (n - 1) / 2, rightCount: (n - 1) / 2)
            }
        }
    }
}

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

extension Tree : Equatable where T : Equatable {
    static func == (lhs: Tree, rhs: Tree) -> Bool {
        return lhs.value == rhs.value && lhs.right == rhs.right && lhs.left == rhs.left
    }
}

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
