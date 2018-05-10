//
//  SimpleGraph.swift
//  SwiftGraphs
//
//  Created by Bromberger, Seth on 09-May-18.
//  Copyright © 2018 Seth Bromberger. All rights reserved.
//

protocol SimpleGraph: AbstractGraph {
    associatedtype T
    var rowidx: Array<T> { get }
    var colptr: Array<Array<T>.Index> { get }
    func inDegree(of vertex: T) -> Int
    func outDegree(of vertex: T) -> Int
    func inNeighbors(of vertex: T) -> ArraySlice<T>
    func outNeighbors(of vertex: T) -> ArraySlice<T>
}

extension SimpleGraph {
    public var nv: T { return T((colptr.count - 1)) }

    public var vertices: CountableRange<T> {
        return (0 as T) ..< nv
    }

    func foo(_ foo: Int) -> Int { return foo * 2 }

    private func vecRange(_ s: Array<T>.Index) -> CountableRange<Array<T>.Index> {
        let rStart = colptr[s]
        let rEnd = colptr[s + 1]
        return rStart ..< rEnd
    }

    public func outNeighbors(of vertex: T) -> ArraySlice<T> {
        let range = vecRange(Array<T>.Index(vertex))
        return rowidx[range]
    }

    public var edges: [Edge<T>] {
        var edgeList = [Edge<T>]()
        edgeList.reserveCapacity(ne)
        for src in vertices {
            for dst in neighbors(of: src) {
                edgeList.append(Edge<T>(src, dst))
            }
        }
        return edgeList
    }

    public func hasEdge(_ src: T, _ dst: T) -> Bool {
        return neighbors(of: src).searchSortedIndex(val: dst).1
    }

    public func hasEdge(_ edge: Edge<T>) -> Bool {
        return hasEdge(edge.src, edge.dst)
    }

    public var degrees: [T] {
        return (1 ..< colptr.count).map { T(colptr[$0] - colptr[$0 - 1]) }
    }

    public func outDegree(of vertex: T) -> Int {
        return colptr[Int(vertex) + 1] - colptr[Int(vertex)]
    }
}
