import Dispatch

// func timeIt(_ fn: () -> ()) -> UInt64 {
//    let start = DispatchTime.now()
//    fn()
//    let end = DispatchTime.now()
//    return (end.uptimeNanoseconds - start.uptimeNanoseconds)
// }

// var ba = BitArray(repeating: false, count: 10)
// ba[3] = true
// print(ba.count)
// print(ba)
// let edge = Edge(UInt(1), UInt(2))
// let edge2 = Edge(1, 2)

//let fn = CommandLine.arguments[1]
//let fn = "/Users/bromberger1/dev/swift/SwiftGraphs/data/friendster-indptrvecs.txt"
//print("opening file \(fn)")
//let gg = Graph<UInt32>(fromVecFile: fn, oneIndexed:true)
//print("writing file \(fn + ".bin")")
//gg.write(toBinaryFile:fn + ".bin")
//exit(0)

let ms = 1_000_000.0
extension Double {
    func truncate(places: Int) -> Double {
        return Double(floor(pow(10.0, Double(places)) * self) / pow(10.0, Double(places)))
    }
}

let edges: [Edge<UInt8>] = [Edge(0, 1), Edge(1, 2), Edge(2, 3), Edge(3, 4), Edge(1, 3)]
//let g = Graph<UInt8>(fromEdgeList: edges)
//let dg = DiGraph<UInt8>(fromEdgeList: edges)
var start = DispatchTime.now()
let g = Graph<UInt32>(fromBinaryFile: "/Users/bromberger1/dev/swift/SwiftGraphs/data/friendster-indptrvecs.txt.bin")
var end = DispatchTime.now()
print("graph load took \(Double(end.uptimeNanoseconds - start.uptimeNanoseconds) / 1_000_000.0) ms")

// print(g)
print(g)
//print(g.degrees)

start = DispatchTime.now()
let yy = g.BFS(from: 1)
print("len(yy) = \(yy.count)")
//let zz = g.dijkstraShortestPaths(from: 1, withPaths: true, trackVertices: true)
end = DispatchTime.now()
//print("dsp = \(zz)")
print("dsp took \(Double(end.uptimeNanoseconds - start.uptimeNanoseconds) / 1_000_000.0) ms")

exit(0)


var edgeList = (0..<100_000).map { v in Edge(v, (v+1) % 100000) }
let coretest = Graph(fromEdgeList: edgeList)

start = DispatchTime.now()
let coreT = coretest.coreNumber()
end = DispatchTime.now()
//print("dsp = \(zz)")
print("coreNumber took \(Double(end.uptimeNanoseconds - start.uptimeNanoseconds) / 1_000_000.0) ms")

let edgeList2 = [
    Edge(0, 1),
    Edge(0, 4),
    Edge(0, 5),
    Edge(1, 3),
    Edge(1, 5),
    Edge(2, 3),
    Edge(2, 4),
    Edge(3, 4),
    Edge(3, 5),
    Edge(4, 5)
]
let coretest2 = Graph(fromEdgeList: edgeList2)
print("coretest2 = \(coretest2)")
print("coretest2.coreNumber = \(coretest2.coreNumber())")
exit(0)
//
//
//
// let edges2 :[Edge<UInt8>] = [Edge(8,9), Edge(9, 10), Edge(8, 10)]
// let ccg = Graph<UInt8>(fromEdgeList: edges + edges2)
//
// let cc = ccg.connectedComponents
// print(cc)
// print("connected? \(ccg.isConnected)")
//
start = DispatchTime.now()
let h = Graph<UInt32>(fromBinaryFile: "/Users/seth/dev/swift/SwiftGraphs/data/indptrvecs-4m-30m.0based.bin")

end = DispatchTime.now()
print("graph read took \(Double(end.uptimeNanoseconds - start.uptimeNanoseconds) / 1_000_000.0) ms")
////
print(h)
print("h.foo(5) = \(h.foo(5))")
// print("Degree histogram of h:")
// start = DispatchTime.now()
// print(h.degreeHistogram.sorted(by:<))
// end = DispatchTime.now()
// print("Histogram took \(Double(end.uptimeNanoseconds - start.uptimeNanoseconds) / 1_000_000.0) ms")
// print("Density = \(h.density)")
//
var dtimes = [Double]()
for i in 1 ... 10 {
    start = DispatchTime.now()
    // let ds = h.dijkstraShortestPaths(from: 1, withPaths: true, trackVertices: true)
    let ds = h.dijkstraShortestPaths(from: 1)
    end = DispatchTime.now()
    let timediff = Double(end.uptimeNanoseconds - start.uptimeNanoseconds) / ms
    dtimes.append(timediff)
    let timeAvg = dtimes.reduce(0, +) / Double(dtimes.count)
    let sumOfSquaredAvgDiff = dtimes.map { pow($0 - timeAvg, 2.0) }.reduce(0, +)
    let timeStd = sqrt(sumOfSquaredAvgDiff / Double(dtimes.count - 1))
    print("\(i): curr: \(timediff.truncate(places: 3)), min: \(dtimes.min()!.truncate(places: 3)), max: \(dtimes.max()!.truncate(places: 3)), avg: \(timeAvg.truncate(places: 3)), std: \(timeStd.truncate(places: 3))")
}

// print("ds.pathCounts[0..<10] = \(ds.pathCounts[0..<10])")
// print("pathCounts sum = \(ds.pathCounts.reduce(0, +))")

exit(0)

start = DispatchTime.now()
let hcc = h.isConnected
end = DispatchTime.now()
print("isConnected took \(Double(end.uptimeNanoseconds - start.uptimeNanoseconds) / 1_000_000.0) ms")
var times = [Double]()

for i in 1 ... 100_000 {
    start = DispatchTime.now()
    let bfs1 = h.BFS(from: 0)
    end = DispatchTime.now()
    let timediff = Double(end.uptimeNanoseconds - start.uptimeNanoseconds) / ms
    // let timeit = end2.uptimeNanoseconds - start2.uptimeNanoseconds
//    print("Run \(i): BFS from vertex 0 to \(timediff) ms; sum = \(bfs1.reduce(0, +))")
    times.append(timediff)
    let timeAvg = times.reduce(0, +) / Double(times.count)
    let sumOfSquaredAvgDiff = times.map { pow($0 - timeAvg, 2.0) }.reduce(0, +)
    let timeStd = sqrt(sumOfSquaredAvgDiff / Double(times.count - 1))
    print("\(i): curr: \(timediff.truncate(places: 3)), min: \(times.min()!.truncate(places: 3)), max: \(times.max()!.truncate(places: 3)), avg: \(timeAvg.truncate(places: 3)), std: \(timeStd.truncate(places: 3))")
}

print("FINAL")
let timeAvg = times.reduce(0, +) / Double(times.count)
let sumOfSquaredAvgDiff = times.map { pow($0 - timeAvg, 2.0) }.reduce(0, +)
let timeStd = sqrt(sumOfSquaredAvgDiff / Double(times.count - 1))
print("Times: min: \(times.min()!), max: \(times.max()!), avg: \(timeAvg), std: \(timeStd)")
