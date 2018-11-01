//
//  ArithmeticTests.swift
//  NinetyNineSwiftProblemsTests
//
//  Created by Jacob Relkin on 11/1/18.
//  Copyright © 2018 Jacob Relkin. All rights reserved.
//

import XCTest
@testable import NinetyNineSwiftProblems

fileprivate let primes = [Int](arrayLiteral:2,3,5,7,11,13,17,19,23,29,31,37,41,43,47)

class ArithmeticTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testIsPrime() {
        primes.forEach {
            XCTAssertTrue($0.isPrime())
        }
    }
    
    func testAllPrime() {
        XCTAssertTrue(primes.allPrime())
        
        let unorderedPrimes = [2,5,3,37,29,7]
        XCTAssertTrue(unorderedPrimes.allPrime(greatestIndex: 3))
        
        // invalid index... should return false
        XCTAssertFalse(unorderedPrimes.allPrime(greatestIndex: 10))
    }
}
