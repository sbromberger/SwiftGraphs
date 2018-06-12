final class UnsafeBitArray<StorageElement: FixedWidthInteger>: RandomAccessCollection, MutableCollection {
    typealias Element = Bool

    let storage: UnsafeMutableBufferPointer<StorageElement>
    init(repeating element: Bool, count: Int) {
        let size = (count + StorageElement.bitWidth - 1) / StorageElement.bitWidth
        if element {
            storage = UnsafeMutableBufferPointer.allocate(capacity: size)
            storage.initialize(repeating: ~0)
            let extras = count % StorageElement.bitWidth
            if extras > 0 {
                storage[size - 1] &= (1 &<< extras) - 1
            }
        } else {
            storage = UnsafeMutableBufferPointer.allocate(capacity: size)
            storage.initialize(repeating: 0)
        }
    }

    var startIndex: Int { return 0 }
    var endIndex: Int { return storage.count &* StorageElement.bitWidth }

    private func getBlockAndOffset(of bitIndex: Int) -> (Int, Int) {
        return (bitIndex / StorageElement.bitWidth, bitIndex % StorageElement.bitWidth)
    }

    subscript(index: Int) -> Bool {
        get {
            return storage[index / StorageElement.bitWidth] &>> (index % StorageElement.bitWidth) & 1 == 1
        }
        set {
            if newValue {
                storage[index / StorageElement.bitWidth] |= (1 &<< (index % StorageElement.bitWidth))
            } else {
                storage[index / StorageElement.bitWidth] &= ~(1 &<< (index % StorageElement.bitWidth))
            }
        }
    }

    deinit {
        storage.deallocate()
    }
}

struct UnsafeArray<Element> {
    var count: Int
    let storage: UnsafeMutablePointer<Element>

    init(capacity: Int) {
        storage = UnsafeMutablePointer.allocate(capacity: capacity)
        count = 0
    }

    init(repeating element: Element, count: Int) {
        storage = UnsafeMutablePointer.allocate(capacity: count)
        storage.initialize(repeating: element, count: count)
        self.count = count
    }

    mutating func append(_ element: Element) {
        storage.advanced(by: count).initialize(to: element)
        count = count &+ 1
    }

    mutating func removeAll() {
        storage.deinitialize(count: count)
        count = 0
    }

    subscript(index: Int) -> Element {
        get {
            return storage.advanced(by: index).pointee
        }
        set {
            storage.advanced(by: index).pointee = newValue
        }
    }

    func deallocate() {
        storage.deinitialize(count: count)
        storage.deallocate()
    }
}

extension UnsafeArray: RandomAccessCollection, MutableCollection {
    var startIndex: Int { return 0 }
    var endIndex: Int { return count }
}
