//
//  List.swift
//  NinetyNineSwiftProblems
//
//  Created by Jacob Relkin on 10/28/18.
//  Copyright © 2019 Jacob Relkin. All rights reserved.
//

import Foundation

// MARK: List Data Structure

class List<T> {
    var value: T
    var nextItem: List<T>?

    init(value: T) {
        self.value = value
    }

    convenience init?(_ values: T...) {
        self.init(Array(values))
    }

    init?(_ values: [T]) {
        guard let first = values.first else {
            return nil
        }
        value = first
        nextItem = List(Array(values.dropFirst()))
    }
}

// MARK: - Computed Properties

extension List {
    var last: T? {
        lastNode?.value
    }

    var lastNode: List<T>? {
        nextItem?.lastNode ?? self
    }

    var penultimate: T? {
        var current = self

        while let next = current.nextItem {
            if next.nextItem == nil {
                return current.value
            }

            current = next
        }

        return nil
    }

    var length: Int {
        var count = 0
        var item = Optional(self)

        while item != nil {
            item = item?.nextItem
            count += 1
        }

        return count
    }

    var values: [T] {
        var item = Optional(self)
        var values = [T]()

        while let value = item?.value {
            values.append(value)
            item = item?.nextItem
        }

        return values
    }

    var reversed: List<T> {
        let copied = copy()
        copied.reverse()
        return copied
    }
}

// MARK: - Functions

extension List {
    subscript(index: Int) -> List<T> {
        var node = self

        for _ in 0..<index {
            guard let next = node.nextItem else {
                return self
            }

            node = next
        }

        return node
    }

    func copy() -> List {
        // swiftlint:disable force_unwrapping
        return values.toList()!
        // swiftlint:enable force_unwrapping
    }

    func append(_ list: List<T>) {
        lastNode?.nextItem = list
    }

    func insert(_ list: List<T>) {
        if let next = nextItem {
            list.append(next)
        }

        nextItem = list
    }

    func reverse() {
        var index = 1
        var item = self
        let len = length

        while index <= len / 2 {
            let other = self[len - index]
            let otherValue = other.value

            other.value = item.value
            item.value = otherValue

            if let next = item.nextItem {
                item = next
            }

           index += 1
        }
    }

    func duplicateNew(times: Int = 1) -> List? {
        guard times > 0 else {
            return nil
        }

        var values = [T]()
        var node = Optional(self)

        while let n = node {
            for _ in 0...times {
                values.append(n.value)
            }

            node = n.nextItem
        }

        return values.toList()
    }

    func duplicate(times: Int = 1) {
        guard times > 0 else {
            return
        }

        var node = Optional(self)

        while let n = node {
            let next = n.nextItem
            let newNext = List(value: n.value)

            for _ in 0..<times - 1 {
                newNext.append(List(value: n.value))
            }

            if let next = next {
                newNext.append(next)
            }

            n.nextItem = newNext
            node = next
        }
    }

    func drop(every: Int) -> List? {
        guard every > 0 else {
            return nil
        }

        let head = copy()

        var index = 0
        var node = Optional(head)

        while let n = node {
            let next = n.nextItem

            defer {
                index += 1
                node = next
            }

            if index % every == 1 {
                // chain this next node's next to n's next node.
                n.nextItem = next?.nextItem ?? n.nextItem
            }
        }

        return head
    }

    func split(at splitIndex: Int) -> (left: List?, right: List?) {
        var node = Optional(self)
        var left: List?
        var right: List?
        var index = 0

        while let value = node?.value {
            defer {
                index += 1
                node = node?.nextItem
            }

            let newItem = List(value)

            if index < splitIndex {
                if left == nil {
                    left = newItem
                } else if let new = newItem {
                    left?.append(new)
                }
            } else {
                if right == nil {
                    right = newItem
                } else if let new = newItem {
                    right?.append(new)
                }
            }
        }

        return (left, right)
    }

    func slice(_ from: Int, _ to: Int) -> List? {
        let endIndex = to - from - 1
        let list = copy()
        guard from < list.length, endIndex > 0 else {
            return nil
        }

        let fromNode = list[from]
        let endNode = fromNode[endIndex]
        endNode.nextItem = nil
        return fromNode
    }

    func rotate(amount: Int) -> List {
        let len = length
        let index = (len + amount) % len
        let parts = split(at: index)
        let result = parts.1!

        if let firstPart = parts.0 {
            result.append(firstPart)
        }

        return result
    }

    func remove(at position: Int) -> (rest: List?, removed: T?) {
        guard position < length else {
            return (rest: nil, removed: nil)
        }

        guard position > 0 else {
            return (rest: nextItem, removed: value)
        }

        let (left, right) = split(at: position)
        if let rightNext = right?.nextItem {
            left?.nextItem = rightNext
        }

        return (rest: left, right?.value)
    }

