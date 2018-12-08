//
//  Logic.swift
//  NinetyNineSwiftProblems
//
//  Created by Jacob Relkin on 12/8/18.
//  Copyright © 2018 Jacob Relkin. All rights reserved.
//

import Foundation

struct LogicalExpression {
    enum ExpressionType : String, CaseIterable {
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

extension LogicalExpression.ExpressionType {
    var truthTable: [[Bool]] {
        switch self {
        case .and:
            return [
                [true, true, true],
                [false, false, false],
                [true, false, false],
                [false, true, false]
            ]
        case .or:
            return [
                [true, true, true],
                [false, false, false],
                [true, false, true],
                [false, true, true]
            ]
        case .nand:
            return [
                [true, true, false],
                [false, false, true],
                [true, false, true],
                [false, true, true]
            ]
        case .nor:
            return [
                [true, true, false],
                [false, false, true],
                [true, false, false],
                [false, true, false]
            ]
        case .xor:
            return [
                [true, true, false],
                [false, false, false],
                [true, false, true],
                [false, true, true]
            ]
        case .impl:
            return [
                [true, true, true],
                [false, false, true],
                [true, false, false],
                [false, true, true]
            ]
        case .equ:
            return [
                [true, true, true],
                [false, false, true],
                [true, false, false],
                [false, true, false]
            ]
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
        let list = List(combo.first!, combo.last!, expression(combo.first!, combo.last!))!
        lists.append(list)
    }
    
    return List(lists)!
}

infix operator ∧ : LogicalConjunctionPrecedence
func ∧(_ left: Bool, _ right: Bool) -> Bool {
    return logExpr(.and, left, right)
}

infix operator ⊼ : LogicalConjunctionPrecedence
func ⊼(_ left: Bool, _ right: Bool) -> Bool {
    return logExpr(.nand, left, right)
}

infix operator ∨ : LogicalDisjunctionPrecedence
func ∨(_ left: Bool, _ right: Bool) -> Bool {
    return logExpr(.or, left, right)
}

infix operator ⊽ : LogicalDisjunctionPrecedence
func ⊽(_ left: Bool, _ right: Bool) -> Bool {
    return logExpr(.nor, left, right)
}

infix operator ⊕ : LogicalDisjunctionPrecedence
func ⊕(_ left: Bool, _ right: Bool) -> Bool {
    return logExpr(.xor, left, right)
}

infix operator → : LogicalDisjunctionPrecedence
func →(_ left: Bool, _ right: Bool) -> Bool {
    return logExpr(.impl, left, right)
}

infix operator ≡ : LogicalDisjunctionPrecedence
func ≡(_ left: Bool, _ right: Bool) -> Bool {
    return logExpr(.equ, left, right)
}

