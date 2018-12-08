//
//  Logic.swift
//  NinetyNineSwiftProblems
//
//  Created by Jacob Relkin on 12/8/18.
//  Copyright © 2018 Jacob Relkin. All rights reserved.
//

import Foundation

struct LogicalExpression {
    enum ExpressionType : String {
        case and
        case or
        case nand
        case nor
        case xor
        case impl
        case equ
    }
    
    let left: Bool
    let right: Bool
    let type: ExpressionType
    
    // For convenience. Always has a count of 2
    private let operands: [Bool]
    
    init(left l: Bool, right r: Bool, type t: ExpressionType) {
        left = l
        right = r
        operands = [l, r]
        type = t
    }
    
    func evaluate() -> Bool {
        switch type {
        case .and:
            return !operands.contains(false)
        case .or:
            return operands.contains(true)
        case .nand:
            return !operands.allSatisfy { $0 }
        case .nor:
            return operands.allSatisfy { !$0 }
        case .xor:
            return operands.filter { $0 }.count == 1
        case .impl:
            return !(left == true && right == false)
        case .equ:
            return operands.allSatisfy { !$0 } || operands.allSatisfy { $0 }
        }
    }
}

func logExpr(_ type: LogicalExpression.ExpressionType, _ l: Bool, _ r: Bool) -> Bool {
    return LogicalExpression(left: l, right: r, type: type).evaluate()
}

func generateTruthTable(expression: (Bool, Bool) -> Bool) -> List<List<Bool>> {
    let inputs = [[true, true], [false, false], [true, false], [false, true]]
    
    var lists = [List<Bool>]()
    for combo in inputs {
        lists.append(List(combo.first!, combo.last!, expression(combo.first!, combo.last!))!)
    }
    
    return List(lists)!
}
