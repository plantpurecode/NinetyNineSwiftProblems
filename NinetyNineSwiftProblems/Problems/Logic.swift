//
//  Logic.swift
//  NinetyNineSwiftProblems
//
//  Created by Jacob Relkin on 12/8/18.
//  Copyright © 2018 Jacob Relkin. All rights reserved.
//

import Foundation

struct LogicalExpression {
    var booleanOperands: [Bool]
    
    init(operands: [Bool]) {
        booleanOperands = operands
    }
    
    mutating func update(_ operands: [Bool]) {
        booleanOperands = operands
    }
}

extension LogicalExpression {
    func and() -> Bool {
        return !booleanOperands.contains(false)
    }

    func or() -> Bool {
        return booleanOperands.contains(true)
    }
    
    func nand() -> Bool {
        return !booleanOperands.allSatisfy { $0 == true }
    }
    
    func nor() -> Bool {
        return booleanOperands.allSatisfy { $0 == false }
    }
    
    func xor() -> Bool {
        return booleanOperands.filter { $0 == true }.count == 1
    }
    
    func impl() -> Bool {
        return !(booleanOperands.first == true && booleanOperands.last == false)
    }
    
    func equ() -> Bool {
        return nor() || booleanOperands.allSatisfy { $0 == true }
    }
}
