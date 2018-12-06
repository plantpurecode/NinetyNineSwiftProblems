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
    func testIsPrime() {
        primes.forEach {
            XCTAssertTrue($0.isPrime())
        }
        
        XCTAssertFalse((-1).isPrime())
    }
    
    func testAllPrime() {
        XCTAssertNoThrow(try primes.allPrime())
        XCTAssertTrue(try! primes.allPrime())
        
        let unorderedPrimes = [2,5,3,37,29,7]
        XCTAssertTrue(try! unorderedPrimes.allPrime(greatestIndex: 3))
        
        // invalid indexes should throw errors.
        XCTAssertThrowsError(try primes.allPrime(greatestIndex: -2)) {
            guard case Primes.Error.negativeGreatestIndex = $0 else {
                XCTFail("Invalid error type thrown")
                return
            }
        }
        
        XCTAssertThrowsError(try unorderedPrimes.allPrime(greatestIndex: 10)) {
            guard case Primes.Error.greatestIndexTooLarge = $0 else {
                XCTFail("Invalid error type thrown")
                return
            }
        }

        XCTAssertFalse(try! [1,2].allPrime())
        XCTAssertFalse(try! (1...10).map { $0 }.allPrime())
    }
    
    func testGCD() {
        XCTAssertEqual(Int.gcd(36, 63), 9)
    }
    
    func testLCM() {
        XCTAssertEqual(Int.lcm(4, 6), 12)
    }
    
    func testCoprime() {
        XCTAssertTrue(35.isCoprimeTo(64))
        XCTAssertFalse(35.isCoprimeTo(63))
    }
    
    func testTotient() {
        XCTAssertEqual(1.totient(), 1)
        XCTAssertEqual(10.totient(), 4)
    }
    
    func testPrimeFactors() {
        XCTAssertEqual(315.primeFactors, List(3, 3, 5, 7))
        XCTAssertEqual(42.primeFactors, List(2, 3, 7))
        
        (-10...1).forEach {
            XCTAssertNil($0.primeFactors)
        }
        
        XCTAssertEqual(2.primeFactors, List(2))
    }
    
    func testPrimeFactorMultiplicity() {
        let expected = [3:2, 5:1, 7:1]
        315.primeFactorMultiplicity.values.forEach { tuple in
            XCTAssertNotNil(expected[tuple.0])
            XCTAssertEqual(tuple.1, expected[tuple.0])
        }
        
        XCTAssertEqual(315.primeFactorMultiplicityDict, expected)
    }
}

