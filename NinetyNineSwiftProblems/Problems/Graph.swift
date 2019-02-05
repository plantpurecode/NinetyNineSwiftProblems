//
//  Graph.swift
//  NinetyNineSwiftProblems
//
//  Created by Jacob Relkin on 2/3/19.
//  Copyright © 2019 Jacob Relkin. All rights reserved.
//

import Foundation

class Graph<T, U> {
    enum Direction {
        case Indirected
        case Directed
    }

    class var direction: Direction {
        return .Indirected
    }

    var nodes: List<T>?
    var edges: List<(T, T, U)>?
}

class Digraph<T, U> : Graph<T, U> {
    override class var direction: Direction { return .Directed }
}
