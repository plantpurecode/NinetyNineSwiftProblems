//
//  ListTests.swift
//  NinetyNineSwiftProblemsTests
//
//  Created by Jacob Relkin on 10/29/18.
//  Copyright © 2018 Jacob Relkin. All rights reserved.
//

import XCTest
@testable import NinetyNineSwiftProblems

// swiftlint:disable force_unwrapping

class ListTests: XCTestCase {
    let defaultValues = [1, 1, 2, 3, 5, 8, 6]
    // swiftlint:disable implicitly_unwrapped_optional
    var defaultList: List<Int>!
    // swiftlint:enable implicitly_unwrapped_optional

    override func setUp() {
        super.setUp()

        defaultList = List(defaultValues)!
    }

    func testInitWithOneValue() {
        let list = List(value: 5)
        XCTAssertEqual(list.value, 5)
        XCTAssertNil(list.nextItem)
    }

    func testValueEquality() {
        XCTAssertTrue(defaultList == defaultValues)
    }

    func testComparators() {
        // List to List
        XCTAssertTrue(List(1, 2, 3) == List(1, 2, 3))

        // List to Array
        XCTAssertTrue(List(1, 2, 3)! == [1, 2, 3])

        // Single value comparison
        XCTAssertTrue(List(1)! == 1)
        XCTAssertFalse(List(1, 2)! == 1)
    }

    func testReversed() {
        XCTAssertTrue(defaultList.reversed == defaultValues.reversed())
    }

    func testLength() {
        XCTAssertTrue(defaultList.length == defaultValues.count)
    }

    func testSubscripting() {
        let values = defaultList.values
        for (i, value) in values.enumerated() {
            XCTAssertEqual(defaultList[i].value, value)
        }

        // Shouldn't allow subscripting above length
        XCTAssertEqual(defaultList[100], defaultList)
    }

    func testPenultimate() {
        XCTAssertTrue(defaultList.penultimate == defaultValues[defaultValues.count - 2])
        XCTAssertNil(List(value: 1).penultimate)
    }

    func testLast() {
        XCTAssertTrue(defaultList.last == defaultValues.last)
    }

    func testValue() {
        for (i, value) in defaultValues.enumerated() {
            XCTAssertTrue(defaultList[i].value == value)
        }
    }

    func testReverse() {
        let copy = defaultList.copy()
        copy.reverse()
        XCTAssertTrue(copy == defaultValues.reversed())
    }

    func testPalindromes() {
        XCTAssertTrue(List(1, 2, 3, 2, 1)?.isPalindrome() ?? false)
        XCTAssertFalse(List(1, 2, 3, 4)?.isPalindrome() ?? true)
    }

    func testFlattening() {
        let nestedList = List<Any>(List<Any>(1, 2, List<Any>(3, List<Any>(4, List<Any>(5, 6, 7)!)!, 8)!)!, 9)
        XCTAssertTrue(nestedList?.flattened.values as? [Int] == [1, 2, 3, 4, 5, 6, 7, 8, 9])
    }

    func testCompression() {
        XCTAssertEqual(List(1, 2, 2, 3, 4, 4, 5)?.compressed.values, [1, 2, 3, 4, 5])
    }

    func testPacking() {
        XCTAssertEqual(List(1, 1, 2, 3, 3, 5, 5, 2, 2, 2)?.packed.values, [List(1, 1), List(2), List(3, 3), List(5, 5), List(2, 2, 2)].compactMap { $0 })
    }

    func testEncoding() {
        let list = List(1, 1, 2, 2, 3, 3, 5, 5, 5, 2, 2, 2)
        let expected = [(2, 1), (2, 2), (2, 3), (3, 5), (3, 2)]
        list?.encode().values.enumerated().forEach { i, value in
            XCTAssertTrue(value == expected[i])
        }

        let list2 = List(1, 2, 2, 3, 5, 5, 5, 2, 2, 2)
        XCTAssertEqual(list2?.encodeModified().description, "[1, (2, 2), 3, (3, 5), (3, 2)]")
    }

    func testAppending() {
        let list = List(1)
        list?.append([List(2)].compactMap { $0 }[0])
        XCTAssertEqual(list, List(1, 2))
    }

    func testDecoding() {
        let list = List((4, "a"), (1, "b"), (2, "c"), (2, "a"), (1, "d"), (4, "e"))
        XCTAssertEqual(list?.decode().values, ["a", "a", "a", "a", "b", "c", "c", "a", "a", "d", "e", "e", "e", "e"])
    }

