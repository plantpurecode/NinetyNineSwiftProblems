//
//  ArithmeticTests.swift
//  NinetyNineSwiftProblemsTests
//
//  Created by Jacob Relkin on 11/1/18.
//  Copyright © 2019 Jacob Relkin. All rights reserved.
//

import XCTest
@testable import NinetyNineSwiftProblems

private let primes = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47]

class ArithmeticTests: XCTestCase {
    func testIsPrime() {
        primes.forEach {
            XCTAssertTrue($0.isPrime())
        }

        XCTAssertFalse((-1).isPrime())
    }

    func testAllPrime() {
        XCTAssertNoThrow(try primes.allPrime())
        XCTAssertTrue(try primes.allPrime())

        let unorderedPrimes1 = [2, 5, 3, 37, 29, 7]
        XCTAssertTrue(try unorderedPrimes1.allPrime(greatestIndex: 3))

        var unorderedPrimes2 = primes.prefix(15)
        unorderedPrimes2.swapAt(3, 14)
        XCTAssertTrue(try unorderedPrimes2.allPrime(greatestIndex: 3))

        // Negative numbers should throw an error.
        XCTAssertThrowsError(try [-1].allPrime()) {
            guard case Primes.Error.negativeNumber = $0 else {
                XCTFail("Invalid error type thrown")
                return
            }
        }

        // invalid indexes should throw an error.
        XCTAssertThrowsError(try primes.allPrime(greatestIndex: -2)) {
            guard case Primes.Error.negativeGreatestIndex = $0 else {
                XCTFail("Invalid error type thrown")
                return
            }
        }

        XCTAssertThrowsError(try unorderedPrimes1.allPrime(greatestIndex: 10)) {
            guard case Primes.Error.greatestIndexTooLarge = $0 else {
                XCTFail("Invalid error type thrown")
                return
            }
        }

        XCTAssertFalse(try [1, 2].allPrime())
        XCTAssertFalse(try Array(1...10).allPrime())
    }

    func testGCD() {
        XCTAssertEqual(Int.gcd(36, 63), 9)
        XCTAssertEqual(Int.gcd(63, 36), 9)
    }

    func testLCM() {
        XCTAssertEqual(Int.lcm(4, 6), 12)
    }

    func testCoprime() {
        XCTAssertTrue(35.isCoprimeTo(64))
        XCTAssertFalse(35.isCoprimeTo(63))
    }

    func testTotient() {
        let expectations = [1: 1, 10: 4, 486: 162, 1_292: 576, 38_856: 12_944]

        for (n, t) in expectations {
            XCTAssertEqual(n.totient, t)
            XCTAssertEqual(n.totientImproved(), t)
        }
    }

    func testTotientPerformance() {
        measure {
            _ = 10_090.totient
        }
    }

    func testTotientImprovedPerformance() {
        let dict = 10_090.primeFactorMultiplicityDict

        measure {
            _ = 10_090.totientImproved(dict)
        }
    }

    func testPrimeFactors() {
        XCTAssertEqual(315.primeFactors, [3, 3, 5, 7])
        XCTAssertEqual(42.primeFactors, [2, 3, 7])

        (-10...1).forEach {
            XCTAssertNil($0.primeFactors)
        }

        XCTAssertEqual(2.primeFactors, [2])
    }

    func testPrimeFactorMultiplicity() {
        let expected = [3: 2, 5: 1, 7: 1]
        315.primeFactorMultiplicity.forEach { tuple in
            XCTAssertNotNil(expected[tuple.0])
            XCTAssertEqual(tuple.1, expected[tuple.0])
        }

        XCTAssertEqual(315.primeFactorMultiplicityDict, expected)
    }

    func testListPrimesInRange() {
        XCTAssertEqual(Int.listPrimesInRange(range: 7...31), List(7, 11, 13, 17, 19, 23, 29, 31))
    }

    func testPrimeGeneration() {
        let generatedPrimes = Primes.generate(upTo: 50)

        XCTAssertEqual(primes, generatedPrimes)
    }

    func testPrimeGenerationRuntime() {
        // This test will be disabled normally in order to keep overall test suite runtime to a minimum.

        let upperBound = 5_000_000
        var primeCount = 0

        measure {
            primeCount = Primes.generate(upTo: upperBound).count
        }

        print("Found \(primeCount) primes up to \(upperBound)")
    }

    func testGoldbach() {
        let expectsNil = [0, 1, 4, 5, 7, 9, 29]
        expectsNil.forEach {
            XCTAssertNil(try? $0.goldbach())
        }

        let result = try? 28.goldbach()
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.0, 5)
        XCTAssertEqual(result?.1, 23)
    }

    func testGoldbachCompositions() {
        let expected = [
            10: [3, 7],
            12: [5, 7],
            14: [3, 11],
            16: [3, 13],
            18: [5, 13],
            20: [3, 17]
        ]

        for (number, goldbach) in Int.goldbachCompositions(inRange: 9...20) {
            let expectedGoldbach = expected[number]

            XCTAssertEqual([goldbach.0, goldbach.1], expectedGoldbach)
        }

        let goldbachCompositions = Int.goldbachCompositionsLimited(inRange: 1...20)
        XCTAssertEqual(goldbachCompositions, "2 = 1 + 1, 3 = 1 + 2")
    }

    func testGoldbachCompositionsFull() {
        measure {
            XCTAssertEqual(Int.goldbachCompositions(inRange: 1...5_000, aboveMinimum: 50).count, 2_447)
        }
    }

    func testEnglishWordRepresentation() {
        XCTAssertEqual(0.englishWordRepresentation, "Zero")
        XCTAssertEqual(1.englishWordRepresentation, "One")
        XCTAssertEqual(106.englishWordRepresentation, "One Zero Six")
        XCTAssertEqual(175.englishWordRepresentation, "One Seven Five")
        XCTAssertEqual(209.englishWordRepresentation, "Two Zero Nine")
        XCTAssertEqual((-106).englishWordRepresentation, "Negative One Zero Six")
        XCTAssertEqual((-175).englishWordRepresentation, "Negative One Seven Five")
    }
}
