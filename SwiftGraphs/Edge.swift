public struct Edge<T: BinaryInteger> {
    let src: T
    let dst: T

    public init(_ s: T, _ d: T) {
        src = s
        dst = d
    }

    public var ordered: Edge {
        if src > dst {
            return Edge(dst, src)
        } else { return self }
    }

    public var reverse: Edge {
        return Edge(dst, src)
    }
}

extension Edge: CustomStringConvertible {
    public var description: String {
        return "\(src) -> \(dst)"
    }
}

extension Edge: Hashable {
    var HashValue: Int {
        return [Int(src) << Int.bitWidth + Int(dst)].hashValue
    }
}

extension Edge: Comparable {
    public static func == (lhs: Edge, rhs: Edge) -> Bool {
        return lhs.src == rhs.src && lhs.dst == rhs.dst
    }

    public static func < (lhs: Edge, rhs: Edge) -> Bool {
        if lhs.src < rhs.src { return true }
        if lhs.src > rhs.src { return false }
        return lhs.dst < rhs.dst
    }
}
