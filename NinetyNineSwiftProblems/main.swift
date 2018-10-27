//
//  main.swift
//  NinetyNineSwiftProblems
//
//  Created by Jacob Relkin on 7/14/18.
//  Copyright © 2018 jacobrelkin. All rights reserved.
//

import Foundation

// Ninety-Nine Swift Problems.

class List<T> {
    var value: T
    var nextItem: List<T>?
    
    convenience init?(_ values: T...) {
        self.init(Array(values))
    }
    
    init?(_ values: [T]) {
        guard let first = values.first else {
            return nil
        }
        value = first
        nextItem = List(Array(values.suffix(from: 1)))
    }
}

extension List {
    func append(_ list: List<T>) {
        last.nextItem = list
    }
    
    func insert(_ list: List<T>) {
        if let next = nextItem {
            list.append(next)
        }
        
        nextItem = list
    }
    
    var last: List<T> {
        var item = self
        while let next = item.nextItem {
            item = next
        }
        
        return item
    }
    
    var penultimate: List<T> {
        var item:List<T>? = self
        while let i = item {
            if i.nextItem?.nextItem == nil {
                break
            }
            
            item = i.nextItem
        }
        
        return item!
    }
    
    subscript(index: Int) -> List<T>? {
        var count = 0
        var item = Optional(self)
        
        while count < index {
            item = item?.nextItem
            
            if item == nil {
                return nil
            }
            
            count += 1
        }
        
        return item
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
    
    func copy() -> List? {
        return List<T>(values)
    }
    
    var reversed:List<T> {
        return List(Array(values.reversed())) ?? self
    }
    
    func reverse() {
        var index = 1
        var item:List<T>? = self
        let len = length
        
        while index <= len/2 {
            let other = self[len-index]!
            let otherValue = other.value
            
            other.value = item!.value
            item!.value = otherValue
            
            item = item!.nextItem
            index += 1
        }
    }
    
    func rotate(amount: Int) -> List {
        let len = length
        let index = len > 0 ? (len + amount) % len : 0
        let parts = split(at: index)
        var result:List! = parts.1
        
        if result == nil {
            result = parts.0
        } else {
            result.append(parts.0!)
        }
        
        return result
    }
    
    func removeAt(_ position: Int) -> (rest: List?, removed: T?) {
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
        guard index < len, let newList = copy(), let nodeToInsert = List(value) else {
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
    
    func randomSelect(_ amount: Int) -> List {
        var new = copy()!
        var vals = [T]()
        
        for _ in 0..<amount {
            let randomIndex = Int(arc4random_uniform(UInt32(new.length)))
            let (rest, value) = new.removeAt(randomIndex)
            if let rest = rest {
                new = rest
            }
            
            if let value = value {
                vals.append(value)
            }
        }
        
        return List(vals)!
    }
}

extension List where T == Int {
    class func lotto(numbers: Int, _ maximum: Int) -> List {
        var values = Set<Int>()
        var index = 0
        while index < numbers {
            let random = Int(arc4random_uniform(UInt32(maximum)))
            if values.contains(random) {
                continue
            }
            
            values.insert(random)
            index += 1
        }
        
        return List(Array(values))!
    }
    
    class func range(from: Int, _ to: Int) -> List {
        precondition(from < to)
        
        let values = Array(from...to)
        return List(values)!
    }
}

extension List where T == Any {
    var flattened:List<T> {
        let list = List<T>(values)!
        list.flatten()
        return list
    }
    
    // Recursive flatten that returns a new List
    private func flattenNew() -> List {
        var values = [T]()
        var node = Optional(self)
        
        while let n = node {
            if let subList = n.value as? List<T> {
                values.append(contentsOf: subList.flattenNew().values)
            } else {
                values.append(n.value)
            }
            
            node = n.nextItem
        }
        
        return List<T>(values)!
    }
    
    // Inline flatten
    func flatten() {
        var node = Optional(self)
        
        while let n = node {
            let nn = n.nextItem
            if let subList = n.value as? List {
                subList.flatten()
                
                n.value = subList.value
                
                if let next = n.nextItem {
                    subList.append(next)
                }
                
                n.nextItem = subList.nextItem
            }
            
            node = nn
        }
    }
}

extension List where T:Equatable {
    func isPalindrome() -> Bool {
        var cNode:List<T>? = reversed
        var csNode = Optional(self)
        
        while let node = cNode, let snode = csNode {
            if node.value != snode.value {
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
            let value = n.value
            
            repeat {
                node = node!.nextItem
            } while node?.value == value
            
            n.nextItem = node
        }
    }
    
    var compressed: List<T> {
        let list = List(values)!
        list.compress()
        return list
    }
    
    var packed: List<List<T>> {
        var node = Optional(self)
        var outerList = [List<T>]()
        
        while let n = node {
            var innerList = [T]()
            var nn:List<T>? = n
            
            repeat {
                innerList.append(n.value)
                nn = nn?.nextItem
            } while n.value == nn?.value
            
            outerList.append(List(innerList)!)
            node = nn
        }
        
        return List<List<T>>(outerList)!
    }
    
    func encode() -> List<(Int, T)> {
        var node = Optional(self)
        var outerList = [(Int, T)]()
        
        while let n = node {
            var nn:List<T>? = n
            var count = 0
            
            repeat {
                count += 1
                nn = nn?.nextItem
            } while n.value == nn?.value
            
            let tuple = (count, n.value)
            outerList.append(tuple)
            node = nn
        }
        
        return List<(Int, T)>(outerList)!
    }
    
    func encodeModified() -> List<Any> {
        var node = Optional(self)
        var outerList = [Any]()
        
        while let n = node {
            var nn:List<T>? = n
            var count = 0
            
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
            
            node = nn
        }
        
        return List<Any>(outerList)!
    }
}

extension List where T == (Int, String) {
    // Decode a run-length encoded linked list
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
        
        return List<String>(list)!
    }
}

extension List {
    // Returns a new List with duplicated values
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
        
        return List(values)
    }
    
    // Duplicates values inline
    func duplicate(times: Int = 1) {
        guard times > 0 else {
            return
        }
        
        var node = Optional(self)
        
        while let n = node {
            let next = n.nextItem
            let newNext = List(n.value)!
            
            for _ in 0..<times-1 {
                newNext.append(List(n.value)!)
            }
            
            newNext.last.nextItem = next
            n.nextItem = newNext
            node = next
        }
    }
    
    func drop(every: Int) -> List? {
        guard var head = copy() else {
            return nil
        }
        
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
            
            index += 1
            node = node?.nextItem
        }
        
        return (left, right)
    }
    
    func slice(_ from: Int, _ to: Int) -> List? {
        let endIndex = to - from - 1
        guard let list = copy(),
            let fromNode = list[from],
            let endNode = fromNode[endIndex] else {
                return nil
        }
        
        endNode.nextItem = nil
        return fromNode
    }
}

extension List where T : Hashable {
    func randomPermute() -> List {
        var permutations = Set<T>()
        
        while permutations.count < length {
            let selection = randomSelect(1).value
            if permutations.contains(selection) {
                continue
            }
            
            permutations.insert(selection)
        }
        
        return List<T>(Array(permutations))!
    }
}

extension List : Equatable where T: Equatable {
    static func == (lhs: List<T>, rhs: List<T>) -> Bool {
        return lhs.values == rhs.values
    }
}

extension List : CustomStringConvertible {
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

/// -- Tests

let values =  [1,1,2,3,5,8,6]
let list = List(values)!

assert(list.values == values)
assert(list.reversed.values == values.reversed())
assert(list.length == list.values.count)
assert(list.penultimate.value == values[values.count - 2])
assert(list.last.value == values.last)

for (i, value) in values.enumerated() {
    assert(list[i]!.value == value)
}

list.reverse()
assert(list.values == values.reversed())

let list2 = List(1,2,3,2,1)!
assert(list2.isPalindrome())
assert(List(1,2,3,4)?.isPalindrome() == false)

let nestedList = List<Any>(List<Any>(1,2, List<Any>(3, List<Any>(4, List<Any>(5, 6, 7)!)!, 8)!)!, 9)!
assert(nestedList.flattened.values as! [Int] == [1,2,3,4,5,6,7,8,9])

let list3 = List(1,2,2,3,4,4,5)!
assert(list3.compressed.values == [1,2,3,4,5])

let list4 = List(1,1,2,3,3,5,5,2,2,2)!
assert(list4.packed.values == [List(1,1), List(2), List(3,3), List(5, 5), List(2, 2, 2)].map { $0! })

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
assert(list8.decode() == List("a", "a", "a", "a", "b", "c", "c", "a", "a", "d", "e", "e", "e", "e")!)

let list9 = List("a", "b", "c", "c", "d")!
assert(list9.duplicateNew() == List("a", "a", "b", "b", "c", "c", "c", "c", "d", "d"))

let list10 = List("a", "b", "c", "c", "d")!
assert(list10.duplicateNew(times: 2) == List("a", "a", "a", "b", "b", "b", "c", "c", "c", "c", "c", "c", "d", "d", "d"))

let list11 = List("a", "b", "c", "c", "d")!
list11.duplicate()
assert(list11 == List("a", "a", "b", "b", "c", "c", "c", "c", "d", "d"))

let list12 = List("a", "b", "c", "c", "d")!
list12.duplicate(times: 3)
assert(list12 == List("a", "a", "a", "a", "b", "b", "b", "b", "c", "c", "c", "c", "c", "c", "c", "c", "d", "d", "d", "d"))

let list13 = List("a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k")!
assert(list13.drop(every: 3) == List("a", "b", "d", "e", "g", "h", "j", "k"))

let list14 = List("a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k")!
let (left, right) = list14.split(at: 3)

assert(left == List("a", "b", "c"))
assert(right == List("d", "e", "f", "g", "h", "i", "j", "k"))

let list15 = List("a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k")!
assert(list15.slice(3, 7) == List("d", "e", "f", "g")!)

let list16 = List("a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k")!
assert(list16.rotate(amount: 3) == List("d", "e", "f", "g", "h", "i", "j", "k", "a", "b", "c"))
assert(list16.rotate(amount: -2) == List("j", "k", "a", "b", "c", "d", "e", "f", "g", "h", "i"))

let list17 = List("a", "b", "c", "d")!
assert(list17.removeAt(1) == (List("a", "c", "d"), "b"))
assert(list17.removeAt(3) == (List("a", "b", "c"), "d"))
assert(list17.removeAt(4) == (nil, nil))

let list18 = List("a", "b", "c", "d")!
assert(list18.insertAt(index: 1, "new") == List("a", "new", "b", "c", "d"))
assert(list18.insertAt(index: 0, "new") == List("new", "a", "b", "c", "d"))
assert(list18.insertAt(index: 3, "new") == List("a", "b", "c", "d", "new"))
assert(list18.insertAt(index: 4, "new") == nil)

assert(List.range(from: 4, 9) == List(4, 5, 6, 7, 8, 9)!)

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
