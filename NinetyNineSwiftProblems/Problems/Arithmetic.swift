//
//  Arithmetic.swift
//  NinetyNineSwiftProblems
//
//  Created by Jacob Relkin on 11/1/18.
//  Copyright © 2019 Jacob Relkin. All rights reserved.
//

import Foundation

infix operator ^^ : MultiplicationPrecedence

func ^^ (radix: Int, power: Int) -> Int {
    Int(pow(Double(radix), Double(power)))
}

struct Primes {
    enum Error: Swift.Error {
        case greatestIndexTooLarge
        case negativeGreatestIndex
        case negativeNumber
    }

    static func generate(upTo n: Int) -> [Int] {
        var composite = Array(repeating: false, count: n + 1)
        var primes: [Int] = []

        if n >= 50 {
            // Upper bound for the number of primes up to and including `n`,
            // from https://en.wikipedia.org/wiki/Prime_number_theorem#Non-asymptotic_bounds_on_the_prime-counting_function :
            let d = Double(n)
            let upperBound = Int(d / (log(d) - 4))
            primes.reserveCapacity(upperBound)
        } else {
            primes.reserveCapacity(n)
        }

        let squareRootN = Int(Double(n).squareRoot())

        (2...squareRootN).forEach {
            guard composite[$0] == false else {
                return
            }

            primes.append($0)
            for q in stride(from: $0 * $0, through: n, by: $0) {
                composite[q] = true
            }
        }

        primes += (squareRootN + 1...n).filter { !composite[$0] }
        return primes
    }
}

extension Int {
    static func gcd(_ first: Int, _ second: Int) -> Int {
        var a = 0
        var b = first > second ? first : second
        var r = first < second ? first : second

        while r != 0 {
            a = b
            b = r
            r = a % b
        }

        return b
    }

    static func lcm(_ m: Int, _ n: Int) -> Int {
        m / gcd(m, n) * n
    }

    static func listPrimesInRange(range: ClosedRange<Int>) -> List<Int>? {
        let primes = Primes.generate(upTo: range.upperBound)

        return List(primes.filter {
            $0 >= range.lowerBound
        })
    }

    static func goldbachCompositions(inRange range: ClosedRange<Int>, aboveMinimum minimum: Int = 2) -> [Int: (Int, Int)] {
        range.dropFirst().reduce([:]) { result, current in
            guard let goldbach = try? current.goldbach(aboveMinimum: minimum) else {
                return result
            }

            var res = result
            res[current] = goldbach
            return res
        }
    }

    static func goldbachCompositionsLimited(inRange range: ClosedRange<Int>, aboveMinimum minimum: Int = 2) -> String {
        let compositions = goldbachCompositions(inRange: range, aboveMinimum: minimum).sorted { $0.key < $1.key }

        return compositions.map {
            let (key, value) = $0
            return "\(key) = \(value.0) + \(value.1)"
        }.joined(separator: ", ")
    }

    func isPrime() -> Bool {
        guard self >= 2 else {
            return false
        }

        if [2, 3].contains(self) {
            return true
        }

        return (2...Int(Double(self).squareRoot())).contains(where: { self % $0 == 0 }) == false
    }

    func isCoprimeTo(_ other: Int) -> Bool {
        Int.gcd(self, other) == 1
    }

    private func _rawPrimeFactorization() -> [Int] {
        guard isPrime() == false, self > 1 else {
            return [self]
        }

        var n = self

        return (2..<n).reduce([Int]()) { factors, divisor in
            var mutableFactors = factors
            while n % divisor == 0 {
                mutableFactors.append(divisor)
                n /= divisor
            }

            return mutableFactors
        }
    }

    var totient: Int {
        guard self != 1 else {
            return 1
        }

        return (1..<self).filter { $0.isCoprimeTo(self) }.count
    }

    func goldbach(aboveMinimum minimum: Int = 3) throws -> (Int, Int)? {
        guard self != 2 else {
            return (1, 1)
        }

        guard self != 3 else {
            return (1, 2)
        }

        guard self > 3, minimum >= 3, self % 2 == 0 else {
            return nil
        }

        for first in 0...self / 2 {
            let both = [first, self - first]
            if !both.allSatisfy({ $0 >= minimum }) {
                continue
            }

            if try both.allPrime() {
                return both.bookends()
            }
        }

        return nil
    }

    func totientImproved(_ multiplicityDict: [Int: Int]? = nil) -> Int {
        guard self != 1 else {
            return 1
        }

        let multiplicityDictionary = multiplicityDict ?? primeFactorMultiplicityDict
        return multiplicityDictionary.reduce(1) { tot, factorPair -> Int in
            let (factor, mult) = factorPair

            return tot * (factor - 1) * (factor ^^ (mult - 1))
        }
    }

    var primeFactors: [Int]? {
        guard self > 1 else {
            return nil
        }

        return _rawPrimeFactorization()
    }

    var primeFactorMultiplicity: [(Int, Int)] {
        primeFactorMultiplicityDict.map { ($0.key, $0.value) }
    }

    var primeFactorMultiplicityDict: [Int: Int] {
        let factors = _rawPrimeFactorization()
        return factors.reduce([Int: Int]()) { res, factor -> [Int: Int] in
            var result = res
            result[factor] = (res[factor] ?? 0) + 1
            return result
        }
    }
}

extension Collection where Element == Int, Index == Int {
    func allPrime(greatestIndex: Int = -1) throws -> Bool {
        guard contains(where: { $0 < 0 }) == false else {
            throw Primes.Error.negativeNumber
        }

        guard greatestIndex >= -1 else {
            throw Primes.Error.negativeGreatestIndex
        }

        let gi = greatestIndex == -1 ? count - 1 : greatestIndex
        guard gi < count else {
            throw Primes.Error.greatestIndexTooLarge
        }

        guard count >= 15 else {
            // Use individual invocations of isPrime
            return allSatisfy { $0.isPrime() }
        }

        let greatest = self[gi]
        let primes = Primes.generate(upTo: greatest)

        if primes.elementsEqual(self) {
            return true
        }

        return Set(primes).fullyIntersects(other: Set(self))
    }
}
