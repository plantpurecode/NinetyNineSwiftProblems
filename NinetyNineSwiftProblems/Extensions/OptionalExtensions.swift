//
//  OptionalExtensions.swift
//  NinetyNineSwiftProblems
//
//  Created by Jacob Relkin on 12/16/18.
//  Copyright © 2018 Jacob Relkin. All rights reserved.
//

import Foundation

extension Optional {
    func or(_ value: Wrapped) -> Wrapped {
        switch self {
        case .none:
            return value
        case .some(let wrapped):
            return wrapped
        }
    }
}

extension Optional where Wrapped : Numeric {
    var orZero: Wrapped {
        return or(0)
    }
}

extension Collection {
    func allNil<T>() -> Bool where Element == Optional<T> {
        return allSatisfy { $0 == nil }
    }
    
    func allNotNil<T>() -> Bool where Element == Optional<T> {
        return allSatisfy { $0 != nil }
    }
}
