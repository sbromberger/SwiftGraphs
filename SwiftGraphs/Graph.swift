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

    public init(fromEdgeList edgeList: [Edge<T>]) {
        let orderedEdgeList = edgeList.map { $0.ordered }
        let reversedEdgeList = orderedEdgeList.map { $0.reverse }
        let allEdges = (orderedEdgeList + reversedEdgeList).sorted()

        var numVertices = T(0)
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
        for v in stride(from: 0 as T, through: numVertices, by: +1) {
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
            autoreleasepool {
                if line.hasPrefix("-----") {
                    inColPtr = false
                } else {
                    let n = Int(line)!
                    if inColPtr {
                        colptrRead.append(n)
                    } else {
                        rowindRead.append(T.init(n))
                    }
                }
            }
        }
        rowidx = rowindRead
        colptr = colptrRead
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
        let (_, found) = neighbors(of: src).searchSortedIndex(val: dst)
        return found
    }
    
    public func BFS(from sourceVertex:T) -> [T] {
        let numVertices = Int(nv)
        let maxT = ~T()
        var visited = BitArray(repeating: false, count: numVertices)
        var vertLevel = Array<T>(repeating: maxT, count: numVertices)
        var nLevel = T(1)
        var curLevel = [T]()
        curLevel.reserveCapacity(numVertices)
        var nextLevel = [T]()
        nextLevel.reserveCapacity(numVertices)
        
        visited[Int(sourceVertex)] = true
        vertLevel[Int(sourceVertex)] = T(0)
        curLevel.append(sourceVertex)
        
        while !curLevel.isEmpty {
            for vertex in curLevel {
                for neighbor in neighbors(of: vertex) {
                    if !visited.unsafeTestAndSet(Int(neighbor)) {
                        nextLevel.append(neighbor)
                        vertLevel[Int(neighbor)] = nLevel
                    }
                }
            }
            nLevel += T(1)
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
