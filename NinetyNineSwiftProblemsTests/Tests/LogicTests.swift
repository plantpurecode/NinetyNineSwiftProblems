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
            
            if let expectation = row.last, expectation == true {
                XCTAssertTrue(evaluated, "\(type.rawValue) expression faile with operands (\(operands))", file: #file, line: line)
            } else {
                XCTAssertFalse(evaluated, "\(type.rawValue) expression faile with operands (\(operands))", file: #file, line: line)
            }
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
            let result = generateTruthTable(expression: { (l, r) -> Bool in
                return logExpr(type, l, r)
            }).values.map { $0.values }

            XCTAssertEqual(result, type.truthTable)
        }
    }
}
