//
//  OptionalExtensions.swift
//  NinetyNineSwiftProblems
//
//  Created by Jacob Relkin on 12/16/18.
//  Copyright © 2019 Jacob Relkin. All rights reserved.
//

import Foundation

func either<T>(_ lhs: T?, _ rhs: T) -> T {
    return lhs.or(rhs)
}

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

extension Optional where Wrapped: Numeric {
    var orZero: Wrapped {
        return or(0)
    }
}
