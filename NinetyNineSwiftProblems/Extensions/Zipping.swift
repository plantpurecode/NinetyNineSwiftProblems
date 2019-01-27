//
//  Zipping.swift
//  NinetyNineSwiftProblems
//
//  Created by Jacob Relkin on 1/27/19.
//  Copyright © 2019 Jacob Relkin. All rights reserved.
//

import Foundation

func zipAll<T>(left: [T], right: [T], defaultValue: T) -> [(T, T)] {
    return zipAll(left: left, right: right, leftShorterDefault: defaultValue, rightShorterDefault: defaultValue)
}

func zipAll<T>(left: [T], right: [T], leftShorterDefault: T, rightShorterDefault: T) -> [(T, T)] {
    let maxCount = max(left.count, right.count)
    
    var l = left, r = right
    
    l.pad(upTo: maxCount, with: leftShorterDefault)
    r.pad(upTo: maxCount, with: rightShorterDefault)
    
    return zip(l, r).map { $0 }
}
