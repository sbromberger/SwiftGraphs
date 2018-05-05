import Dispatch

//func timeIt(_ fn: () -> ()) -> UInt64 {
//    let start = DispatchTime.now()
//    fn()
//    let end = DispatchTime.now()
//    return (end.uptimeNanoseconds - start.uptimeNanoseconds)
//}

//var ba = BitArray(repeating: false, count: 10)
//ba[3] = true
//print(ba.count)
//print(ba)
//let edge = Edge(UInt(1), UInt(2))
//let edge2 = Edge(1, 2)
//let edges = [Edge(0, 1), Edge(1, 2), Edge(2, 3), Edge(3, 4), Edge(1, 3)]
//let g = Graph(fromEdgeList: edges)
//print(g)
//print(g.rowidx)
//print(g.colptr)
//
//
//print("neighbors of vertex 1: \(g.neighbors(of: 1))")
//print("vertices of g = \(Array(g.vertices))")
//print("edges of g = \(g.edges())")
//let start = DispatchTime.now()
//let h = Graph<UInt32>(fromFile: "/Users/bromberger1/dev/swift/SwiftGraphs/SwiftGraphs/data/edgecsv-10m-100m.csv")
//let end = DispatchTime.now()
//print("graph read took \(Double(end.uptimeNanoseconds - start.uptimeNanoseconds) / 1_000_000_000.0) s")
//let timeit = timeIt { _ = g.BFS(from: 0) }
//
//print("timeit = \(timeit / 1000) us")
var start = DispatchTime.now()
let h = Graph<UInt32>(fromVecFile: "/Users/seth/dev/swift/SwiftGraphs/data/indptrvecs-4m-30m.0based.txt")
var end = DispatchTime.now()
print("graph read took \(Double(end.uptimeNanoseconds - start.uptimeNanoseconds) / 1_000_000.0) ms")
//
print(h)
for i in 1...5 {
    start = DispatchTime.now()
    let bfs1 = h.BFS(from: 0)
    end = DispatchTime.now()
//let timeit = end2.uptimeNanoseconds - start2.uptimeNanoseconds
    print("Run \(i): BFS from vertex 0 to \(Double(end.uptimeNanoseconds - start.uptimeNanoseconds) / 1_000_000.0) ms; sum = \(bfs1.reduce(0, +))")
}
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

//import Foundation

//var arr1 = (1...5_000_000).map{_ in arc4random()}
//var arr2 = arr1
//var arr3 = arr1
//let start = DispatchTime.now()
//radixSort(&arr1)
//let end = DispatchTime.now()
//print("radixSort(&arr1) time \(Double(end.uptimeNanoseconds - start.uptimeNanoseconds) / 1_000_000.0) ms")
//
//print("arr1 == arr2 = \(arr1 == arr2)")
//let startb = DispatchTime.now()
//arr2.sort()
//let endb = DispatchTime.now()
//print("arr2.sort() time \(Double(endb.uptimeNanoseconds - startb.uptimeNanoseconds) / 1_000_000.0) ms")
//print("arr1 == arr2 = \(arr1 == arr2)")
//print("arr1 == arr3 = \(arr1 == arr3)")
//let startc = DispatchTime.now()
//arr3.radixSort()
//let endc = DispatchTime.now()
//print("arr3.radixSort() time \(Double(endc.uptimeNanoseconds - startc.uptimeNanoseconds) / 1_000_000.0) ms")
//print("arr1 == arr3 = \(arr1 == arr3)")
