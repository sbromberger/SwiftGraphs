import Foundation

public struct DiGraph<T: FixedWidthInteger>: SimpleGraph where T.Stride: SignedInteger {
    let rowidx: Array<T>
    let colptr: Array<Array<T>.Index>
    let backwardRowidx: Array<T>
    let backwardColptr: Array<Array<T>.Index>

    let isDirected: Bool = true
    var eltype: Any.Type { return T.self }

    public var ne: Int { return rowidx.count }

    public var density: Double {
        return Double(ne) / Double(Int(nv)) / Double(Int(nv - 1))
    }

    public init(fromEdgeList edges: [Edge<T>]) {
        let sortedForwardEdges = edges.sorted()
        let sortedReverseEdges = (edges.map { $0.reverse }).sorted()
        var allForwardEdges = [Edge<T>]([sortedForwardEdges[0]])
        var allReverseEdges = [Edge<T>]([sortedReverseEdges[0]])
        for newEdge in sortedForwardEdges[1...] {
            if newEdge != allForwardEdges.last {
                allForwardEdges.append(newEdge)
            }
        }
        for newEdge in sortedReverseEdges[1...] {
            if newEdge != allReverseEdges.last {
                allReverseEdges.append(newEdge)
            }
        }


        var numVertices: T = 0
        var forwardSrcs = [T]()
        var forwardDsts = [T]()
        forwardSrcs.reserveCapacity(allForwardEdges.count)
        forwardDsts.reserveCapacity(allForwardEdges.count)

        for edge in allForwardEdges {
            forwardSrcs.append(edge.src)
            forwardDsts.append(edge.dst)
            if numVertices < edge.src {
                numVertices = edge.src
            }
            if numVertices < edge.dst {
                numVertices = edge.dst
            }
        }
        
        var reverseSrcs = [T]()
        var reverseDsts = [T]()
        reverseSrcs.reserveCapacity(allReverseEdges.count)
        reverseDsts.reserveCapacity(allReverseEdges.count)

        for edge in allReverseEdges {
            reverseSrcs.append(edge.src)
            reverseDsts.append(edge.dst)
        }
        numVertices += 1
        var f_ind = [Array<T>.Index]()
        var b_ind = [Array<T>.Index]()
        for v in (0 as T) ... numVertices {
            f_ind.append(forwardSrcs.searchSortedIndex(val: v).0)
            b_ind.append(reverseSrcs.searchSortedIndex(val: v).0)
        }

        rowidx = forwardDsts
        colptr = f_ind
        backwardRowidx = reverseDsts
        backwardColptr = b_ind
    }

    public init(fromCSV fileName: String) {
        let furl = URL(fileURLWithPath: fileName)
        var edges = [Edge<T>]()
        do {
            let s = try String(contentsOf: furl)
            let lines = s.split(separator: "\n")
            for line in lines {
                let splits = line.split(separator: ",", maxSplits: 2)
                let src = T(Int(splits[0])!)
                let dst = T(Int(splits[1])!)
                edges.append(Edge(src, dst))
            }
        } catch {
            print("error processing file \(fileName): \(error)")
        }

        self.init(fromEdgeList: edges)
    }

