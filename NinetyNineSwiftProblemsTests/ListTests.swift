//
//  ListTests.swift
//  NinetyNineSwiftProblemsTests
//
//  Created by Jacob Relkin on 10/29/18.
//  Copyright © 2018 Jacob Relkin. All rights reserved.
//

import Foundation
import XCTest
@testable import NinetyNineSwiftProblems

class ListTests : XCTestCase {
    let defaultValues = [1,1,2,3,5,8,6]
    var defaultList: List<Int>!
    
    override func setUp() {
        defaultList = List(defaultValues)!
    }
    
    func testValueEquality() {
        XCTAssertTrue(defaultList == defaultValues)
    }
    
    func testComparators() {
        // List to List
        XCTAssertEqual(List(1,2,3)!, List(1,2,3)!)
        
        // List to Array
        XCTAssertTrue(List(1,2,3)! == [1,2,3])
        
        // Single value comparison
        XCTAssertTrue(List(1)! == 1)
        XCTAssertFalse(List(1,2)! == 1)
    }
    
    func testReversed() {
        XCTAssertTrue(defaultList.reversed == defaultValues.reversed())
    }
    
    func testLength() {
        XCTAssertTrue(defaultList.length == defaultValues.count)
    }
    
    func testSubscripting() {
        let values = defaultList.values
        for (i, _) in values.enumerated() {
            XCTAssertEqual(defaultList[i]?.value, values[i])
        }
        
        // Shouldn't allow subscripting above length
        XCTAssertNil(defaultList[100])
    }

    func testPenultimate() {
        XCTAssertTrue(defaultList.penultimate.value == defaultValues[defaultValues.count - 2])
    }
    
    func testLast() {
        XCTAssertTrue(defaultList.last.value == defaultValues.last!)
    }
    
    func testValue() {
        for (i, value) in defaultValues.enumerated() {
            XCTAssertTrue(defaultList[i]!.value == value)
        }
    }

    func testReverse() {
        let copy = defaultList.copy()!
        copy.reverse()
        XCTAssertTrue(copy == defaultValues.reversed())
    }
    
    func testPalindromes() {
        let list = List(1,2,3,2,1)!
        XCTAssertTrue(list.isPalindrome())
        XCTAssertTrue(List(1,2,3,4)?.isPalindrome() == false)
    }

    func testFlattening() {
        let nestedList = List<Any>(List<Any>(1,2, List<Any>(3, List<Any>(4, List<Any>(5, 6, 7)!)!, 8)!)!, 9)!
        XCTAssertTrue(nestedList.flattened.values as! [Int] == [1,2,3,4,5,6,7,8,9])
    }

    func testCompression() {
        let list = List(1,2,2,3,4,4,5)!
        XCTAssertTrue(list.compressed == [1,2,3,4,5])
    }
    
    func testPacking() {
        let list = List(1,1,2,3,3,5,5,2,2,2)!
        XCTAssertTrue(list.packed == [List(1,1), List(2), List(3,3), List(5, 5), List(2, 2, 2)].map { $0! })
    }
    
    func testEncoding() {
        let list = List(1,1,2,2,3,3,5,5,5,2,2,2)!
        let expected = [(2,1), (2,2), (2,3), (3,5), (3,2)]
        list.encode().values.enumerated().forEach { i, value in
            XCTAssertTrue(value == expected[i])
        }
    
        let list2 = List(1,2,2,3,5,5,5,2,2,2)!
        XCTAssertTrue(list2.encodeModified().description == "[1, (2, 2), 3, (3, 5), (3, 2)]")
    }
    
    func testAppending() {
        let list = List(1)!
        list.append(List(2)!)
        XCTAssertTrue(list == List(1,2))
    }

    func testDecoding() {
        let list = List((4, "a"), (1, "b"), (2, "c"), (2, "a"), (1, "d"), (4, "e"))!
        XCTAssertTrue(list.decode() == ["a", "a", "a", "a", "b", "c", "c", "a", "a", "d", "e", "e", "e", "e"])
    }
    
    func testDuplication() {
        let list1 = List("a", "b", "c", "c", "d")!
        XCTAssertTrue(list1.duplicateNew()! == ["a", "a", "b", "b", "c", "c", "c", "c", "d", "d"])
        
        let duplicated1 = ["a", "a", "a", "b", "b", "b", "c", "c", "c", "c", "c", "c", "d", "d", "d"]
        let dupList1 = list1.duplicateNew(times: 2)!
        
        XCTAssertTrue(dupList1 == duplicated1)
        XCTAssertNil(list1.duplicateNew(times: 0))
        
        let list2 = List("a", "b", "c", "c", "d")!
        list2.duplicate()
        XCTAssertTrue(list2 == ["a", "a", "b", "b", "c", "c", "c", "c", "d", "d"])

        let list3 = List("a", "b", "c", "c", "d")!
        let duplicated2 = ["a", "a", "a", "a", "b", "b", "b", "b", "c", "c", "c", "c", "c", "c", "c", "c", "d", "d", "d", "d"]
    
        // Should NOP when passing 0 times, so run assertion again
        for t in [3, 0] {
            list3.duplicate(times: t)
            XCTAssertTrue(list3 == duplicated2)
        }
    }

