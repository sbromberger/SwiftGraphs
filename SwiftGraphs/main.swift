

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
let bfs1 = g.BFS(from: 0)
print("bfs from 0 = \(bfs1)")

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
