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

extension Tree {
    var height: Int {
        return 1 + max(leftHeight, rightHeight)
    }
    
    var leftHeight: Int {
        return left?.height ?? 0
    }
    
    var rightHeight: Int {
        return right?.height ?? 0
    }
    
    func isCompletelyBalanced() -> Bool {
        let hasCompletelyBalancedHeight = !(abs(leftHeight - rightHeight) > 1)
        guard hasCompletelyBalancedHeight else {
            return false
        }
        
        return [left, right].compactMap { $0 }.allSatisfy { $0.isCompletelyBalanced() }
    }
}
