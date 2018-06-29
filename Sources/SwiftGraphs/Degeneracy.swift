//
//  Degeneracy.swift
//  SwiftGraphs
//
//  Created by Seth Bromberger on 2018-06-17.
//  Copyright © 2018 Seth Bromberger. All rights reserved.
//

extension AbstractGraph {
    func coreNumber() -> [T] {
        guard !hasSelfLoops else {
            fatalError("Graph must not have self loops")
        }
        let degs = degrees
        var vs = degs.enumerated().sorted {$0.element < $1.element }.map {T($0.offset) }
        
        var binBounds = [0]
        var currDegree = T(0)
        for (i, v) in vs.enumerated() {
            let vInt = Int(v)
            if degs[vInt] > currDegree {
                let repmat = Array(repeating: i, count: Int((degs[vInt])) - Int(currDegree))
                binBounds.append(contentsOf:repmat)
                currDegree = degs[vInt]
            }
        }
        var vertexPos = vs.enumerated().sorted {$0.element < $1.element }.map{ $0.offset }
        var core = degrees
        var nbrs = Array<Set<T>>()
        nbrs.reserveCapacity(Int(nv))
        for v in vertices {
            nbrs.append(Set(neighbors(of: v)))
        }
        for v in vs {
            let vInt = Int(v)
            for u in nbrs[vInt] {
                let uInt = Int(u)
                if core[uInt] > core[vInt] {
                    nbrs[uInt].remove(v)
                    let pos = vertexPos[uInt]
                    let binStart = binBounds[Int(core[uInt])]
                    vertexPos[uInt] = binStart
                    vertexPos[Int(vs[binStart])] = pos
                    vs.swapAt(binStart, pos)
                    binBounds[Int(core[uInt])] += 1
                    core[uInt] -= 1
                }
            }
        }
        return core
    }
    
    func kCore(_ k:T?, corenum:[T]?) -> [T] {
        let useCoreNum = corenum ?? self.coreNumber()
        let useK = k ?? (useCoreNum.max() ?? T.max)
        return useCoreNum.filter { x in x >= useK }
    }
    
}