    func testDuplication() {
        let list1 = List("a", "b", "c", "c", "d")
        XCTAssertEqual(list1?.duplicateNew()?.values, ["a", "a", "b", "b", "c", "c", "c", "c", "d", "d"])

        let duplicated1 = ["a", "a", "a", "b", "b", "b", "c", "c", "c", "c", "c", "c", "d", "d", "d"]
        let dupList1 = list1?.duplicateNew(times: 2)

        XCTAssertEqual(dupList1?.values, duplicated1)
        XCTAssertNil(list1?.duplicateNew(times: 0))

        let list2 = List("a", "b", "c", "c", "d")
        list2?.duplicate()
        XCTAssertEqual(list2?.values, ["a", "a", "b", "b", "c", "c", "c", "c", "d", "d"])

        let list3 = List("a", "b", "c", "c", "d")
        let duplicated2 = ["a", "a", "a", "a", "b", "b", "b", "b", "c", "c", "c", "c", "c", "c", "c", "c", "d", "d", "d", "d"]

        // Should NOP when passing 0 times, so run assertion again
        for t in [3, 0] {
            list3?.duplicate(times: t)
            XCTAssertEqual(list3?.values, duplicated2)
        }
    }

    func testDrop() {
        let list = List("a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k")
        XCTAssertEqual(list?.drop(every: 3)?.values, ["a", "b", "d", "e", "g", "h", "j", "k"])
        XCTAssertNil(list?.drop(every: 0))
    }

    func testSplit() {
        let list = List("a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k")!
        let (left, right) = list.split(at: 3)

        XCTAssertTrue(left! == ["a", "b", "c"])
        XCTAssertTrue(right! == ["d", "e", "f", "g", "h", "i", "j", "k"])
    }

    func testSlice() {
        let list = List("a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k")
        XCTAssertEqual(list?.slice(3, 7)?.values, ["d", "e", "f", "g"])

        // Should return nil when providing out-of-bounds range.
        let len = list?.length ?? 0
        XCTAssertNil(list?.slice(len, len))
    }

    func testRotation() {
        let list = List("a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k")
        XCTAssertEqual(list?.rotate(amount: 3).values, ["d", "e", "f", "g", "h", "i", "j", "k", "a", "b", "c"])
        XCTAssertEqual(list?.rotate(amount: -2).values, ["j", "k", "a", "b", "c", "d", "e", "f", "g", "h", "i"])
    }

    func testRemoveAt() {
        let list = List("a", "b", "c", "d")!
        XCTAssertTrue(list.remove(at: 0) == (List("b", "c", "d"), "a"))
        XCTAssertTrue(list.remove(at: 1) == (List("a", "c", "d"), "b"))
        XCTAssertTrue(list.remove(at: 3) == (List("a", "b", "c"), "d"))
        XCTAssertTrue(list.remove(at: 4) == (nil, nil))
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
        XCTAssertEqual(List.range(from: 4, to: 9)?.values, [4, 5, 6, 7, 8, 9])
        XCTAssertNil(List.range(from: 0, to: -1))
    }

    func testRandomSelect() {
        let list = List("a", "b", "c", "d", "e", "f", "g", "h")!
        let rand3 = list.randomSelect(3)!

        let listSet = Set(list.values)
        let randSet = Set(rand3.values)

        XCTAssertTrue(listSet.intersection(randSet).count == rand3.length)
        XCTAssertTrue(rand3.length == 3)
        XCTAssertNil(list.randomSelect(0))
    }

    func testLotto() {
        let lotto = List.lotto(numbers: 5, 20)
        XCTAssertTrue(lotto?.length == 5)
        XCTAssertTrue(lotto?.values.contains(where: { $0 >= 20 }) == false)

        XCTAssertNil(List.lotto(numbers: 0, 1))
        XCTAssertNil(List.lotto(numbers: 0, 0))
        XCTAssertNil(List.lotto(numbers: 100, 0))
    }

    func testPermutations() {
        let list = List("a", "b", "c")!
        let length = list.length
        let randomPermutation = Set(list.randomPermute().values)
        let group = Int.random(in: 1...length)

        XCTAssertTrue(randomPermutation.intersection(list.values).count == length)

        let distinctPermutations = list.permutations(group)!.values.map { $0.values }

        let set = Set(list.values)
        distinctPermutations.forEach { perm in
            let intersection = set.intersection(Set(perm))
            XCTAssertTrue(intersection.count == group)
        }

        // Test permutations without giving a group parameter.
        let list2 = List(1, 2)!
        let perms = list2.permutations()!
        let random = perms.values.randomElement()!.values
        XCTAssertTrue(random.count == list2.length)

        // Test giving a too-large group parameter.
        XCTAssertNil(List(1, 2)!.permutations(3))
    }

