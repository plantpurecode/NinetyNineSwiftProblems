//
//  Arithmetic.swift
//  NinetyNineSwiftProblems
//
//  Created by Jacob Relkin on 11/1/18.
//  Copyright © 2018 Jacob Relkin. All rights reserved.
//

import Foundation

fileprivate func eratosthenesSieve(n: UInt) -> [UInt]? {
    guard n > 1 else {
        return nil
    }
    
    let secondToLast = n.unsafeSubtracting(1)
    var a = Array(repeating: false, count: 2)
    a.append(contentsOf: Array(repeating: true, count: Int(secondToLast)))
    
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

extension Int {
    func isPrime() -> Bool {
        return [self].allPrime()
    }
}

extension Array where Element == Int {
    func allPrime(greatestIndex: Int = -1) -> Bool {
        return self.map { UInt($0) }.allPrime(greatestIndex: greatestIndex)
    }
}

extension Array where Element == UInt {
    
    // TODO: Use Error type to bubble up error of too big index provided.
    
    func allPrime(greatestIndex: Int = -1) -> Bool {
        let gi = greatestIndex == -1 ? count-1 : greatestIndex
        guard gi < count else {
            return false
        }
        
        let greatest = self[gi]
        
        guard let sieve = eratosthenesSieve(n: greatest) else {
            return false
        }
        
        // If the sieve is equal, we're good.
        if sieve == self {
            return true
        }
        
        // Check if the sieve and self fully intersect
        let sieveSet = Set(sieve)
        let selfSet = Set(self)
        
        return sieveSet.intersection(selfSet).count == count
    }
}