    public init(fromBinaryFile fileName: String) {
        let file = URL(fileURLWithPath: fileName)
        let fileHandle = try! FileHandle(forReadingFrom: file)
        let magic = fileHandle.readData(ofLength: 4)
        guard magic.elementsEqual("DGPH".utf8) else {
            fatalError("\(file) was not a digraph file")
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

        let bColSize = fileHandle.readData(ofLength: MemoryLayout<UInt32>.size).withUnsafeBytes { (ptr: UnsafePointer<UInt32>) -> Int in
            return Int(ptr.pointee.bigEndian)
        }
        backwardColptr = fileHandle.readData(ofLength: MemoryLayout<UInt32>.size * bColSize).withUnsafeBytes({ (ptr: UnsafePointer<UInt32>) -> [Int] in
            let bufferPointer = UnsafeBufferPointer(start: ptr, count: bColSize)
            return [Int](bufferPointer.lazy.map { Int($0.bigEndian) })
        })
        let bRowSize = fileHandle.readData(ofLength: MemoryLayout<UInt32>.size).withUnsafeBytes { (ptr: UnsafePointer<UInt32>) -> Int in
            return Int(ptr.pointee.bigEndian)
        }
        backwardRowidx = fileHandle.readData(ofLength: MemoryLayout<UInt32>.size * bRowSize).withUnsafeBytes({ (ptr: UnsafePointer<UInt32>) -> [T] in
            let bufferPointer = UnsafeBufferPointer(start: ptr, count: bRowSize)
            return [T](bufferPointer.lazy.map { T($0.bigEndian) })
        })
    }

    public func write(toBinaryFile fileName: String) {
        let file = URL(fileURLWithPath: fileName)
        // There should be a way to make FileHandle(forWritingAtPath) create the file but I don't know it
        try! Data().write(to: file)
        let fileHandle = try! FileHandle(forWritingTo: file)
        let magic = Data("DGPH".utf8)
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
        do {
            var bColData = Data(repeating: 0, count: MemoryLayout<UInt32>.size * (backwardColptr.count + 1))
            bColData.withUnsafeMutableBytes { (ptr: UnsafeMutablePointer<UInt32>) -> Void in
                ptr.initialize(to: UInt32(backwardColptr.count).bigEndian)
                let bufferPointer = UnsafeMutableBufferPointer(start: ptr.successor(), count: backwardColptr.count)
                _ = bufferPointer.initialize(from: backwardColptr.lazy.map { UInt32($0).bigEndian })
            }
            fileHandle.write(bColData)
        }
        do {
            var bRowData = Data(repeating: 0, count: MemoryLayout<UInt32>.size * (backwardRowidx.count + 1))
            bRowData.withUnsafeMutableBytes { (ptr: UnsafeMutablePointer<UInt32>) -> Void in
                ptr.initialize(to: UInt32(backwardRowidx.count).bigEndian)
                let bufferPointer = UnsafeMutableBufferPointer(start: ptr.successor(), count: backwardRowidx.count)
                _ = bufferPointer.initialize(from: backwardRowidx.lazy.map { UInt32($0).bigEndian })
            }
            fileHandle.write(bRowData)
        }
    }

    public var outDegrees: [T] {
        return (1 ..< colptr.count).map { T(colptr[$0] - colptr[$0 - 1]) }
    }

    public var inDegrees: [T] {
        return (1 ..< backwardColptr.count).map { T(backwardColptr[$0] - backwardColptr[$0 - 1]) }
    }

    public var degrees: [T] {
        return zip(outDegrees, inDegrees).map { $0 + $1 }
    }

    private func backwardVecRange(_ s: Array<T>.Index) -> CountableRange<Array<T>.Index> {
        let rStart = backwardColptr[s]
        let rEnd = backwardColptr[s + 1]
        return rStart ..< rEnd
    }

    public func inNeighbors(of vertex: T) -> ArraySlice<T> {
        let range = backwardVecRange(Array<T>.Index(vertex))
        return backwardRowidx[range]
    }

    func neighbors(of vertex: T) -> ArraySlice<T> {
        return inNeighbors(of: vertex) + outNeighbors(of: vertex)
    }

    func inDegree(of vertex: T) -> Int {
        return backwardColptr[Int(vertex) + 1] - backwardColptr[Int(vertex)]
    }

    func degree(of vertex: T) -> Int {
        return inDegree(of: vertex) + outDegree(of: vertex)
    }
}

extension DiGraph: CustomStringConvertible {
    public var description: String {
        return "{\(nv), \(ne)} Directed Graph"
    }
}

extension DiGraph {
}
