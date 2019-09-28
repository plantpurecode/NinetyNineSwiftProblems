//
//  StringExtensions.swift
//  NinetyNineSwiftProblems
//
//  Created by Jacob Relkin on 1/29/19.
//  Copyright © 2019 Jacob Relkin. All rights reserved.
//

import Foundation

extension String {
    func character(atIndex index: Int) -> Character? {
        guard index < count else {
            return nil
        }

        return self[self.index(startIndex, offsetBy: index)]
    }

    func substring(in range: Range<Int>) -> String? {
        guard range.lowerBound >= 0, range.upperBound <= count else {
            return nil
        }

        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(startIndex, offsetBy: range.upperBound)

        return String(self[start..<end])
    }

    func scan(`for` matching: (Character) -> Bool, fromIndex from: Int = 0) -> Int? {
        guard from < count - 1 else {
            return nil
        }

        let suff = suffix(count - from)
        guard let matchedChar = suff.filter({ matching($0) }).first else {
            return nil
        }

        return suff.firstIndex(of: matchedChar)?.utf16Offset(in: self)
    }
}
