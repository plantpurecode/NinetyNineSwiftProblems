//
//  IntExtensions.swift
//  NinetyNineSwiftProblems
//
//  Created by Jacob Relkin on 12/18/18.
//  Copyright © 2019 Jacob Relkin. All rights reserved.
//

import Foundation

private let numberWords = [
    "zero",
    "one",
    "two",
    "three",
    "four",
    "five",
    "six",
    "seven",
    "eight",
    "nine"
].map { $0.capitalized }

extension Int {
    var even: Bool {
        return self % 2 == 0
    }

    var englishWordRepresentation: String {
        String(abs(self)).compactMap { $0.wholeNumberValue }.reduce(self < 0 ? ["Negative"] : []) {
            $0 + [numberWords[$1]]
        }.joined(separator: " ")
    }
}
