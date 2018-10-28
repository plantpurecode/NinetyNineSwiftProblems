//
//  List.swift
//  NinetyNineSwiftProblems
//
//  Created by Jacob Relkin on 10/28/18.
//  Copyright © 2018 Jacob Relkin. All rights reserved.
//

import Foundation

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
    
    var reversed:List<T> {
        let copied = copy()!
        copied.reverse()
        return copied
    }
    
// MARK: -
    
    func copy() -> List? {
        return List<T>(values)
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
        guard let list = copy(),
            let fromNode = list[from],
            let endNode = fromNode[endIndex] else {
                return nil
        }
        
        endNode.nextItem = nil
        return fromNode
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

extension List where T : Equatable {
    static func == (lhs: List<T>, rhs: [T]) -> Bool {
        return lhs.values == rhs
    }
    
    static func == (lhs: List<T>, rhs: T) -> Bool {
        guard lhs.length == 1, let first = lhs[0] else {
            return false
        }
        
        return first.value == rhs
    }

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
            defer {
                n.nextItem = node
            }
            
            let value = n.value
            
            repeat {
                node = node!.nextItem
            } while node?.value == value
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
            
            defer {
                node = nn
            }
            
            repeat {
                innerList.append(n.value)
                nn = nn?.nextItem
            } while n.value == nn?.value
            
            outerList.append(List(innerList)!)
        }
        
        return List<List<T>>(outerList)!
    }
    
    func encode() -> List<(Int, T)> {
        var node = Optional(self)
        var outerList = [(Int, T)]()
        
        while let n = node {
            var nn:List<T>? = n
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
        
        return List<(Int, T)>(outerList)!
    }
    
    func encodeModified() -> List<Any> {
        var node = Optional(self)
        var outerList = [Any]()
        
        while let n = node {
            var nn:List<T>? = n
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