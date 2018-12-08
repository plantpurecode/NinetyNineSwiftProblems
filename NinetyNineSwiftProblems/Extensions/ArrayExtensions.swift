//
//  ArrayExtensions.swift
//  NinetyNineSwiftProblems
//
//  Created by Jacob Relkin on 12/8/18.
//  Copyright © 2018 Jacob Relkin. All rights reserved.
//

import Foundation

// Combinatoric extensions on Array

func repeatingCombinations<T>(_ elements: [T], taking: Int) -> [[T]] {
    guard elements.count >= 0 && taking > 0 else {
        return [[]]
    }
    
    guard taking > 1 else {
        return elements.map { [$0] }
    }
    
    var combinations = [[T]]()
    var reducedElements = elements
    
    elements.forEach { element in
        combinations += repeatingCombinations(reducedElements, taking: taking - 1).map {
            [element] + $0
        }
        
        reducedElements.removeFirst()
    }
    
    return combinations
}

func nonRepeatingCombinations<T>(_ elements: [T], taking: Int) -> [[T]] {
    guard elements.count >= taking else { return [] }
    guard elements.count > 0 && taking > 0 else { return [[]] }
    
    guard taking > 1 else {
        return elements.map { [$0] }
    }
    
    var combinations = [[T]]()
    
    elements.enumerated().forEach { index, element in
        var reducedElements = elements
        reducedElements.removeFirst(index + 1)
        combinations += nonRepeatingCombinations(reducedElements, taking: taking - 1).map {
            [element] + $0
        }
    }
    
    return combinations
}

func nonRepeatingPermutations<T>(_ elements: [T], taking: Int) -> [[T]] {
    guard elements.count >= taking else { return [] }
    guard elements.count >= taking && taking > 0 else { return [[]] }
    
    guard taking > 1 else {
        return elements.map { [$0] }
    }
    
    var permutations = [[T]]()
    elements.enumerated().forEach { index, element in
        var reducedElements = elements
        reducedElements.remove(at: index)
        permutations += nonRepeatingPermutations(reducedElements, taking: taking - 1).map {
            [element] + $0
        }
    }
    
    return permutations
}

func repeatingPermutations<T>(_ elements: [T], taking: Int) -> [[T]] {
    guard elements.count >= 0 && taking > 0 else { return [[]] }
    guard taking > 1 else {
        return elements.map {[$0]}
    }
    
    var permutations = [[T]]()
    elements.forEach { element in
        permutations += repeatingPermutations(elements, taking: taking - 1).map {
            [element] + $0
        }
    }
    
    return permutations
}

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
