//
//  LogicTests.swift
//  NinetyNineSwiftProblemsTests
//
//  Created by Jacob Relkin on 12/8/18.
//  Copyright © 2018 Jacob Relkin. All rights reserved.
//

import XCTest

@testable import NinetyNineSwiftProblems

class LogicTests: XCTestCase {
    private func performTruthTableTest(_ type: LogicalExpression.ExpressionType, line: UInt = #line) {
        for row in type.truthTable {
            let operands = Array(row.prefix(through: 1))
            let evaluated = logExpr(type, operands.first!, operands.last!)
            
            XCTAssertEqual(evaluated, row.last!, "\(type.rawValue) expression failed with operands (\(operands))", file: #file, line: line)
        }
    }
    
    func testAnd() {
        performTruthTableTest(.and)
    }

    func testOr() {
         performTruthTableTest(.or)
    }
    
    func testNand() {
        performTruthTableTest(.nand)
    }
    
    func testNor() {
        performTruthTableTest(.nor)
    }
    
    func testXor() {
        performTruthTableTest(.xor)
    }
    
    func testImpl() {
        performTruthTableTest(.impl)
    }
    
    func testEqu() {
        performTruthTableTest(.equ)
    }
    
    func testTruthTableGeneration() {
        for type in LogicalExpression.ExpressionType.allCases {
            let result = generateTruthTable(expression: { array in
                return logExpr(type, array.first!, array.last!)
            }).values.map { $0.values }

            XCTAssertEqual(result, type.truthTable)
        }
    
        let table = generateTruthTable(variables: 3) { vars in
            vars[0] ∧ vars[1] ∨ vars[2]
        }.values.map { $0.values }
        
        let expectation = [
            [true,  true,  true,  true],
            [true,  true,  false, true],
            [true,  false, true,  true],
            [true,  false, false, false],
            [false, true,  true,  true],
            [false, true,  false, false],
            [false, false, true,  true],
            [false, false, false, false]
        ]
        
        XCTAssertEqual(table, expectation)
    }
    
    func testLogicalOperators() {
        typealias LogicalOperator = (Bool, Bool) -> Bool
        
        let operatorsAndExpressionTypes:[(LogicalOperator, LogicalExpression.ExpressionType)] = [
            (∧, .and),
            (∨, .or),
            (⊼, .nand),
            (⊽, .nor),
            (⊕, .xor),
            (→, .impl),
            (≡, .equ)
        ]
        
        operatorsAndExpressionTypes.forEach { tuple in
            let table = tuple.1.truthTable
            
            table.forEach { row in
                let expectedResult = row.last!
                let actualResult = tuple.0(row.first!, row[1])

                XCTAssertEqual(expectedResult, actualResult)
            }
        }
    }
    
    func testGrayCodes() {
        XCTAssertNil(gray(0))
        XCTAssertEqual(gray(1), List("0", "1"))
        XCTAssertEqual(gray(2), List("00", "01", "11", "10"))
        XCTAssertEqual(gray(3), List("000", "001", "011", "010", "110", "111", "101", "100"))
    }
}