    func insertAt(index: Int, _ value: T) -> List? {
        let len = length
        let newList = copy()
        guard index < len, let nodeToInsert = List(value) else {
            return nil
        }

        guard index > 0 else {
            nodeToInsert.nextItem = newList
            return nodeToInsert
        }

        guard index != len - 1 else {
            newList.append(nodeToInsert)
            return newList
        }

        let (left, right) = newList.split(at: index)
        let leftNext = left?.nextItem
        left?.nextItem = nodeToInsert
        nodeToInsert.nextItem = leftNext

        if let right = right {
            left?.append(right)
        }

        return left
    }

    func randomSelect(_ amount: Int) -> List? {
        var new = copy()
        var vals = [T]()

        for _ in 0..<amount {
            let randomIndex = Int.random(in: 0..<new.length)
            let (rest, value) = new.remove(at: randomIndex)
            if let rest = rest {
                new = rest
            }

            if let value = value {
                vals.append(value)
            }
        }

        return vals.toList()
    }
}

// MARK: - Class Functions where T == Int

extension List where T == Int {
    class func lotto(numbers: Int, _ maximum: Int) -> List? {
        guard numbers > 0, maximum > 0 else {
            return nil
        }

        var values = Set<Int>()
        while values.count < numbers {
            let random = Int.random(in: 0..<maximum)
            values.insert(random)
        }

        return values.toList()
    }

    class func range(from: Int, to: Int) -> List? {
        guard from < to else {
            return nil
        }

        return Array(from...to).toList()
    }
}

// MARK: - Flattening (T == Any)

extension List where T == Any {
    var flattened: List<T> {
        let list = copy()
        list.flatten()
        return list
    }

    // Inline flatten
    func flatten() {
        var node = Optional(self)

        while let n = node {
            let nn = n.nextItem
            defer {
                node = nn
            }

            if let subList = n.value as? List {
                subList.flatten()

                n.value = subList.value

                if let next = n.nextItem {
                    subList.append(next)
                }

                n.nextItem = subList.nextItem
            }
        }
    }
}

// MARK: - Equatable

extension List: Equatable where T: Equatable {
    static func == (lhs: List<T>, rhs: List<T>) -> Bool {
        lhs.values == rhs.values
    }

    static func == (lhs: List<T>, rhs: [T]) -> Bool {
        lhs.values == rhs
    }

    static func == (lhs: List<T>, rhs: T) -> Bool {
        guard lhs.length == 1 else {
            return false
        }

        return lhs[0].value == rhs
    }
}

extension List where T: Equatable {
    var compressed: List<T> {
        let list = copy()
        list.compress()
        return list
    }

    var packed: List<List<T>> {
        // A List cannot be constructed without an initial value,
        // Therefore, it is reasonable to force-unwrap List creation.

        // swiftlint:disable force_unwrapping

        var node = Optional(self)
        var outerList = [List<T>]()

        while let n = node {
            var innerList = [T]()
            var nn: List<T>? = n

            defer {
                node = nn
            }

            repeat {
                innerList.append(n.value)
                nn = nn?.nextItem
            } while n.value == nn?.value

            outerList.append(innerList.toList()!)
        }

        return outerList.toList()!
        // swiftlint:enable force_unwrapping
    }

    func isPalindrome() -> Bool {
        var cNode: List<T>? = reversed
        var csNode = Optional(self)

        while let node = cNode, let snode = csNode {
            guard node.value == snode.value else {
                return false
            }

            cNode = node.nextItem
            csNode = snode.nextItem
        }

        return true
    }

    func compress() {
        var node = Optional(self)

        while let n = node {
            defer {
                n.nextItem = node
            }

            let value = n.value

            repeat {
                node = node?.nextItem
            } while node?.value == value
        }
    }

    // MARK: Run-length encoding

    func encode() -> List<(Int, T)> {
        // swiftlint:disable force_unwrapping
        var node = Optional(self)
        var outerList = [(Int, T)]()

        while let n = node {
            var nn = Optional(n)
            var count = 0

            defer {
                node = nn
            }

            repeat {
                count += 1
                nn = nn?.nextItem
            } while n.value == nn?.value

            let tuple = (count, n.value)
            outerList.append(tuple)
        }

        return outerList.toList()!
        // swiftlint:enable force_unwrapping
    }

