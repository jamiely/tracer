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
}
