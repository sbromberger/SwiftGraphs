//
//  ArrayExtensions.swift
//  SwiftGraphs
//
//  Created by Bromberger, Seth on 2018-05-02.
//  Copyright © 2018 Seth Bromberger. All rights reserved.
//

extension ArraySlice where Element: Comparable {
    public func searchSortedIndex(val: Element) -> (Index, Bool) {
        var (low, high) = (startIndex, endIndex)
        while low != high {
            let mid = index(low, offsetBy: distance(from: low, to: high) / 2)
            if self[mid] < val {
                low = index(after: mid)
            } else {
                high = mid
            }
        }
        let found = low < endIndex ? self[low] == val : false
        return (low, found)
    }
}

extension Array where Element: Comparable {
    public func searchSortedIndex(val: Element) -> (Index, Bool) {
        var (low, high) = (startIndex, endIndex)
        while low != high {
            let mid = index(low, offsetBy: distance(from: low, to: high) / 2)
            if self[mid] < val {
                low = index(after: mid)
            } else {
                high = mid
            }
        }
        let found = low < endIndex ? self[low] == val : false
        return (low, found)
    }
    
    public mutating func insertSorted(val: Element) {
        let (index, _) = searchSortedIndex(val: val)
        insert(val, at: index)
    }
}

