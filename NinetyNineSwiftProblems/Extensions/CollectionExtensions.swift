//
//  CollectionExtensions.swift
//  NinetyNineSwiftProblems
//
//  Created by Jacob Relkin on 9/25/19.
//  Copyright © 2019 Jacob Relkin. All rights reserved.
//

import Foundation

extension Collection {
    func allNil<T>() -> Bool where Element == T? {
        allSatisfy { $0 == nil }
    }

    func allNotNil<T>() -> Bool where Element == T? {
        allSatisfy { $0 != nil }
    }
}

extension Collection where Element: Equatable {
    func allContained<C: Collection>(in collection: C) -> Bool where C.Element == Element {
        allSatisfy { collection.contains($0) }
    }

    func allNotContained<C: Collection>(in collection: C) -> Bool where C.Element == Element {
        allSatisfy { !collection.contains($0) }
    }

    func removingAllContained<C: Collection>(in collection: C) -> [Element] where C.Element == Element {
        filter { !collection.contains($0) }
    }
}

extension BidirectionalCollection {
    func bookends() -> (head: Element, tail: Element)? {
        guard let first = first, let last = last, count >= 2 else {
            return nil
        }

        return (head: first, tail: last)
    }

    func splitHeadAndTails() -> (head: Element, tails: [Element])? {
        guard let head = first else {
            return nil
        }

        return (head: head, tails: Array(dropFirst()))
    }
}
