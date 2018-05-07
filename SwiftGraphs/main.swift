import Dispatch
import QuartzCore

var start = DispatchTime.now()
let h = Graph<UInt32>(fromBinaryFile: "/Users/bromberger1/dev/swift/SwiftGraphs/data/indptrvecs-4m-30m.0based.bin")
var end = DispatchTime.now()
print("graph read took \(Double(end.uptimeNanoseconds - start.uptimeNanoseconds) / 1_000_000.0) ms")
//
print(h)
var times = [Double]()
var ms = 1_000_000.0
for i in 1 ... 40 {
    let start = CACurrentMediaTime()
    let bfs1 = h.BFS(from: 0)
    let end = CACurrentMediaTime()
    let timediff = (end - start) * 1000
    print("Run \(i): BFS from vertex 0 to \(timediff) ms; sum = \(bfs1.reduce(0, +))")
    times.append(timediff)
}

let timeAvg = times.reduce(0, +) / Double(times.count)
let sumOfSquaredAvgDiff = times.map { pow($0 - timeAvg, 2.0) }.reduce(0, +)
let timeStd = sqrt(sumOfSquaredAvgDiff / Double(times.count - 1))
print("Times: min: \(times.min()!), max: \(times.max()!), avg: \(timeAvg), std: \(timeStd)")
