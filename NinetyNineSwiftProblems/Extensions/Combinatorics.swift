//
//  Combinatorics.swift
//  NinetyNineSwiftProblems
//
//  Created by Jacob Relkin on 12/8/18.
//  Copyright © 2019 Jacob Relkin. All rights reserved.
//

import Foundation

// MARK: Combinatorics

extension Collection {
    func combinations(taking: Int? = nil, repeating: Bool = false) -> [[Element]] {
        if repeating {
            return repeatingCombinations(ArraySlice(self), taking: taking ?? count)
        }

        return nonRepeatingCombinations(ArraySlice(self), taking: taking ?? count)
    }

    func permutations(taking: Int? = nil, repeating: Bool = false) -> [[Element]] {
        if repeating {
            return repeatingPermutations(ArraySlice(self), taking: taking ?? count)
        }

        return nonRepeatingPermutations(ArraySlice(self), taking: taking ?? count)
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

private func repeatingCombinations<T>(_ elements: ArraySlice<T>, taking: Int) -> [[T]] {
    guard taking > 0 else {
        return []
    }

    guard elements.isEmpty == false, taking > 1 else {
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

private func nonRepeatingCombinations<T>(_ elements: ArraySlice<T>, taking: Int) -> [[T]] {
    guard elements.count >= taking else { return [] }
    guard elements.isEmpty == false && taking > 0 else { return [] }

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

private func nonRepeatingPermutations<T>(_ elements: ArraySlice<T>, taking: Int) -> [[T]] {
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

private func repeatingPermutations<T>(_ elements: ArraySlice<T>, taking: Int) -> [[T]] {
    guard taking > 0 else { return [] }
    guard elements.isEmpty == false, taking > 1 else {
        return elements.map { [$0] }
    }

    return elements.reduce([[T]]()) { res, element in
        res + repeatingPermutations(elements, taking: taking - 1).map {
            [element] + $0
        }
    }
}
