//
//  ListTests.swift
//  NinetyNineSwiftProblems
//
//  Created by Jacob Relkin on 10/28/18.
//  Copyright © 2018 Jacob Relkin. All rights reserved.
//

import Foundation

func runListTests() {
    let values =  [1,1,2,3,5,8,6]
    let list = List(values)!

    assert(list == values)
    assert(list.reversed == values.reversed())
    assert(list.length == list.values.count)
    assert(list.penultimate.value == values[values.count - 2])
    assert(list.last.value == values.last)

    for (i, value) in values.enumerated() {
        assert(list[i]!.value == value)
    }

    list.reverse()
    assert(list == values.reversed())

    let list2 = List(1,2,3,2,1)!
    assert(list2.isPalindrome())
    assert(List(1,2,3,4)?.isPalindrome() == false)

    let nestedList = List<Any>(List<Any>(1,2, List<Any>(3, List<Any>(4, List<Any>(5, 6, 7)!)!, 8)!)!, 9)!
    assert(nestedList.flattened.values as! [Int] == [1,2,3,4,5,6,7,8,9])

    let list3 = List(1,2,2,3,4,4,5)!
    assert(list3.compressed == [1,2,3,4,5])

    let list4 = List(1,1,2,3,3,5,5,2,2,2)!
    assert(list4.packed == [List(1,1), List(2), List(3,3), List(5, 5), List(2, 2, 2)].map { $0! })

    let list5 = List(1,1,2,2,3,3,5,5,5,2,2,2)!
    let expected5 = [(2,1), (2,2), (2,3), (3,5), (3,2)]
    list5.encode().values.enumerated().forEach { i, value in
        assert(value == expected5[i])
    }

    let list6 = List(1)!
    list6.append(List(2)!)
    assert(list6 == List(1,2))

    let list7 = List(1,2,2,3,5,5,5,2,2,2)!
    assert(list7.encodeModified().description == "[1, (2, 2), 3, (3, 5), (3, 2)]")

    let list8 = List((4, "a"), (1, "b"), (2, "c"), (2, "a"), (1, "d"), (4, "e"))!
    assert(list8.decode() == ["a", "a", "a", "a", "b", "c", "c", "a", "a", "d", "e", "e", "e", "e"])

    let list9 = List("a", "b", "c", "c", "d")!
    assert(list9.duplicateNew()! == ["a", "a", "b", "b", "c", "c", "c", "c", "d", "d"])

    let list10 = List("a", "b", "c", "c", "d")!
    assert(list10.duplicateNew(times: 2)! == ["a", "a", "a", "b", "b", "b", "c", "c", "c", "c", "c", "c", "d", "d", "d"])

    let list11 = List("a", "b", "c", "c", "d")!
    list11.duplicate()
    assert(list11 == ["a", "a", "b", "b", "c", "c", "c", "c", "d", "d"])

    let list12 = List("a", "b", "c", "c", "d")!
    list12.duplicate(times: 3)
    assert(list12 == ["a", "a", "a", "a", "b", "b", "b", "b", "c", "c", "c", "c", "c", "c", "c", "c", "d", "d", "d", "d"])

    let list13 = List("a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k")!
    assert(list13.drop(every: 3)! == ["a", "b", "d", "e", "g", "h", "j", "k"])

    let list14 = List("a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k")!
    let (left, right) = list14.split(at: 3)

    assert(left! == ["a", "b", "c"])
    assert(right! == ["d", "e", "f", "g", "h", "i", "j", "k"])

    let list15 = List("a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k")!
    assert(list15.slice(3, 7)! == ["d", "e", "f", "g"])

    let list16 = List("a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k")!
    assert(list16.rotate(amount: 3) == ["d", "e", "f", "g", "h", "i", "j", "k", "a", "b", "c"])
    assert(list16.rotate(amount: -2) == ["j", "k", "a", "b", "c", "d", "e", "f", "g", "h", "i"])

    let list17 = List("a", "b", "c", "d")!
    assert(list17.removeAt(1) == (List("a", "c", "d"), "b"))
    assert(list17.removeAt(3) == (List("a", "b", "c"), "d"))
    assert(list17.removeAt(4) == (nil, nil))

    let list18 = List("a", "b", "c", "d")!
    assert(list18.insertAt(index: 1, "new")! == ["a", "new", "b", "c", "d"])
    assert(list18.insertAt(index: 0, "new")! == ["new", "a", "b", "c", "d"])
    assert(list18.insertAt(index: 3, "new")! == ["a", "b", "c", "d", "new"])
    assert(list18.insertAt(index: 4, "new") == nil)

    assert(List.range(from: 4, 9) == [4, 5, 6, 7, 8, 9])

    let list19 = List("a", "b", "c", "d", "e", "f", "g", "h")!
    let list19rand3 = list19.randomSelect(3)
    assert(list19rand3.length == 3)

    let lotto = List.lotto(numbers: 5, 20)
    assert(lotto.length == 5)
    assert(lotto.randomSelect(1).value < 20)

    let permutation = list19.randomPermute()
    let permSet = Set(permutation.values)

    // Assert that the permutation has the same count of, and all the elements in the list.
    assert(permSet.intersection(list19.values).count == list19.values.count)
}
