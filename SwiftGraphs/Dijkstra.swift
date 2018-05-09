//
//  Dijkstra.swift
//  SwiftGraphs
//
//  Created by Bromberger, Seth on 2018-05-08.
//  Copyright © 2018 Seth Bromberger. All rights reserved.
//

struct DijkstraState<T: FixedWidthInteger> {
    var parents: [T]
    var dists: [Double]
    var predecessors: [[T]]
    var pathCounts: [T]
    var closestVertices: [T]
}

struct DistVertex<T: FixedWidthInteger> {
    let distance: Double
    let vertex: T
}

extension DistVertex: Comparable {
    static func < (lhs: DistVertex<T>, rhs: DistVertex<T>) -> Bool {
        return lhs.distance < rhs.distance
    }
    
    static func ==(lhs: DistVertex<T>, rhs: DistVertex<T>) -> Bool {
        return lhs.distance == rhs.distance && lhs.vertex == rhs.vertex
    }
}

extension AbstractGraph {
    func dijkstraShortestPaths(from sourceVertex: T, distances: [[Double]]? = nil, withPaths: Bool = false, trackVertices: Bool = false) -> DijkstraState<T> {
        let numVertices = Int(nv)
        var dists = Array<Double>(repeating: Double.infinity, count: numVertices)
        var parents = Array<T>(repeating: 0, count: numVertices)
        var preds = [[T]]()
        preds.reserveCapacity(numVertices)
        var closestVertices = [T]()
        for _ in 0..<numVertices {
            let p = Array<T>()
            preds.append(p)
        }
        let visited = UnsafeBitArray<Int>(repeating: false, count: numVertices)
        var pathCounts = Array<T>(repeating: 0, count: numVertices)
        dists[Int(sourceVertex)] = 0
        var H = PriorityQueue<DistVertex<T>>(ascending: true)

        visited[Int(sourceVertex)] = true
        pathCounts[Int(sourceVertex)] = 1
        H.push(DistVertex(distance: 0, vertex: sourceVertex))
        dists.withUnsafeMutableBufferPointer { dists in
            while !H.isEmpty {
                let currentDistVertex = H.pop()!
                let vertex = currentDistVertex.vertex
                let intVertex = Int(vertex)
                if trackVertices {
                    closestVertices.append(vertex)
                }
                for neighbor in neighbors(of: vertex) {
                    let intNeighbor = Int(neighbor)
                    let distFromMatrix = distances?[intVertex][intNeighbor] ?? 1
                    let alt = (dists[intVertex] == Double.infinity) ? Double.infinity : dists[intVertex] + distFromMatrix
                    if !visited[intNeighbor] {
                        visited[intNeighbor] = true
                        
                        dists[intNeighbor] = alt
                        parents[intNeighbor] = vertex
                        pathCounts[intNeighbor] += pathCounts[intVertex]
                        
                        if withPaths {
                            preds[intNeighbor] = [vertex]
                        }
                        
                        H.push(DistVertex(distance: alt, vertex: neighbor))
                    } else {
                        if alt < dists[intNeighbor] {
                            dists[intNeighbor] = alt
                            parents[intNeighbor] = vertex
                            pathCounts[intNeighbor] = 0
                            preds[intNeighbor] = []
                            H.push(DistVertex(distance: alt, vertex: neighbor))
                        }
                        if alt == dists[intNeighbor] {
                            pathCounts[intNeighbor] += pathCounts[intVertex]
                            if withPaths {
                                preds[intNeighbor].append(vertex)
                            }
                        }
                    }
                }
            } // H.isEmpty
        }
        if trackVertices {
            for vertex in vertices {
                if !visited[Int(vertex)] {
                    closestVertices.append(vertex)
                }
            }
        }
        
        pathCounts[Int(sourceVertex)] = 1
        parents[Int(sourceVertex)] = 0
        preds[Int(sourceVertex)] = []
        
        return DijkstraState(parents: parents, dists: dists, predecessors: preds, pathCounts: pathCounts, closestVertices: closestVertices)
    }
}
