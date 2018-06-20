import Cocoa

var str = "Hello, playground"

//func powInt(_ x:Int, _ y:Int) -> Int {
//    return (0..<y).reduce(
//    var acc = 1
//    var it = 0
//    while it < y {
//        acc *= x
//    }
//    return acc
//}

extension Set: CustomPlaygroundDisplayConvertible {
    public var playgroundDescription: Any {
        return "Set with \(count) elements"
    }
}


#if _runtime(_ObjC)
print(16)
#endif
print("done")
let arr = 0..<100_000_000
var s = Set<Int>()
s.reserveCapacity(100_000_000)
for p in (3...8) {
    let n = Int(pow(10.0, Double(p)))
//    print("n = \(n)")
    var s = Set(arr[0..<n])
    let x = n - 2
    let start = DispatchTime.now()
    s.remove(x)
    let end = DispatchTime.now()
    let diff = Double(end.uptimeNanoseconds - start.uptimeNanoseconds)
    print("n = \(n), time = \(diff / 1_000_000.0) ms, \(diff / Double(n)) ns per")
}


