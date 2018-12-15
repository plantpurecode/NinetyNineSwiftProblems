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
    
    private var heightDifferential: Int {
        return abs(leftHeight - rightHeight)
    }
    
    private var nodeCountDifferential: Int {
        return abs((left?.nodeCount).orZero - (right?.nodeCount).orZero)
    }
    
    func isCompletelyBalanced() -> Bool {
        return !(nodeCountDifferential > 1)
    }
    
    class func _makeBalancedTrees(nodes n: Int, value: T) -> [Tree<T>]? {
        switch n {
        case 0:
            return nil
        case 1:
            return [Tree(value)]
        case 2:
            return [Tree(value, Tree(value)), Tree(value, nil, Tree(value))]
        default:
            let buildTreePair = { (x:Int, y:Int) -> [Tree<T>] in
                var left = _makeBalancedTrees(nodes: x, value: value) ?? [Tree<T>?]()
                var right = _makeBalancedTrees(nodes: y, value: value) ?? [Tree<T>?]()
                left.pad(upTo: right.count - left.count, with: Tree(value))
                right.pad(upTo: left.count - right.count, with: Tree(value))
                
                return zip(right, left).map { Tree(value, $0, $1) }
            }
            
            if n.even {
                return buildTreePair((n / 2) - 1, n / 2) + buildTreePair(n / 2, (n / 2) - 1)
            } else {
                return buildTreePair((n - 1) / 2, (n - 1) / 2)
            }
        }
    }
    
    class func makeBalancedTrees(nodes n: Int, value: T) -> List<Tree<T>>? {
        guard let result = _makeBalancedTrees(nodes: n, value: value) else {
            return nil
        }
        
        return List(result)
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

extension Optional {
    func or(_ value: Wrapped) -> Wrapped {
        switch self {
        case .none:
            return value
        case .some(let wrapped):
            return wrapped
        }
    }
}

extension Optional where Wrapped : Numeric {
    var orZero: Wrapped {
        return or(0)
    }
}

extension Array {
    mutating func pad(upTo n: Int, with padding: Element) {
        guard n > 0 else {
            return
        }
        
        self += (0..<n).map { _ in padding }
    }
}
