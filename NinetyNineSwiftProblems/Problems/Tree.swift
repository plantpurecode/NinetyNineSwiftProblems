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

    var isLeaf: Bool {
        return [left, right].compactMap { $0 }.count == 0
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
    
    var completelyBalanced: Bool {
        return !(nodeCountDifferential > 1)
    }
    
    // MARK: - Private
    
    private var heightDifferential: Int {
        return abs(leftHeight - rightHeight)
    }
    
    private var nodeCountDifferential: Int {
        return abs((left?.nodeCount).orZero - (right?.nodeCount).orZero)
    }
    
    private class func _makeBalancedTrees(nodes n: Int, value: T) -> [Tree<T>]? {
        func defaultNode() -> Tree {
            return Tree(value)
        }
        
        switch n {
        case 0:
            return nil
        case 1:
            return [defaultNode()]
        case 2:
            return [Tree(value, defaultNode()), Tree(value, nil, defaultNode())]
        default:
            func generateSubtrees(leftCount: Int, rightCount: Int) -> [Tree<T>] {
                var left = _makeBalancedTrees(nodes: leftCount, value: value) ?? [Tree<T>?]()
                var right = _makeBalancedTrees(nodes: rightCount, value: value) ?? [Tree<T>?]()
                left.pad(upTo: right.count - left.count, with: defaultNode())
                right.pad(upTo: left.count - right.count, with: defaultNode())
                
                return zip(right, left).map { Tree(value, $0, $1) }
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

extension Int {
    var even: Bool {
        return self % 2 == 0
    }
    
    var odd: Bool {
        return !even
    }
}

extension Tree : Equatable where T : Equatable {
    static func == (lhs: Tree, rhs: Tree) -> Bool {
        return lhs.value == rhs.value && lhs.right == rhs.right && lhs.left == rhs.left
    }
}