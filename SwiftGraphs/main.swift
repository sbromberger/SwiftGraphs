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

extension Double
{
    func truncate(places : Int)-> Double
    {
        return Double(floor(pow(10.0, Double(places)) * self)/pow(10.0, Double(places)))
    }
}

let edges: [Edge<UInt8>] = [Edge(0, 1), Edge(1, 2), Edge(2, 3), Edge(3, 4), Edge(1, 3)]
let g = Graph<UInt8>(fromEdgeList: edges)
print(g.degrees)
for i in 0 ..< g.nv {
    print("degree of \(i) = \(g.degree(of: i))")
}



let edges2 :[Edge<UInt8>] = [Edge(8,9), Edge(9, 10), Edge(8, 10)]
let ccg = Graph<UInt8>(fromEdgeList: edges + edges2)

let cc = ccg.connectedComponents
print(cc)
print("connected? \(ccg.isConnected)")

var start = DispatchTime.now()
let h = Graph<UInt32>(fromBinaryFile: "/Users/seth/dev/swift/SwiftGraphs/data/indptrvecs-4m-30m.0based.bin")

var end = DispatchTime.now()
print("graph read took \(Double(end.uptimeNanoseconds - start.uptimeNanoseconds) / 1_000_000.0) ms")
////
print(h)
print("Degree histogram of h:")
print(h.degreeHistogram.sorted(by:<))
exit(0)

start = DispatchTime.now()
let hcc = h.isConnected
end = DispatchTime.now()
print("isConnected took \(Double(end.uptimeNanoseconds - start.uptimeNanoseconds) / 1_000_000.0) ms")
var times = [Double]()
var ms = 1_000_000.0
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

