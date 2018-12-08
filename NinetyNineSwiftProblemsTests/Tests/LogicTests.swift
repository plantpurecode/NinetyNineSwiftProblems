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
    var expr = LogicalExpression(operands: [true, true])
    
    private func performTruthTableTest(_ table: [[Bool]], operation: @autoclosure () -> Bool, message: @autoclosure () -> String = "", line: UInt = #line) {
        for row in table {
            let operands = Array(row.suffix(from: 1))
            expr.update(operands)
            
            if let expectation = row.first, expectation == true {
                XCTAssertTrue(operation(), message() + " (\(operands))", file: #file, line: line)
            } else {
                XCTAssertFalse(operation(), message() + " (\(operands))", file: #file, line: line)
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
        
        performTruthTableTest(table, operation: expr.and(), message: "AND expression failed!")
    }

    func testOr() {
        let table = [
            [true, true, true],
            [true, true, false],
            [true, false, true],
            [false, false, false]
        ]
        
         performTruthTableTest(table, operation: expr.or(), message: "OR expression failed!")
    }
    
    func testNand() {
        let table = [
            [true, true, false],
            [true, false, true],
            [true, false, false],
            [false, true, true]
        ]
        
        performTruthTableTest(table, operation: expr.nand(), message: "NAND expression failed!")
    }
    
    func testNor() {
        let table = [
            [false, true, false],
            [false, false, true],
            [false, true, true],
            [true, false, false],
        ]
        
        performTruthTableTest(table, operation: expr.nor(), message: "NOR expression failed!")
    }
    
    func testXor() {
        let table = [
            [true, true, false],
            [true, false, true],
            [false, true, true],
            [false, false, false],
        ]
        
        performTruthTableTest(table, operation: expr.xor(), message: "XOR expression failed!")
    }
    
    func testImpl() {
        let table = [
            [true, true, true],
            [false, true, false],
            [true, false, true],
            [true, false, false],
        ]
        
        performTruthTableTest(table, operation: expr.impl(), message: "IMPL expression failed!")
    }

    
    func testEqu() {
        let table = [
            [true, true, true],
            [true, false, false],
            [false, true, false],
            [false, false, true]
        ]
        
        performTruthTableTest(table, operation: expr.equ(), message: "EQU expression failed!")
    }
}