    func encodeModified() -> List<Any> {
        // swiftlint:disable force_unwrapping
        var node = Optional(self)
        var outerList = [Any]()

        while let n = node {
            var nn: List<T>? = n
            var count = 0

            defer {
                node = nn
            }

            repeat {
                count += 1
                nn = nn?.nextItem
            } while n.value == nn?.value

            if count > 1 {
                let tuple = (count, n.value)
                outerList.append(tuple)
            } else {
                outerList.append(n.value)
            }
        }

        return outerList.toList()!
        // swiftlint:disable force_unwrapping
    }
}

extension List where T == (Int, String) {
    // MARK: Run-length decoding
    func decode() -> List<String> {
        var node = Optional(self)
        var list = [String]()

        while let n = node {
            let (count, value) = n.value

            for _ in 0..<count {
                list.append(value)
            }

            node = n.nextItem
        }

        return list.toList()!
    }
}

extension List {
    // MARK: Combinatorics

    func randomPermute() -> List {
        let permutation = values.randomPermutation()
        return List<T>(permutation)!
    }

    func combinations(_ group: Int = 0) -> List<List<T>>? {
        let vals = values
        var count = group

        if group == 0 {
            // Default value provided - use vals.count
            count = vals.count
        }

        guard group <= vals.count else {
            return nil
        }

        let combos = vals.combinations(taking: count, repeating: false)
        return combos.map { List($0)! }.toList()!
    }

    func permutations(_ group: Int = 0) -> List<List<T>>? {
        let vals = values
        var count = group

        guard group <= vals.count else {
            return nil
        }

        if group == 0 {
            // Default value provided - use vals.count
            count = vals.count
        }

        let perms = vals.permutations(taking: count, repeating: false)
        return perms.map { List($0)! }.toList()
    }

    // MARK: Grouping

    func group3() -> List<List<List<T>>>? {
        guard length == 9 else {
            return nil
        }

        return group(groups: [2, 3, 4].toList()!)
    }

    func group(groups: List<Int>) -> List<List<List<T>>>? {
        let gVals = groups.values

        // Guard that the sum of the groups and the length of the list are equal
        guard gVals.reduce(0, +) == length else {
            return nil
        }

        var finalList = [[[T]]]()
        var index = 0
        var shouldBreak = false
        var vals = values

        let list = gVals.map { gv -> [[T]] in
            let group = vals.permutations(taking: gv, repeating: false)
            vals.removeFirst(gv)
            return group
        }

        while true {
            var row = [[T]]()

            for i in 0..<gVals.count {
                let r = list[i]
                if index == r.count - 1 {
                    shouldBreak = true
                    break
                }

                row.append(r[index])
            }

            if shouldBreak {
                break
            }

            index += 1
            finalList.append(row)
        }

        return finalList.compactMap {
            $0.compactMap { List<T>($0) }.toList()!
        }.toList()
    }
}

extension List where T == List<Any> {
    // MARK: Sorting

    func lsort() -> List<List<Any>> {
        List(values.sorted { $0.length < $1.length })!
    }

    func lsortFreq() -> List<List<Any>> {
        let listsSortedByLengthFrequencies = values.reduce(into: [Int: (Int, [List<Any>])]()) { result, list in
            var lists: [List<Any>]?
            var freq = 1

            if let (f, array) = result[list.length] {
                freq = f + 1
                lists = array
            } else {
                lists = [List<Any>]()
            }

            lists!.append(list)
            result[list.length] = (freq, lists!)
        }.sorted { (first: (length: Int, info: (freq: Int, lists: [List<Any>])), second: (length: Int, info: (freq: Int, lists: [List<Any>]))) -> Bool in
            let ff = first.info.freq, sf = second.info.freq
            guard ff != sf else {
                return first.length > second.length
            }

            return ff < sf
        }

        let results = listsSortedByLengthFrequencies.reduce(into: [List<Any>]()) { (result, tuple: (key: Int, value: (Int, [List<Any>]))) in
            result.append(contentsOf: tuple.value.1)
        }

        return results.toList()!
    }
}

// MARK: - Sequence Conformance

extension List: Sequence {
    struct ListIterator: IteratorProtocol {
        typealias Element = T

        let list: List
        var index = 0

        init(_ givenList: List) {
            list = givenList
        }

        mutating func next() -> T? {
            guard index < list.length else {
                return nil
            }

            let next = list[index]
            index += 1
            return next.value
        }
    }

    func makeIterator() -> ListIterator {
        ListIterator(self)
    }
}

// MARK: - CustomStringConvertible

extension List: CustomStringConvertible {
    public var description: String {
        var buffer = [String]()
        var current = Optional(self)

        while let value = current?.value {
            buffer.append(String(describing: value))
            current = current?.nextItem
        }

        return "[" + buffer.joined(separator: ", ") + "]"
    }
}

extension Sequence {
    func toList() -> List<Element>? {
        List(map { $0 })
    }
}
