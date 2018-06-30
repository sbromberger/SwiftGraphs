import Foundation
import Gzip

public struct Graph<T: FixedWidthInteger>: SimpleGraph where T.Stride: SignedInteger {
    @usableFromInline let rowidx: Array<T>
    @usableFromInline let colptr: Array<Array<T>.Index>
    @usableFromInline let isDirected: Bool = false
    var eltype: Any.Type { return T.self }

    public var ne: Int { return rowidx.count / 2 }

    public var density: Double {
        return Double(ne) / Double(Int(nv)) / Double(Int(nv - 1)) * 2
    }

    public init(fromEdgeList edgeList: [Edge<T>]) {
        let orderedEdgeList = edgeList.map { $0.ordered }
        let orderedAndReversedEdgeList = (orderedEdgeList +  orderedEdgeList.map { $0.reverse }).sorted()
        
        var allEdges = [Edge<T>]([orderedAndReversedEdgeList[0]])
        for newEdge in orderedAndReversedEdgeList[1...] {
            if newEdge != allEdges.last {
                allEdges.append(newEdge)
            }
        }

        var numVertices: T = 0
        var srcs = [T]()
        var dsts = [T]()
        srcs.reserveCapacity(allEdges.count)
        dsts.reserveCapacity(allEdges.count)

        for edge in allEdges {
            srcs.append(edge.src)
            dsts.append(edge.dst)
            if numVertices < edge.src {
                numVertices = edge.src
            }
            if numVertices < edge.dst {
                numVertices = edge.dst
            }
        }
        numVertices += 1
        var f_ind = [Array<T>.Index]()
        for v in (0 as T) ... numVertices {
            f_ind.append(srcs.searchSortedIndex(val: v).0)
        }
        rowidx = dsts
        colptr = f_ind
    }

    public init(fromCSV fileName: String) {
        let x = LineReader(path: fileName)
        print("in init: \(fileName)")
        guard let reader = x else {
            fatalError("File not found: \(fileName)")
        }
        var edges = [Edge<T>]()
        var ln = 0
        for line in reader {
            ln += 1
            if (ln % 1_000_000) == 0 {
                print(ln)
            }
            let splits = line.trimmingCharacters(in: .whitespacesAndNewlines).split(separator: ",", maxSplits: 2)
            let src = T(Int(splits[0])!)
            let dst = T(Int(splits[1])!)
            edges.append(Edge(src, dst))
        }

        self.init(fromEdgeList: edges)
    }
    
    @inlinable public init(fromVecFile fileName:String, oneIndexed:Bool = true) {
        var colptrRead = [Int]()
        var rowindRead = [T]()
        var inColPtr = true
        let offset = oneIndexed ? -1 : 0

        guard let reader = LineReader(path: fileName) else {
            fatalError("error opening file \(fileName)")
        }
        var i = 0
        for var line in reader {
            i += 1
            if (i % 1_000_000) == 0 {
                print("\(i/1_000_000)m")
            }
            line.removeLast()
            if line.hasPrefix("-----") {
                print("new vector")
                inColPtr = false
            } else {
                let n = Int(line)!
                if inColPtr {
                    colptrRead.append(n + offset)
                } else {
                    rowindRead.append(T(n + offset))
                }
            }
        }
        rowidx = rowindRead
        colptr = colptrRead
    }

    @inlinable public init(fromBinaryFile fileName: String) {
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

    @inlinable public func write(toBinaryFile fileName: String) {
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

    @inlinable public func inNeighbors(of vertex: T) -> ArraySlice<T> { return outNeighbors(of: vertex) }
    @inlinable public func neighbors(of vertex: T) -> ArraySlice<T> { return outNeighbors(of: vertex) }

    @inlinable public func inDegree(of vertex: T) -> Int { return outDegree(of: vertex) }
    @inlinable public func degree(of vertex: T) -> Int { return outDegree(of: vertex) }
}

extension Graph: CustomStringConvertible {
    public var description: String {
        return "{\(nv), \(ne)} Graph"
    }
}
