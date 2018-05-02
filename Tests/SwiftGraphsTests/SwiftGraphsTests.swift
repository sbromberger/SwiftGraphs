import XCTest
@testable import SwiftGraphs

final class SwiftGraphsTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(SwiftGraphs().text, "Hello, World!")
    }


    static var allTests = [
        ("testExample", testExample),
    ]
}
