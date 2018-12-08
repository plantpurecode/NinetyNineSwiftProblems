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
    private func performTruthTableTest(_ table: [[Bool]], _ type: LogicalExpression.ExpressionType, line: UInt = #line) {
        for row in table {
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
        let table = [
            [true, true, true],
            [true, false, false],
            [false, true, false],
            [false, false, false]
        ]
        
        performTruthTableTest(table, .and)
    }

    func testOr() {
        let table = [
            [true, true, true],
            [true, false, true],
            [false, true, true],
            [false, false, false]
        ]
        
         performTruthTableTest(table, .or)
    }
    
    func testNand() {
        let table = [
            [true, false, true],
            [false, true, true],
            [false, false, true],
            [true, true, false]
        ]
        
        performTruthTableTest(table, .nand)
    }
    
    func testNor() {
        let table = [
            [true, false, false],
            [false, true, false],
            [true, true, false],
            [false, false, true],
        ]
        
        performTruthTableTest(table, .nor)
    }
    
    func testXor() {
        let table = [
            [true, false, true],
            [false, true, true],
            [true, true, false],
            [false, false, false],
        ]
        
        performTruthTableTest(table, .xor)
    }
    
    func testImpl() {
        let table = [
            [true, true, true],
            [true, false, false],
            [false, true, true],
            [false, false, true],
        ]
        
        performTruthTableTest(table, .impl)
    }

    
    func testEqu() {
        let table = [
            [true, true, true],
            [false, false, true],
            [false, true, false],
            [false, true, false]
        ]
        
        performTruthTableTest(table, .equ)
    }
    
    func testTruthTables() {
        let table = [
            [true, true, true],
            [false, false, true],
            [true, false, false],
            [false, true, false]
        ]

        let result = generateTruthTable(expression: { (l, r) -> Bool in
            return logExpr(.equ, l, r)
        }).values.map { $0.values }

        XCTAssertEqual(result, table)
    }
}
