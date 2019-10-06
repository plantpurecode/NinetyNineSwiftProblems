//
//  AssertionHelpers.swift
//  NinetyNineSwiftProblemsTests
//
//  Created by Jacob Relkin on 10/6/19.
//  Copyright © 2019 Jacob Relkin. All rights reserved.
//

import XCTest

func XCTAssertEqualCollectionIgnoringOrder<A: Collection, B: Collection>(_ a: A, _ b: B, file: StaticString = #file, line: UInt = #line) where A.Element: Hashable, A.Element == B.Element {
    let aSet = Set(a)
    let bSet = Set(b)

    XCTAssertEqual(aSet, bSet, file: file, line: line)
}

func XCTAssertEmpty<C: Collection>(_ collection: C?, empty: Bool = true, file: StaticString = #file, line: UInt = #line) {
    XCTAssertEqual(collection?.isEmpty, empty, file: file, line: line)
}
