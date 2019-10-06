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
            let evaluated = logExpr(type, operands[0], operands[1])

            XCTAssertEqual(evaluated, row[2], "\(type.rawValue) expression failed with operands (\(operands))", file: #file, line: line)
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
                logExpr(type, array[0], array[1])
            })

            XCTAssertEqual(result, type.truthTable)
        }

        let table = generateTruthTable(variables: 3) { vars in
            vars[0] ∧ vars[1] ∨ vars[2]
        }

        let expectation = [
            [true, true, true, true],
            [true, true, false, true],
            [true, false, true, true],
            [true, false, false, false],
            [false, true, true, true],
            [false, true, false, false],
            [false, false, true, true],
            [false, false, false, false]
        ]

        XCTAssertEqual(table, expectation)
    }

    func testLogicalOperators() {
        typealias LogicalOperator = (Bool, Bool) -> Bool

        let operatorsAndExpressionTypes:[(`operator`: LogicalOperator, type: LogicalExpression.ExpressionType)] = [
            (∧, .and),
            (∨, .or),
            (⊼, .nand),
            (⊽, .nor),
            (⊕, .xor),
            (→, .impl),
            (≡, .equ)
        ]

        operatorsAndExpressionTypes.forEach { tuple in
            let table = tuple.type.truthTable

            table.forEach { row in
                let actualResult = tuple.operator(row[0], row[1])
                let expectedResult = row[2]

                XCTAssertEqual(expectedResult, actualResult)
            }
        }
    }

    func testGrayCodes() {
        XCTAssertNil(gray(0))
        XCTAssertEqual(gray(1), ["0", "1"])
        XCTAssertEqual(gray(2), ["00", "01", "11", "10"])
        XCTAssertEqual(gray(3), ["000", "001", "011", "010", "110", "111", "101", "100"])
    }
}
