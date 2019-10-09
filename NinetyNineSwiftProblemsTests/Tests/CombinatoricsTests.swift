//
//  CombinatoricsTests.swift
//  NinetyNineSwiftProblemsTests
//
//  Created by Jacob Relkin on 10/2/19.
//  Copyright © 2019 Jacob Relkin. All rights reserved.
//

import XCTest

@testable import NinetyNineSwiftProblems

class CombinatoricsTests: XCTestCase {
    private let testCollection = ["a", "b", "c"]

    func testRepeatingCombinations() {
        XCTAssertEqual(testCollection.combinations(taking: 2, repeating: true),
                       [["a", "a"], ["a", "b"], ["a", "c"], ["b", "b"], ["b", "c"], ["c", "c"]])
        XCTAssertEqual(testCollection.combinations(taking: nil, repeating: true),
                       [["a", "a", "a"], ["a", "a", "b"], ["a", "a", "c"], ["a", "b", "b"], ["a", "b", "c"], ["a", "c", "c"], ["b", "b", "b"], ["b", "b", "c"], ["b", "c", "c"], ["c", "c", "c"]])
    }

    func testNonRepeatingCombinations() {
        XCTAssertEqual(testCollection.combinations(taking: 2),
                       [["a", "b"], ["a", "c"], ["b", "c"]])
        XCTAssertEqual(testCollection.combinations(), [["a", "b", "c"]])
    }

    func testRepeatingPermutations() {
        XCTAssertEqual(testCollection.permutations(taking: 2, repeating: true), [
            ["a", "a"],
            ["a", "b"],
            ["a", "c"],
            ["b", "a"],
            ["b", "b"],
            ["b", "c"],
            ["c", "a"],
            ["c", "b"],
            ["c", "c"]
        ])
        XCTAssertEqual(testCollection.permutations(taking: nil, repeating: true), [
            ["a", "a", "a"],
            ["a", "a", "b"],
            ["a", "a", "c"],
            ["a", "b", "a"],
            ["a", "b", "b"],
            ["a", "b", "c"],
            ["a", "c", "a"],
            ["a", "c", "b"],
            ["a", "c", "c"],
            ["b", "a", "a"],
            ["b", "a", "b"],
            ["b", "a", "c"],
            ["b", "b", "a"],
            ["b", "b", "b"],
            ["b", "b", "c"],
            ["b", "c", "a"],
            ["b", "c", "b"],
            ["b", "c", "c"],
            ["c", "a", "a"],
            ["c", "a", "b"],
            ["c", "a", "c"],
            ["c", "b", "a"],
            ["c", "b", "b"],
            ["c", "b", "c"],
            ["c", "c", "a"],
            ["c", "c", "b"],
            ["c", "c", "c"]
        ])
    }

    func testNonRepeatingPermutations() {
        XCTAssertEqual(testCollection.permutations(taking: 2),
                       [["a", "b"], ["a", "c"], ["b", "a"], ["b", "c"], ["c", "a"], ["c", "b"]])
        XCTAssertEqual(testCollection.permutations(), [
            ["a", "b", "c"],
            ["a", "c", "b"],
            ["b", "a", "c"],
            ["b", "c", "a"],
            ["c", "a", "b"],
            ["c", "b", "a"]
        ])
    }

    func testEmptyCollections() {
        XCTAssertTrue([].combinations().isEmpty)
        XCTAssertTrue([].permutations().isEmpty)

        (0...2).forEach {
            XCTAssertTrue([].combinations(taking: $0).isEmpty)
            XCTAssertTrue([].combinations(taking: $0, repeating: true).isEmpty)
            XCTAssertTrue([].permutations(taking: $0).isEmpty)
            XCTAssertTrue([].permutations(taking: $0, repeating: true).isEmpty)
        }
    }

    func testRandomCombination() {
        let numbers = Array(1...3)
        XCTAssertEqual(numbers.randomCombination(), numbers)

        numbers.randomCombination(repeating: true).forEach {
            XCTAssertTrue(numbers.contains($0))
        }

        var rng = TestingRandomNumberGenerator(values: [0, 8, 8])
        XCTAssertEmpty([].randomCombination())
        XCTAssertEmpty([].randomCombination(repeating: true))
        XCTAssertEmpty([].randomCombination(using: &rng))

        XCTAssertEqual(numbers.randomCombination(using: &rng), numbers.combinations().first)
        XCTAssertEqual(numbers.randomCombination(using: &rng, repeating: true), [2, 3, 3])
    }

    func testRandomPermutation() {
        let numbers = Array(1...3)

        numbers.randomPermutation().forEach {
            XCTAssertTrue(numbers.contains($0))
        }

        numbers.randomPermutation(repeating: true).forEach {
            XCTAssertTrue(numbers.contains($0))
        }

        var rng = TestingRandomNumberGenerator(values: [0, 16, 16])

        XCTAssertEmpty([].randomPermutation())
        XCTAssertEmpty([].randomPermutation(repeating: true))
        XCTAssertEmpty([].randomPermutation(using: &rng))

        XCTAssertEqual(numbers.randomPermutation(using: &rng), [3, 1, 2])
        XCTAssertEqual(numbers.randomPermutation(using: &rng, repeating: true), [3, 3, 1])
    }
}

struct TestingRandomNumberGenerator: RandomNumberGenerator {
    var values: [Int]

    mutating func next() -> UInt64 {
        guard values.isEmpty == false else {
            return .max
        }

        return UInt64(values.removeFirst())
    }
}
