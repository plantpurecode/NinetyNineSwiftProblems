//
//  SetExtensions.swift
//  NinetyNineSwiftProblems
//
//  Created by Jacob Relkin on 11/1/18.
//  Copyright © 2019 Jacob Relkin. All rights reserved.
//

import Foundation

extension Set {
    func fullyIntersects(other: Set) -> Bool {
        return intersection(other).count == other.count
    }
}
