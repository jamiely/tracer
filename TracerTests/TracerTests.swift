//
//  TracerTests.swift
//  TracerTests
//
//  Created by Ly, Jamie on 3/13/19.
//  Copyright © 2019 Ly, Jamie. All rights reserved.
//

import XCTest
@testable import Tracer

class TracerTests: XCTestCase {
    func testGetFrame() {
        let rect = TraceView.getFrameFrom(maxDistance: 10, andPt: CGPoint(x: 100, y: 300))
        XCTAssertEqual(rect, CGRect(x: 95, y: 295, width: 10, height: 10), "The rects should be equal")
    }
    
    func testCalculateWaypoints() {
        let points = TraceView.calculateWaypoints(maxDistance: 10, start: CGPoint(x: 0, y: 0), end: CGPoint(x: 20, y: 20))
        XCTAssertEqual(points, [
            CGPoint(x: 5, y: 5),
            CGPoint(x: 10, y: 10),
            CGPoint(x: 15, y: 15)
            ], "waypoints should be the same")
    }
}
