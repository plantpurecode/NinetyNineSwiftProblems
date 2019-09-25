//
//  CollectionExtensions.swift
//  NinetyNineSwiftProblems
//
//  Created by Jacob Relkin on 9/25/19.
//  Copyright © 2019 Jacob Relkin. All rights reserved.
//

import Foundation

extension Collection {
    func allNil<T>() -> Bool where Element == Optional<T> {
        return allSatisfy { $0 == nil }
    }

    func allNotNil<T>() -> Bool where Element == Optional<T> {
        return allSatisfy { $0 != nil }
    }
}

extension Collection where Element : Hashable {
    func allContained<C: Collection>(in collection: C) -> Bool where C.Element == Element {
        return allSatisfy { collection.contains($0) }
    }

    func allNotContained<C: Collection>(in collection: C) -> Bool where C.Element == Element {
        return allSatisfy { !collection.contains($0) }
    }

    func removingAllContained<C: Collection>(in collection: C) -> [Element] where C.Element == Element {
        return filter { collection.contains($0) }
    }

    func removingAllNotContained<C: Collection>(in collection: C) -> [Element] where C.Element == Element {
        return filter { !collection.contains($0) }
    }
}