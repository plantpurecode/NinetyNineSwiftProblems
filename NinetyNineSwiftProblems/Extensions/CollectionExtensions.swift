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

extension Collection where Element : Equatable {
    func allContained(in collection: Self) -> Bool {
        return allSatisfy { collection.contains($0) }
    }

    func allNotContained(in collection: Self) -> Bool {
        return allSatisfy { !collection.contains($0) }
    }

    func removingAllContained(in collection: Self) -> [Element] {
        return filter { collection.contains($0) }
    }

    func removingAllNotContained(in collection: Self) -> [Element] {
        return filter { !collection.contains($0) }
    }
}
