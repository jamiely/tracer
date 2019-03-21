//
//  TracerTests.swift
//  TracerTests
//
//  Created by Ly, Jamie on 3/13/19.
//  Copyright © 2019 Ly, Jamie. All rights reserved.
//

import XCTest
import SwiftCheck
@testable import Tracer

struct LineAndDistance {
    let maxDistance: CGFloat
    let start: CGPoint
    let end: CGPoint
}

extension CGFloat: Arbitrary {
    public static var arbitrary : Gen<CGFloat> {
        return Double.arbitrary.map{CGFloat($0)}
    }
}

let positiveFloats = CGFloat.arbitrary.suchThat { $0 >= 0 }
let positivePoints = Gen<(CGFloat, CGFloat)>.zip(
    positiveFloats, positiveFloats).map(CGPoint.init)

extension LineAndDistance : Arbitrary {
    
    public static var arbitrary : Gen<LineAndDistance> {
        return Gen<(CGFloat, CGPoint, CGPoint)>.zip(
            // max distance should be greater than 1
            positiveFloats.suchThat{$0 >= 1},
            positivePoints,
            positivePoints).map(LineAndDistance.init)
    }
}

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
    
    func testWaypointDistanceProperty() {
        var counter = 0
        property("waypoints are created so that points are not more than max distance apart") <- forAll { (args: LineAndDistance) in
            
            let maxDistance = args.maxDistance
            let start = args.start
            let end = args.end
            
            let points =
                [ start ] +
                TraceView.calculateWaypoints(maxDistance: maxDistance, start: start, end: end) +
                [ end ]
            
            guard var last = points.first else { return false }
            let result = points[1..<points.count].allSatisfy {
                let distance = TraceView.getDistance(start: last, end: $0)
                // we add 1 for some floating point rounding error
                last = $0
                return distance <= maxDistance
            }
            
            counter = counter + 1
            
            print("Counter \(counter)")
            
            return result
        }
    }
}
