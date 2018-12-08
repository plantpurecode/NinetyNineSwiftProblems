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

struct EratosthenesSieveCache {
    private var cache: [UInt] = []
    
    mutating func update(_ ns: [UInt]) {
        guard ns.count > cache.count else {
            return
        }
        
        cache = ns
    }
    
    func hasSieve(forMaximum m: UInt) -> Bool {
        guard let last = cache.last else {
            return false
        }
        
        return last >= m
    }
    
    func sieve(forMaximum m: UInt) -> [UInt] {
        return Array(cache[0...cache.firstIndex(where: {
            return $0 >= m
        }).unsafelyUnwrapped])
    }
}

var sieveCache = EratosthenesSieveCache()

struct Primes {
    enum Error : Swift.Error {
        case greatestIndexTooLarge
        case negativeGreatestIndex
        case negativeNumber
    }
    
    static fileprivate func eratosthenesSieve(n: UInt) -> [UInt]? {
        guard n > 1 else {
            return nil
        }
        
        guard sieveCache.hasSieve(forMaximum: n) == false else {
            return sieveCache.sieve(forMaximum: n)
        }
        
        let (secondToLast, overflowed) = n.subtractingReportingOverflow(1)
        
        guard overflowed == false else {
            return nil
        }
        
        var a = Array(repeating: false, count: 2)
        a.append(contentsOf: Array(repeating: true, count: Int(secondToLast)))
        
        // TODO: Use sqrt as upper bound?
        for i in 2..<a.count where a[i] {
            var k = 2
            while k*i < a.count {
                a[k*i] = false
                k += 1
            }
        }
        
        let sieve = a.enumerated().compactMap { i in
            i.element == false ? nil : UInt(i.offset)
        }
        
        sieveCache.update(sieve)
        return sieve
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
 
    static func listPrimesInRange(range: ClosedRange<UInt>) -> List<UInt>? {
        let sieve = Primes.eratosthenesSieve(n: range.upperBound)!
        
        return List(sieve.filter {
            $0 >= range.lowerBound
        })
    }
    
    static func goldbachCompositions(inRange range: ClosedRange<Int>) -> [Int : (Int, Int)] {
        return range.filter {
            $0 > range.lowerBound && $0 % 2 == 0
        }.reduce([:]) { result, current in
            var res = result
            res[current] = current.goldbach!
            return res
        }
    }
    
    func isPrime() -> Bool {
        return (try? [self].allPrime()) ?? false
    }
    
    func isCoprimeTo(_ other: Int) -> Bool {
        return Int.gcd(self, other) == 1
    }
    
    private func _rawPrimeFactorization() -> [Int] {
        guard isPrime() == false, self > 1 else {
            return [self]
        }
        
        var n = self
        var factors = [Int]()
        for divisor in 2..<n {
            while n % divisor == 0 {
                factors.append(divisor)
                n /= divisor
            }
        }
        
        return factors
    }
    
    var totient: Int {
        guard self != 1 else {
            return 1
        }
        
        return (1..<self).filter { $0.isCoprimeTo(self) }.count
    }
    
    var goldbach: (Int, Int)? {
        // TODO: Throw specific errors instead of returning nil
        
        guard self > 2, self % 2 == 0 else {
            return nil
        }
        
        guard let primes = Primes.eratosthenesSieve(n: UInt(self)) else {
            return nil
        }
        
        let permutations = primes.permutations(taking: 2, withRepetition: false)
        let found = permutations.first { permutation in
            return permutation.first! + permutation.last! == self
        }!.map { Int($0) }
        
        return (found.first!, found.last!)
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
        
        return try map { UInt($0) }.allPrime(greatestIndex: greatestIndex)
    }
}

extension Array where Element == UInt {
    func allPrime(greatestIndex: Int = -1) throws -> Bool {
        guard greatestIndex >= -1 else {
            throw Primes.Error.negativeGreatestIndex
        }
        
        let gi = greatestIndex == -1 ? count-1 : greatestIndex
        guard gi < count else {
            throw Primes.Error.greatestIndexTooLarge
        }
        
        let greatest = self[gi]
        
        guard let sieve = Primes.eratosthenesSieve(n: greatest) else {
            return false
        }
        
        // If the sieve is equal, we're good.
        if sieve == self {
            return true
        }
        
        // Check if the sieve and self fully intersect
        return Set(sieve).fullyIntersects(other: Set(self))
    }
}
