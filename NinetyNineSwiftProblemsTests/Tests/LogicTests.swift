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
            let operands = Array(row.suffix(from: 1))
            let expression = LogicalExpression(left: operands.first!, right: operands.last!, type: type)
            
            if let expectation = row.first, expectation == true {
                XCTAssertTrue(expression.evaluate(), "\(type.rawValue) expression faile with operands (\(operands))", file: #file, line: line)
            } else {
                XCTAssertFalse(expression.evaluate(), "\(type.rawValue) expression faile with operands (\(operands))", file: #file, line: line)
            }
        }
    }
    
    func testAnd() {
        let table = [
            [true, true, true],
            [false, true, false],
            [false, false, true],
            [false, false, false]
        ]
        
        performTruthTableTest(table, .and)
    }

    func testOr() {
        let table = [
            [true, true, true],
            [true, true, false],
            [true, false, true],
            [false, false, false]
        ]
        
         performTruthTableTest(table, .or)
    }
    
    func testNand() {
        let table = [
            [true, true, false],
            [true, false, true],
            [true, false, false],
            [false, true, true]
        ]
        
        performTruthTableTest(table, .nand)
    }
    
    func testNor() {
        let table = [
            [false, true, false],
            [false, false, true],
            [false, true, true],
            [true, false, false],
        ]
        
        performTruthTableTest(table, .nor)
    }
    
    func testXor() {
        let table = [
            [true, true, false],
            [true, false, true],
            [false, true, true],
            [false, false, false],
        ]
        
        performTruthTableTest(table, .xor)
    }
    
    func testImpl() {
        let table = [
            [true, true, true],
            [false, true, false],
            [true, false, true],
            [true, false, false],
        ]
        
        performTruthTableTest(table, .impl)
    }

    
    func testEqu() {
        let table = [
            [true, true, true],
            [true, false, false],
            [false, true, false],
            [false, false, true]
        ]
        
        performTruthTableTest(table, .equ)
    }
}
