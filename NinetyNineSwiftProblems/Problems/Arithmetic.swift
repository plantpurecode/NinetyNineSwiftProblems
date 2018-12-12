//
//  Arithmetic.swift
//  NinetyNineSwiftProblems
//
//  Created by Jacob Relkin on 11/1/18.
//  Copyright © 2018 Jacob Relkin. All rights reserved.
//

import Foundation

infix operator ^^ : MultiplicationPrecedence

func ^^ (radix: Int, power: Int) -> Int {
    return Int(pow(Double(radix), Double(power)))
}

struct Primes {
    enum Error : Swift.Error {
        case greatestIndexTooLarge
        case negativeGreatestIndex
        case negativeNumber
    }
    
    static func generate(upTo n: Int) -> [Int] {
        var composite = Array(repeating: false, count: n + 1)
        var primes: [Int] = []
        
        if n >= 55 {
            // Upper bound for the number of primes up to and including `n`,
            // from https://en.wikipedia.org/wiki/Prime_number_theorem#Non-asymptotic_bounds_on_the_prime-counting_function :
            let d = Double(n)
            let upperBound = Int(d / (log(d) - 4))
            primes.reserveCapacity(upperBound)
        }
        
        let squareRootN = Int(Double(n).squareRoot())
        
        (2...squareRootN).filter { !composite[$0] }.forEach { p in
            primes.append(p)
            
            for q in stride(from: p * p, through: n, by: p) {
                composite[q] = true
            }
        }
        
        return primes + (squareRootN...n).filter { !composite[$0] }
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
        return m / gcd(m, n) * n
    }
 
    static func listPrimesInRange(range: ClosedRange<Int>) -> List<Int>? {
        let primes = Primes.generate(upTo: range.upperBound)
        
        return List(primes.filter {
            $0 >= range.lowerBound
        })
    }
    
    static func goldbachCompositions(inRange range: ClosedRange<Int>, aboveMinimum minimum: Int = 2) -> [Int : (Int, Int)] {
        return range.dropFirst().reduce([:]) { result, current in
            guard let goldbach = current.goldbach(aboveMinimum: minimum) else {
                return result
            }
            
            var res = result
            res[current] = goldbach
            return res
        }
    }
    
    static func printGoldbachCompositionsLimited(inRange range: ClosedRange<Int>, aboveMinimum minimum: Int = 2) {
        let compositions = goldbachCompositions(inRange: range, aboveMinimum: minimum).sorted { (first, second) -> Bool in
            return first.key < second.key
        }
        
        print("\nPrinting \(compositions.count) Goldbach compositions...\n")
        print(compositions.reduce("") { (result, current) -> String in
            let (key, value) = current
            return [result, "\(key) = \(value.0) + \(value.1)"].joined(separator: "\n")
        })
    }
    
    func isPrime() -> Bool {
        guard self >= 2 else {
            return false
        }
        
        if [2, 3].contains(self) {
            return true
        }

        for i in 2...Int(Double(self).squareRoot()) {
            if self % i == 0 {
                return false
            }
        }
        
        return true
    }
    
    func isCoprimeTo(_ other: Int) -> Bool {
        return Int.gcd(self, other) == 1
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
    
    func goldbach(aboveMinimum minimum: Int = 3) -> (Int, Int)? {
        // TODO: Throw specific errors instead of returning nil
        guard self != 2 else {
            return (1, 1)
        }
        
        guard self != 3 else {
            return (1, 2)
        }
        
        guard self > 3, minimum >= 3, self % 2 == 0 else {
            return nil
        }
        
        for first in 0...self/2 {
            let both = [first, self - first]
            if !both.allSatisfy({ $0 >= minimum }) {
                continue
            }
            
            if (try? both.allPrime()) ?? false {
                return both.convertToBinaryTuple()
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
    
    var primeFactors: List<Int>? {
        guard self > 1 else {
            return nil
        }
        
        return List(_rawPrimeFactorization())
    }

    var primeFactorMultiplicity: List<(Int, Int)> {
        return List(primeFactorMultiplicityDict.map { ($0.key, $0.value) })!
    }
    
    var primeFactorMultiplicityDict: [Int : Int] {
        let factors = _rawPrimeFactorization()
        return factors.reduce([Int:Int]()) { (res, factor) -> [Int:Int] in
            var result = res
            result[factor] = (res[factor] ?? 0) + 1
            return result
        }
    }
}

extension Array where Element == Int {
    func allPrime(greatestIndex: Int = -1) throws -> Bool {
        guard contains(where: { $0 < 0 }) == false else {
            throw Primes.Error.negativeNumber
        }
        
        guard greatestIndex >= -1 else {
            throw Primes.Error.negativeGreatestIndex
        }

        let gi = greatestIndex == -1 ? count-1 : greatestIndex
        guard gi < count else {
            throw Primes.Error.greatestIndexTooLarge
        }

        guard count >= 15 else {
            // Use individual invocations of isPrime
            return allSatisfy { $0.isPrime() }
        }
    
        let greatest = self[gi]
        let primes = Primes.generate(upTo: greatest)
        
        if primes == self {
            return true
        }
        
        return Set(primes).fullyIntersects(other: Set(self))
    }
}

