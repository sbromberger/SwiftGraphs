import Foundation

public struct Graph<T: BinaryInteger> {
    let rowidx: Array<T>
    let colptr: Array<Array<T>.Index>

    static var eltype: Any.Type { return T.self }
    public var nv: T { return T((colptr.count - 1)) }
    public var ne: Int { return rowidx.count / 2 }

    public var vertices: StrideTo<T> {
        return stride(from: T(0), to: nv, by: +1)
    }

    public init(fromVecFile fileName: String) {
        var colptrRead = [Int]()
        var rowindRead = [T]()
        var inColPtr = true

        guard let reader = LineReader(path: fileName) else {
            fatalError("error opening file \(fileName)")
        }
        for var line in reader {
            line.removeLast()
            if line.hasPrefix("-----") {
                inColPtr = false
            } else {
                let n = Int(line)!
                if inColPtr {
                    colptrRead.append(n)
                } else {
                    rowindRead.append(T(n))
                }
            }
        }
        rowidx = rowindRead
        colptr = colptrRead
    }

    public init(fromBinaryFile fileName: String) {
        let file = URL(fileURLWithPath: fileName)
        let fileHandle = try! FileHandle(forReadingFrom: file)
        let magic = fileHandle.readData(ofLength: 4)
        guard magic.elementsEqual("GRPH".utf8) else {
            fatalError("\(file) was not a graph file")
        }
        let colSize = fileHandle.readData(ofLength: MemoryLayout<UInt32>.size).withUnsafeBytes { (ptr: UnsafePointer<UInt32>) -> Int in
            return Int(ptr.pointee.bigEndian)
        }
        colptr = fileHandle.readData(ofLength: MemoryLayout<UInt32>.size * colSize).withUnsafeBytes({ (ptr: UnsafePointer<UInt32>) -> [Int] in
            let bufferPointer = UnsafeBufferPointer(start: ptr, count: colSize)
            return [Int](bufferPointer.lazy.map { Int($0.bigEndian) })
        })
        let rowSize = fileHandle.readData(ofLength: MemoryLayout<UInt32>.size).withUnsafeBytes { (ptr: UnsafePointer<UInt32>) -> Int in
            return Int(ptr.pointee.bigEndian)
        }
        rowidx = fileHandle.readData(ofLength: MemoryLayout<UInt32>.size * rowSize).withUnsafeBytes({ (ptr: UnsafePointer<UInt32>) -> [T] in
            let bufferPointer = UnsafeBufferPointer(start: ptr, count: rowSize)
            return [T](bufferPointer.lazy.map { T($0.bigEndian) })
        })
    }

    public func write(toBinaryFile fileName: String) {
        let file = URL(fileURLWithPath: fileName)
        // There should be a way to make FileHandle(forWritingAtPath) create the file but I don't know it
        try! Data().write(to: file)
        let fileHandle = try! FileHandle(forWritingTo: file)
        let magic = Data("GRPH".utf8)
        fileHandle.write(magic)
        do {
            var colData = Data(repeating: 0, count: MemoryLayout<UInt32>.size * (colptr.count + 1))
            colData.withUnsafeMutableBytes { (ptr: UnsafeMutablePointer<UInt32>) -> Void in
                ptr.initialize(to: UInt32(colptr.count).bigEndian)
                let bufferPointer = UnsafeMutableBufferPointer(start: ptr.successor(), count: colptr.count)
                _ = bufferPointer.initialize(from: colptr.lazy.map { UInt32($0).bigEndian })
            }
            fileHandle.write(colData)
        }
        do {
            var rowData = Data(repeating: 0, count: MemoryLayout<UInt32>.size * (rowidx.count + 1))
            rowData.withUnsafeMutableBytes { (ptr: UnsafeMutablePointer<UInt32>) -> Void in
                ptr.initialize(to: UInt32(rowidx.count).bigEndian)
                let bufferPointer = UnsafeMutableBufferPointer(start: ptr.successor(), count: rowidx.count)
                _ = bufferPointer.initialize(from: rowidx.lazy.map { UInt32($0).bigEndian })
            }
            fileHandle.write(rowData)
        }
    }

    private func vecRange(_ s: Array<T>.Index) -> CountableRange<Array<T>.Index> {
        let rStart = colptr[s]
        let rEnd = colptr[s + 1]
        return rStart ..< rEnd
    }

    public func neighbors(of vertex: T) -> ArraySlice<T> {
        let range = vecRange(Array<T>.Index(vertex))
        return rowidx[range]
    }
    public func edges() -> [Edge<T>] {
        var edgeList = [Edge<T>]()
        edgeList.reserveCapacity(ne)
        for src in vertices {
            for dst in neighbors(of: src) {
                edgeList.append(Edge<T>(src, dst))
            }
        }
        return edgeList
    }

    public func hasEdge(_ edge: Edge<T>) -> Bool {
        let (src, dst) = (edge.src, edge.dst)

        return hasEdge(src, dst)
    }

    public func hasEdge(_ src: T, _ dst: T) -> Bool {
        return neighbors(of: src).searchSortedIndex(val: dst).1
    }

    public var degrees: [Int] {
        return (1 ..< colptr.count).map { colptr[$0] - colptr[$0 - 1] }
    }

    public func degree(of vertex: Int) -> Int {
        return colptr[vertex + 1] - colptr[vertex]
    }

    public func degree(of vertex: T) -> Int {
        return degree(of: Int(vertex))
    }

    public func BFS(from sourceVertex: Int) -> [T] {
        let numVertices = Int(nv)
        let maxT = ~T()
        var visited = BitVector(repeating: false, count: numVertices)
        var vertLevel = Array<T>(repeating: maxT, count: numVertices)
//        let vertLevelPtr = UnsafeMutableBufferPointer(start: &vertLevel, count: numVertices)
        var nLevel: T = 1
        var curLevel = [T]()
        curLevel.reserveCapacity(numVertices)
        var nextLevel = [T]()
        nextLevel.reserveCapacity(numVertices)

        visited[sourceVertex] = true
        vertLevel[sourceVertex] = 0
        curLevel.append(T(sourceVertex))

        while !curLevel.isEmpty {
            for vertex in curLevel {
                for neighbor in neighbors(of: vertex) {
                    if !visited.testAndSet(Int(neighbor)) {
                        nextLevel.append(neighbor)
//                        vertLevelPtr[Int(neighbor)] = nLevel
                        vertLevel[Int(neighbor)] = nLevel
                    }
                }
            }
            nLevel += 1
            curLevel.removeAll(keepingCapacity: true)
            (curLevel, nextLevel) = (nextLevel, curLevel)
            curLevel.sort()
        }
        return vertLevel
    }
}

extension Graph: CustomStringConvertible {
    public var description: String {
        return "{\(nv), \(ne)} Graph"
    }
}

extension Graph {
}
