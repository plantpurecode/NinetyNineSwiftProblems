//
//  StringExtensions.swift
//  NinetyNineSwiftProblems
//
//  Created by Jacob Relkin on 1/29/19.
//  Copyright © 2019 Jacob Relkin. All rights reserved.
//

import Foundation

public extension String {
    subscript(_ i: Int) -> Self {
        let idx1 = index(startIndex, offsetBy: i)
        let idx2 = index(idx1, offsetBy: 1)
        return String(self[idx1..<idx2])
    }

    subscript (r: Range<Int>) -> String {
        let start = index(startIndex, offsetBy: r.lowerBound)
        let end = index(startIndex, offsetBy: r.upperBound)
        return String(self[start ..< end])
    }

    subscript (r: CountableClosedRange<Int>) -> String {
        let startIndex = self.index(self.startIndex, offsetBy: r.lowerBound)
        let endIndex = self.index(startIndex, offsetBy: r.upperBound - r.lowerBound)
        return String(self[startIndex...endIndex])
    }

    func scan(`for` matching: (Character) -> Bool, fromIndex from: Int = 0) -> Int? {
        guard from < count - 1 else {
            return nil
        }

        let suff = suffix(count - from)
        guard let matchedChar = suff.first(where: matching) else {
            return nil
        }

        return suff.firstIndex(of: matchedChar)?.utf16Offset(in: self)
    }
}
