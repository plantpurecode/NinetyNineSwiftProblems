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
}
