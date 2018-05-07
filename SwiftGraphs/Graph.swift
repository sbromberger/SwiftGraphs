import Foundation

protocol AbstractGraph {
    associatedtype T: FixedWidthInteger where T.Stride: SignedInteger
    var eltype: Any.Type { get }
    var isDirected: Bool { get }
    var nv: T { get }
    var ne: Int { get }
    var vertices: CountableRange<T> { get }
    var edges: [Edge<T>] { get }
    var degrees: [T] { get }
    func hasEdge(_ edge: Edge<T>) -> Bool
    func degree(of vertex: T) -> Int
    func neighbors(of vertex: T) -> ArraySlice<T>
    func inNeighbors(of vertex: T) -> ArraySlice<T>
    func outNeighbors(of vertex: T) -> ArraySlice<T>
}

public struct Graph<T: FixedWidthInteger> : AbstractGraph where T.Stride: SignedInteger {
    let rowidx: Array<T>
    let colptr: Array<Array<T>.Index>
    let isDirected: Bool = false
    var eltype: Any.Type { return T.self }

    public var nv: T { return T((colptr.count - 1)) }
    public var ne: Int { return rowidx.count / 2 }
    
    public var vertices: CountableRange<T> {
        return (0 as T)..<nv
    }

    public init(fromEdgeList edgeList: [Edge<T>]) {
        let orderedEdgeList = edgeList.map { $0.ordered }
        let reversedEdgeList = orderedEdgeList.map { $0.reverse }
        let allEdges = (orderedEdgeList + reversedEdgeList).sorted()

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
        for v in (0 as T)...numVertices {
            f_ind.append(srcs.searchSortedIndex(val: v).0)
        }
        rowidx = dsts
        colptr = f_ind
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
    
    public func inNeighbors(of vertex: T) -> ArraySlice<T> { return neighbors(of: vertex) }
    public func outNeighbors(of vertex: T) -> ArraySlice<T> { return neighbors(of: vertex) }
    
    public var edges: [Edge<T>] {
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

    public var degrees: [T] {
        return (1 ..< colptr.count).map { T(colptr[$0] - colptr[$0 - 1]) }
    }

    public func degree(of vertex: Int) -> Int {
        return colptr[vertex + 1] - colptr[vertex]
    }

    public var degreeHistogram: [T: Int] {
        var degHist = [T:Int]()
        for d in degrees {
            degHist[d, default: 0] += 1
        }
        return degHist
    }
    
    public var connectedComponents : [[T]] {
        var label = [T](repeating: 0, count: Int(nv))
        for u in vertices {
            if label[Int(u)] == 0 {
                label[Int(u)] = u
                var Q = [T]()
                Q.append(u)
                if let src = Q.popLast() {
                    for vertex in neighbors(of: src) {
                        if label[Int(vertex)] == 0 {
                            Q.append(vertex)
                            label[Int(vertex)] = u
                        }
                    }
                }
            }
        }
        var componentDict = [T: T]()
        var cVec = [[T]]()
        var i: T = 0
        for (v, l) in label.enumerated() {
            let optIndex  = componentDict[l]
            if optIndex == nil {
                componentDict.updateValue(i, forKey: l)
            }
            let index = optIndex ?? i
            
            if cVec.count > index {
                cVec[Int(index)].append(T(v))
            } else {
                cVec.append([T(v)])
                i += 1
            }
        }
        
        return cVec
    }

    public var isConnected : Bool {
        return ne + 1 >= nv && connectedComponents.count == 1
    }
    
    public func degree(of vertex: T) -> Int {
        return degree(of: Int(vertex))
    }

    public func BFS(from sourceVertex:T) -> [T] {
        let numVertices = Int(nv)
        var vertLevel = Array<T>(repeating: T.max, count: numVertices)
        var nLevel: T = 1
        vertLevel.withUnsafeMutableBufferPointer { vertLevel in
            let visited = UnsafeBitArray<Int>(repeating: false, count: numVertices)
            var curLevel = UnsafeArray<T>(capacity: numVertices)
            var nextLevel = UnsafeArray<T>(capacity: numVertices)
            defer {
                curLevel.deallocate()
                nextLevel.deallocate()
            }
            
            visited[Int(sourceVertex)] = true
            vertLevel[Int(sourceVertex)] = 0
            curLevel.append(sourceVertex)
            
            while !curLevel.isEmpty {
                for vertex in curLevel {
                    for neighbor in neighbors(of: vertex) {
                        if !visited[Int(neighbor)] {
                            visited[Int(neighbor)] = true
                            nextLevel.append(neighbor)
                            vertLevel[Int(neighbor)] = nLevel
                        }
                    }
                }
                nLevel += 1
                curLevel.removeAll()
                (curLevel, nextLevel) = (nextLevel, curLevel)
                curLevel.sort()
            }
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
