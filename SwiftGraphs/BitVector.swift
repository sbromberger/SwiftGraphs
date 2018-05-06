//
//  BitVector.swift
//  SwiftGraphs
//
//  Created by Bromberger, Seth on 2018-05-05.
//  Copyright © 2018 Seth Bromberger. All rights reserved.
//

public struct BitVector {
    private var bits: Array<Int>

    private let blockSize = Int.bitWidth

    public init(repeating: Bool, count: Int) {
        let fillInt = repeating ? ~0 : 0
        let nBlocks: Int = (count / blockSize) + 1
        bits = [Int](repeating: fillInt, count: nBlocks)
    }

    private func getBlockAndOffset(of bitIndex: Int) -> (Int, Int) {
        return (bitIndex / blockSize, bitIndex % blockSize)
    }

//    public let startIndex = 0
    public var startIndex: Int { return 0 }
    public var endIndex: Int { return bits.count * blockSize }

    public subscript(_ bitIndex: Int) -> Bool {
        get {
            let (block, offset) = getBlockAndOffset(of: bitIndex)
            let mask = 1 << offset
            return mask & bits[block] != 0
        }
        set {
            let (block, offset) = getBlockAndOffset(of: bitIndex)
            let mask = 1 << offset
            if newValue {
                bits[block] |= mask
            } else {
                bits[block] &= ~mask
            }
        }
    }

    public mutating func testAndSet(_ bitIndex: Int) -> Bool {
        let (block, offset) = getBlockAndOffset(of: bitIndex)
        let mask = 1 << offset
        let oldval = mask & bits[block] != 0
        if !oldval {
            bits[block] |= mask
        }
        return oldval
    }
}
