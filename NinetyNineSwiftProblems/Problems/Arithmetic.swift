//
//  Arithmetic.swift
//  NinetyNineSwiftProblems
//
//  Created by Jacob Relkin on 11/1/18.
//  Copyright © 2018 Jacob Relkin. All rights reserved.
//

import Foundation

struct Primes {
    enum Error : Swift.Error {
        case greatestIndexTooLarge
    }
    
    static fileprivate func eratosthenesSieve(n: UInt) -> [UInt]? {
        guard n > 1 else {
            return nil
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
        
        return a.enumerated().compactMap { i in
            i.element == false ? nil : UInt(i.offset)
        }
    }
}

extension Int {
    func isPrime() -> Bool {
        return (try? [self].allPrime()) ?? false
    }
    
    func isCoprimeTo(_ other: Int) -> Bool {
        return Int.gcd(self, other) == 1
    }
    
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
}

extension Array where Element == Int {
    func allPrime(greatestIndex: Int = -1) throws -> Bool {
        return try self.map { UInt($0) }.allPrime(greatestIndex: greatestIndex)
    }
}

extension Array where Element == UInt {
    func allPrime(greatestIndex: Int = -1) throws -> Bool {
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
