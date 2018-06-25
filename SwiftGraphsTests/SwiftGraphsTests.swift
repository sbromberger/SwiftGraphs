//
//  SwiftGraphsTests.swift
//  SwiftGraphsTests
//
//  Created by Seth Bromberger on 2018-05-1.
//  Copyright © 2018 Seth Bromberger. All rights reserved.
//

import XCTest
import Foundation
@testable import SwiftGraphs

class SwiftGraphsTests: XCTestCase {
    var smallGraph: Graph<UInt8>!
    var smallDiGraph: DiGraph<UInt8>!
    var largeGraph: Graph<UInt32>!
    var coretest: Graph<UInt8>!

    override func setUp() {
        super.setUp()
        let edges :[Edge<UInt8>] = [Edge(0, 1), Edge(1, 2), Edge(2, 3), Edge(3, 4), Edge(1, 3), Edge(3, 1)]
        smallGraph = Graph<UInt8>(fromEdgeList: edges)
        smallDiGraph = DiGraph<UInt8>(fromEdgeList: edges)
        let largeGraphFn = FileManager.default.homeDirectoryForCurrentUser.path + "/dev/swift/SwiftGraphs/data/indptrvecs-4m-30m.0based.bin"

//        largeGraph = Graph<UInt32>(fromBinaryFile: largeGraphFn)
        
        let edgeList: [Edge<UInt8>] = [
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
        coretest = Graph<UInt8>(fromEdgeList: edgeList)

        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testDegrees() {
        XCTAssert(smallGraph.degrees == [1, 3, 2, 3, 1])
        print(smallDiGraph.degrees)
        print(smallDiGraph.edges)
        XCTAssert(smallDiGraph.degrees == [1, 4, 2, 4, 1])
        
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testComponents() {
        XCTAssert(coretest.coreNumber() == [3, 3, 2, 3, 3, 3])
    }
    
    func testNeighborhood() {
        let gEdges = (0..<10).map { v in Edge<UInt8>(v, v+1) }
        let g = Graph(fromEdgeList: gEdges)
        XCTAssert(g.neighborhood(from: 2, depth: 4) == [1, 2, 3, 4, 5, 6])

    }
    func testPerformanceExample() {
        // This is an example of a performance test case.

        self.measure {
            _ = coretest.coreNumber()
//            _ = largeGraph.BFS(from: 0)
            // Put the code you want to measure the time of here.
        }
    }
    
}
