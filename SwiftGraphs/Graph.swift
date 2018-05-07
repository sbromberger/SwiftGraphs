import Foundation

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

public struct Graph<T: BinaryInteger> {
    let rowidx: Array<T>
    let colptr: Array<Array<T>.Index>

    static var eltype: Any.Type { return T.self }
    public var nv: T { return T((colptr.count - 1)) }
    public var ne: Int { return rowidx.count / 2 }

    public var vertices: StrideTo<T> {
        return stride(from: T(0), to: nv, by: +1)
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

    private func vecRange(_ s: Array<T>.Index) -> CountableRange<Array<T>.Index> {
        let rStart = colptr[s]
        let rEnd = colptr[s + 1]
        return rStart ..< rEnd
    }

    public func neighbors(of vertex: T) -> ArraySlice<T> {
        let range = vecRange(Array<T>.Index(vertex))
        return rowidx[range]
    }

    public func BFS(from sourceVertex: Int) -> [T] {
        let numVertices = Int(nv)
        let maxT = ~T()
        var visited = BitVector(repeating: false, count: numVertices)
        var vertLevel = Array<T>(repeating: maxT, count: numVertices)
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
                    if !visited[Int(neighbor)] {
                        visited[Int(neighbor)] = true
                        nextLevel.append(neighbor)
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
