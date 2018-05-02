import Dispatch

func timeIt(_ fn: () -> ()) -> UInt64 {
    let start = DispatchTime.now()
    fn()
    let end = DispatchTime.now()
    return (end.uptimeNanoseconds - start.uptimeNanoseconds)
}

var ba = BitArray(repeating: false, count: 10)
ba[3] = true
print(ba.count)
print(ba)
let edge = Edge(UInt(1), UInt(2))
let edge2 = Edge(1, 2)
let edges = [Edge(0, 1), Edge(1, 2), Edge(2, 3), Edge(3, 4), Edge(1, 3)]
let g = Graph(fromEdgeList: edges)
print(g)
print(g.rowidx)
print(g.colptr)


print("neighbors of vertex 1: \(g.neighbors(of: 1))")
print("vertices of g = \(Array(g.vertices))")
print("edges of g = \(g.edges())")
//let start = DispatchTime.now()
//let h = Graph<UInt32>(fromFile: "/Users/bromberger1/dev/swift/SwiftGraphs/SwiftGraphs/data/edgecsv-10m-100m.csv")
//let end = DispatchTime.now()
//print("graph read took \(Double(end.uptimeNanoseconds - start.uptimeNanoseconds) / 1_000_000_000.0) s")
//let timeit = timeIt { _ = g.BFS(from: 0) }
//
//print("timeit = \(timeit / 1000) us")
let start = DispatchTime.now()
let h = Graph<UInt32>(fromVecFile: "/Users/bromberger1/dev/swift/SwiftGraphs/data/indptrvecs-1m-10m.0based.txt")
let end = DispatchTime.now()
print("graph read took \(Double(end.uptimeNanoseconds - start.uptimeNanoseconds) / 1_000_000_000.0) s")

print(h)
let start2 = DispatchTime.now()
let bfs1 = h.BFS(from: 0)
let end2 = DispatchTime.now()
let timeit = end2.uptimeNanoseconds - start2.uptimeNanoseconds

print("BFS from vertex 0 = \(Double(timeit) / 1_000_000_000) s; top 5 = \(bfs1[0..<5])")

//let h = Graph<UInt32>(fromFile: "g1.csv")
//print("ne = \(h.ne)")
//print("nv = \(h.nv)")
//let foo = h.edges()
//print("type of foo = \(type(of: foo))")
//print("vertices of h = \(Array(h.vertices))")
//print("edges of h = \(h.edges())")
//print("h has edge (1,2) = \(h.hasEdge(Edge<UInt32>(1, 2)))")
//print("h has edge (1,4) = \(h.hasEdge(Edge<UInt32>(1, 4)))")
//print("h has edge (1,2) = \(h.hasEdge(1, 2))")
//print("h has edge (1,4) = \(h.hasEdge(1, 4))")
//
// print("g.test = \(g.test)")
