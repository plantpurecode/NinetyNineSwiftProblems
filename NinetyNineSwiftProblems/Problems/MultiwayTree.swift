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
