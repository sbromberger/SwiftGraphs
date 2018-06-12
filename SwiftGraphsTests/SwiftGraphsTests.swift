//
//  SwiftGraphsTests.swift
//  SwiftGraphsTests
//
//  Created by Seth Bromberger on 2018-05-1.
//  Copyright © 2018 Seth Bromberger. All rights reserved.
//

import XCTest
@testable import SwiftGraphs

class SwiftGraphsTests: XCTestCase {
    var smallGraph: Graph<UInt8>!
    var smallDiGraph: DiGraph<UInt8>!
    override func setUp() {
        super.setUp()
        let edges :[Edge<UInt8>] = [Edge(0, 1), Edge(1, 2), Edge(2, 3), Edge(3, 4), Edge(1, 3), Edge(3, 1)]
        smallGraph = Graph<UInt8>(fromEdgeList: edges)
        smallDiGraph = DiGraph<UInt8>(fromEdgeList: edges)
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
    
    func testPerformanceExample() {
        // This is an example of a performance test case.

        self.measure {
            _ = smallGraph.BFS(from: 0)
            // Put the code you want to measure the time of here.
        }
    }
    
}