    func testDrop() {
        let list = List("a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k")!
        XCTAssertTrue(list.drop(every: 3)! == ["a", "b", "d", "e", "g", "h", "j", "k"])
        
        XCTAssertNil(list.drop(every: 0))
    }
    
    func testSplit() {
        let list = List("a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k")!
        let (left, right) = list.split(at: 3)
        
        XCTAssertTrue(left! == ["a", "b", "c"])
        XCTAssertTrue(right! == ["d", "e", "f", "g", "h", "i", "j", "k"])
    }
    
    func testSlice() {
        let list = List("a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k")!
        XCTAssertTrue(list.slice(3, 7)! == ["d", "e", "f", "g"])
        
        // Should return nil when providing out-of-bounds range.
        let len = list.length
        XCTAssertNil(list.slice(len, len))
    }
    
    func testRotation() {
        let list = List("a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k")!
        XCTAssertTrue(list.rotate(amount: 3) == ["d", "e", "f", "g", "h", "i", "j", "k", "a", "b", "c"])
        XCTAssertTrue(list.rotate(amount: -2) == ["j", "k", "a", "b", "c", "d", "e", "f", "g", "h", "i"])
    }
    
    func testRemoveAt() {
        let list = List("a", "b", "c", "d")!
        XCTAssertTrue(list.removeAt(0) == (List("b", "c", "d"), "a"))
        XCTAssertTrue(list.removeAt(1) == (List("a", "c", "d"), "b"))
        XCTAssertTrue(list.removeAt(3) == (List("a", "b", "c"), "d"))
        XCTAssertTrue(list.removeAt(4) == (nil, nil))
    }
    
    func testInsertion() {
        let list = List("a", "b", "c", "d")!
        XCTAssertTrue(list.insertAt(index: 1, "new")! == ["a", "new", "b", "c", "d"])
        XCTAssertTrue(list.insertAt(index: 0, "new")! == ["new", "a", "b", "c", "d"])
        XCTAssertTrue(list.insertAt(index: 3, "new")! == ["a", "b", "c", "d", "new"])
        XCTAssertTrue(list.insertAt(index: 4, "new") == nil)
        
        list.insert(List("e", "f", "g")!)
        XCTAssertTrue(list == ["a", "e", "f", "g", "b", "c", "d"])
    }
    
    func testRange() {
        XCTAssertTrue(List.range(from: 4, 9) == [4, 5, 6, 7, 8, 9])
    }
    
    func testRandomSelect() {
        let list = List("a", "b", "c", "d", "e", "f", "g", "h")!
        let rand3 = list.randomSelect(3)
        let listSet = Set(list.values)
        let randSet = Set(rand3.values)
        
        XCTAssertTrue(listSet.intersection(randSet).count == rand3.length)
        XCTAssertTrue(rand3.length == 3)
    }
    
    func testLotto() {
        let lotto = List.lotto(numbers: 5, 20)
        XCTAssertTrue(lotto.length == 5)
        XCTAssertTrue(lotto.values.filter { $0 >= 20 }.count == 0)
    }
    
    func testPermutations() {
        let list = List("a", "b", "c")!
        let length = list.length
        let randomPermutation = Set(list.randomPermute().values)
        let group = Int.random(in: 1...length)

        XCTAssertTrue(randomPermutation.intersection(list.values).count == length)
        
        let distinctPermutations = list.permutations(group)!.values.map { $0.values }
        
        print("list is \(list), group is \(group), permutations are: \(distinctPermutations)")
        
        let set = Set(list.values)
        distinctPermutations.forEach { perm in
            let intersection = set.intersection(Set(perm))
            let condition = intersection.count == group
            XCTAssertTrue(condition)
        }
        
        // Test permutations without giving a group parameter.
        let list2 = List(1,2)!
        let perms = list2.permutations()!
        let random = perms.values.randomElement()!.values
        XCTAssertTrue(random.count == list2.length)
        
        // Test giving a too-large group parameter.
        XCTAssertNil(List(1,2)!.permutations(3))
    }
    
    func testCombinations() {
        let length = 12
        let list = List.lotto(numbers: length, 50)
        let group = Int.random(in: 1...length)
        let combinations = list.combinations(group)!.values.map { $0.values }
        
        print("list is \(list), group is \(group), combos are: \(combinations)")
        
        let set = Set(list.values)
        combinations.forEach { combo in
            let intersection = set.intersection(Set(combo))
            let condition = intersection.count == group
            XCTAssertTrue(condition)
        }
        
        // Test combinations without giving a group parameter.
        let list2 = List(1,2)!
        let combos = list2.combinations()!
        let random = combos.values.randomElement()!.values
        XCTAssertTrue(random.count == list2.length)
        
        // Test giving a too-large group parameter.
        XCTAssertNil(List(1,2)!.combinations(3))
    }
}
