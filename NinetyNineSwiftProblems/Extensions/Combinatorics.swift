//
//  Combinatorics.swift
//  NinetyNineSwiftProblems
//
//  Created by Jacob Relkin on 12/8/18.
//  Copyright © 2018 Jacob Relkin. All rights reserved.
//

import Foundation

// MARK: Combinatorics

extension Array {
    func combinations(taking: Int? = nil, repeating: Bool = false) -> [[Element]] {
        if repeating {
            return repeatingCombinations(self, taking: taking ?? count)
        }
        
        return nonRepeatingCombinations(self, taking: taking ?? count)
    }
    
    func permutations(taking: Int? = nil, repeating: Bool = false) -> [[Element]] {
        if repeating {
            return repeatingPermutations(self, taking: taking ?? count)
        }
        
        return nonRepeatingPermutations(self, taking: taking ?? count)
    }
}

// MARK: - Miscellaneous

extension Array {
    mutating func pad(upTo n: Int, with padding: Element) {
        guard n > 0 else {
            return
        }
        
        self += (0..<n).map { _ in padding }
    }
}

// MARK: - Private Combinatoric functions

fileprivate func repeatingCombinations<T>(_ elements: [T], taking: Int) -> [[T]] {
    guard elements.count >= 0 && taking > 0 else {
        return []
    }
    
    guard taking > 1 else {
        return elements.map { [$0] }
    }
    
    var reducedElements = elements
    return elements.reduce([[T]]()) { res, element in
        let combined = res + repeatingCombinations(reducedElements, taking: taking - 1).map {
            [element] + $0
        }
        
        reducedElements.removeFirst()
        return combined
    }
}

fileprivate func nonRepeatingCombinations<T>(_ elements: [T], taking: Int) -> [[T]] {
    guard elements.count >= taking else { return [] }
    guard elements.count > 0 && taking > 0 else { return [] }
    
    guard taking > 1 else {
        return elements.map { [$0] }
    }
    
    return elements.enumerated().reduce([[T]]()) { res, tuple in
        var reducedElements = elements
        reducedElements.removeFirst(tuple.offset + 1)
        return res + nonRepeatingCombinations(reducedElements, taking: taking - 1).map {
            [tuple.element] + $0
        }
    }
}

fileprivate func nonRepeatingPermutations<T>(_ elements: [T], taking: Int) -> [[T]] {
    guard elements.count >= taking else { return [] }
    guard elements.count >= taking && taking > 0 else { return [] }
    
    guard taking > 1 else {
        return elements.map { [$0] }
    }
    
    return elements.enumerated().reduce([[T]]()) { res, tuple in
        var reducedElements = elements
        reducedElements.remove(at: tuple.offset)
        return res + nonRepeatingPermutations(reducedElements, taking: taking - 1).map {
            [tuple.element] + $0
        }
    }
}

fileprivate func repeatingPermutations<T>(_ elements: [T], taking: Int) -> [[T]] {
    guard elements.count >= 0 && taking > 0 else { return [] }
    guard taking > 1 else {
        return elements.map {[$0]}
    }
    
    return elements.reduce([[T]]()) { res, element in
        return res + repeatingPermutations(elements, taking: taking - 1).map {
            [element] + $0
        }
    }
}
