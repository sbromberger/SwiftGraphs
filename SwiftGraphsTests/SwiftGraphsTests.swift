//
//  SwiftGraphsTests.swift
//  SwiftGraphsTests
//
//  Created by Seth Bromberger on 2018-05-1.
//  Copyright © 2018 Seth Bromberger. All rights reserved.
//

import XCTest
import SwiftGraphs

class SwiftGraphsTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        let edges = [Edge(0, 1), Edge(1, 2), Edge(2, 3), Edge(3, 4), Edge(1, 3)]
        let g = Graph(fromEdgeList: edges)

        self.measure {
            _ = g.BFS(from: 0)
            // Put the code you want to measure the time of here.
        }
    }
    
}
