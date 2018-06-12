//
//  AbstractGraph.swift
//  SwiftGraphs
//
//  Created by Bromberger, Seth on 09-May-18.
//  Copyright © 2018 Seth Bromberger. All rights reserved.
//

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
}

extension AbstractGraph {
    public var degreeHistogram: [T: Int] {
        var degHist = [T: Int]()
        for d in degrees {
            degHist[d, default: 0] += 1
        }
        return degHist
    }

    public var isConnected: Bool {
        return ne + 1 >= nv && connectedComponents.count == 1
    }

    public var connectedComponents: [[T]] {
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
            let optIndex = componentDict[l]
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

    public func BFS(from sourceVertex: T) -> [T] {
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