    func testCombinations() {
        let length = 12
        let list = List.lotto(numbers: length, 50)!
        let group = Int.random(in: 1...length)
        let combinations = list.combinations(group)!.values.map { $0.values }
        let set = Set(list.values)

        combinations.forEach { combo in
            let intersection = set.intersection(Set(combo))
            let condition = intersection.count == group
            XCTAssertTrue(condition)
        }

        // Test combinations without giving a group parameter.
        let list2 = List(1, 2)!
        let combos = list2.combinations()!
        let random = combos.values.randomElement()!.values
        XCTAssertTrue(random.count == list2.length)

        // Test giving a too-large group parameter.
        XCTAssertNil(List(1, 2)!.combinations(3))
    }

    func testGroup3() {
        let list = List("Aldo", "Beat", "Carla", "David", "Evi", "Flip", "Gary", "Hugo", "Ida")!
        let group3 = list.group3()!

        let lengthExpectations = [2, 3, 4]
        group3.values.forEach { (listOfLists: List<List<String>>) in
            let vals = listOfLists.values

            for (index, length) in lengthExpectations.enumerated() {
                XCTAssertTrue(vals[index].length == length)
            }
        }

        let expectedFirstSubset = [["Aldo", "Beat"], ["Carla", "David", "Evi"], ["Flip", "Gary", "Hugo", "Ida"]]
        XCTAssertEqual(group3.value, List<List<String>>(expectedFirstSubset.map { List($0)! })!)

        // Try calling it with a list of length != 9
        let invalidLengthList = List(Array(1...8))!
        XCTAssertNil(invalidLengthList.group3())
    }

    func testGroupN() {
        let list = List("Aldo", "Beat", "Carla", "David", "Evi", "Flip", "Gary", "Hugo", "Ida")!
        let lengthExpectations = [2, 2, 5]
        let group = list.group(groups: List(lengthExpectations)!)!

        group.values.forEach { (listOfLists: List<List<String>>) in
            let vals = listOfLists.values

            for (index, length) in lengthExpectations.enumerated() {
                XCTAssertTrue(vals[index].length == length)
            }
        }

        XCTAssertEqual(group.value, List(List("Aldo", "Beat")!, List("Carla", "David")!, List("Evi", "Flip", "Gary", "Hugo", "Ida")!))
        XCTAssertNil(list.group(groups: List(1, 2, list.length)!)) // Sum of groups is greater than the length of the list.
    }

    func testLengthSort() {
        let list = List<List<Any>>(List<Any>("a", "b", "c", "d", "e")!, List<Any>("a", "b")!, List<Any>("a", "b", "c")!)!
        let sorted = list.lsort()

        XCTAssertTrue(sorted.values.map { $0.values as? [String] } == [["a", "b"], ["a", "b", "c"], ["a", "b", "c", "d", "e"]])
    }

    func testLengthFrequencySort() {
        let list: List<List<Any>> = List(List("a", "b", "c")!, List("d", "e")!, List("f", "g", "h")!, List("d", "e")!, List("i", "j", "k", "l")!, List("m", "n")!, List("o")!)!
        let result = list.lsortFreq()

        XCTAssertEqual(result.values.map { $0.values } as? [[String]], [["i", "j", "k", "l"], ["o"], ["a", "b", "c"], ["f", "g", "h"], ["d", "e"], ["d", "e"], ["m", "n"]])
    }
}

// A small sample of tests for the Sequence implementation, just in case.
class ListSequenceTests: XCTestCase {
    let list = List(1, 2, 3)!

    func testContains() {
        XCTAssertTrue(list.contains(1))
        XCTAssertFalse(list.contains(0))
    }

    func testDropFirst() {
        XCTAssertEqual(Array(list.dropFirst()), [2, 3])
    }

    func testDropLast() {
        XCTAssertEqual(Array(list.dropLast()), [1, 2])
    }

    func testElementsEqual() {
        XCTAssertTrue(list.elementsEqual([1, 2, 3]))
    }

    func testEnumerated() {
        var index = 0
        for (i, val) in list.enumerated() {
            XCTAssertTrue(i == index)
            XCTAssertTrue(val == list[i].value)
            index += 1
        }
    }

    func testFilter() {
        XCTAssertEqual(list.filter { $0 != 1 }, [2, 3])
    }

    func testCompactMap() {
        let nilList = List<Any>([nil, nil, 1])!
        XCTAssertTrue(nilList.compactMap { $0 }.count == 1)
    }
}

// swiftlint:enable force_unwrapping
