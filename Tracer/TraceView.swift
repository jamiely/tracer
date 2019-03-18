//
//  TraceView.swift
//  Tracer
//
//  Created by Ly, Jamie on 3/13/19.
//  Copyright © 2019 Ly, Jamie. All rights reserved.
//

import UIKit

struct Line {
    let start: CGPoint
    let end: CGPoint
    let outOfBounds: Bool
}

class TraceView: UIView {
    private var lines: Array<Line>
    private var _expectedPath: Array<CGPoint>
    private var expectedPathView: UIImageView
    private var drawingView: UIImageView
    private var _backgroundView: UIImageView?
    private let maxDistance: CGFloat = 10
    private var pendingPoints: Array<CGPoint>
    private var isComplete: Bool { return pendingPoints.isEmpty }
    
    var expectedPath: Array<CGPoint> {
        get { return _expectedPath }
        set {
            _expectedPath = withAddedWayPoints(maxDistance: maxDistance, path: newValue)
            pendingPoints = Array<CGPoint>(_expectedPath)
            drawExpectedPath(points: newValue)
        }
    }
    
    private func withAddedWayPoints(maxDistance: CGFloat, path: Array<CGPoint>) -> Array<CGPoint> {
        
        guard var last = path.first else {
            return path
        }
        
        var newPath = Array<CGPoint>()
        newPath.append(last)
        
        path[1..<path.count].forEach { pt in
            let waypoints = calculateWaypoints(maxDistance: maxDistance, start: last, end: pt)
            newPath.append(contentsOf: waypoints)
            newPath.append(pt)
            last = pt
        }
        
        return newPath
    }
    
    /// Returns the waypoints that should be inserted
    /// between two points so that the resulting
    /// points are less than the given distance apart.
    private func calculateWaypoints(maxDistance: CGFloat, start: CGPoint, end: CGPoint) -> Array<CGPoint> {
        
        let distance = getDistance(start: start, end: end)
        
        if distance < maxDistance {
            return Array<CGPoint>()
        }
        
        // the points are too far apart, so we need to add
        // a waypoint
        let midpoint = getMidpoint(start: start, end: end)
        // then we want to check recursively get the waypoints
        // between the midpoint and the start and end
        
        return
            calculateWaypoints(maxDistance: maxDistance,
                         start: start, end: midpoint) +
            [midpoint] +
            calculateWaypoints(maxDistance: maxDistance,
                        start: midpoint, end: end)
    }
    
    private func getMidpoint(start: CGPoint, end: CGPoint) -> CGPoint {
        let x = (start.x + end.x) / 2.0
        let y = (start.y + end.y) / 2.0
        return CGPoint(x: x, y: y)
    }
    
    var backgroundView: UIImageView? {
        get { return _backgroundView }
        set {
            _backgroundView?.removeFromSuperview()
            _backgroundView = newValue
            guard let view = newValue else { return }
            view.contentMode = .scaleAspectFit
            view.frame = bounds
            addSubview(view)
            sendSubviewToBack(view)
        }
    }
    
    private func drawExpectedPath(points: Array<CGPoint>) {
        UIGraphicsBeginImageContext(expectedPathView.bounds.size)
        
        guard var last = points.first,
            let context = UIGraphicsGetCurrentContext() else {
            print("There should be at least one point")
            return
        }
        
        context.setFillColor(UIColor.white.cgColor)
        context.fill(expectedPathView.bounds)
        
        context.setStrokeColor(UIColor.blue.cgColor)
        points[1..<points.count].forEach { pt in
            context.move(to: last)
            context.addLine(to: pt)
            context.strokePath()
            last = pt
        }
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        expectedPathView.image = image
    }
    
    required init?(coder aDecoder: NSCoder) {
        lines = []
        _expectedPath = []
        expectedPathView = UIImageView(coder: aDecoder)!
        drawingView = UIImageView(coder: aDecoder)!
        pendingPoints = []
        
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override init(frame: CGRect) {
        lines = []
        _expectedPath = []
        expectedPathView = UIImageView(frame: frame)
        drawingView = UIImageView(frame: frame)
        pendingPoints = []
        
        super.init(frame: frame)
        commonInit()
    }
    
    private func commonInit() {
        addSubview(expectedPathView)
        expectedPath = [
            CGPoint(x: 83, y: 245),
            CGPoint(x: 350, y: 245),
            CGPoint(x: 205, y: 245),
            CGPoint(x: 205, y: 650)
        ]
        
        expectedPathView.alpha = 0.5
        
        addSubview(drawingView)
        bringSubviewToFront(drawingView)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        touches.forEach {
            let start = $0.previousLocation(in: self)
            let end = $0.location(in: self)
            let isOutOfBounds = ![start, end].allSatisfy(isPointWithinBounds)
            let line = Line(start: start, end: end, outOfBounds: isOutOfBounds)
            print("line: \(line)")
            self.lines.append(line)
            removeFromPending(pt: start)
            removeFromPending(pt: end)
        }
        setNeedsDisplay()
    }
    
    private func removeFromPending(pt: CGPoint) {
        var toRemove: Set<Int> = []
        pendingPoints.enumerated().forEach { entry in
            let (offset, element) = entry
            let distance = getDistance(start: element, end: pt)
            if distance > maxDistance { return }
            
            toRemove.insert(offset)
        }
        
        toRemove.forEach { pendingPoints.remove(at: $0) }
    }
    
    private func colorForPoints(_ pts: CGPoint...) -> CGColor {
        if pts.allSatisfy(isPointWithinBounds) {
            return UIColor.black.cgColor
        }
        
        return UIColor.red.cgColor
    }
    
    private func isPointWithinBounds(_ pt: CGPoint) -> Bool {
        return expectedPath.contains { ept in
            return getDistance(start: pt, end: ept) < maxDistance
        }
    }
    
    private func getDistance(start: CGPoint, end: CGPoint) -> CGFloat {
        let dx = start.x - end.x
        let dy = start.y - end.y
        let distance = sqrt(dx * dx + dy * dy)
        return distance
    }

    override func draw(_ rect: CGRect) {
        let overrideColor = isComplete ? UIColor.green.cgColor : nil
        UIGraphicsBeginImageContext(drawingView.bounds.size)
        guard let context = UIGraphicsGetCurrentContext() else {
            print("ERROR: no context available")
            return
        }
        
//        context.setFillColor(UIColor.white.cgColor)
//        context.fill(bounds)
        
        lines.forEach {
            drawLine(context: context, line: $0, overrideColor: overrideColor)
        }
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        drawingView.image = image
        UIGraphicsEndImageContext()
    }
    
    private func drawLine(context: CGContext, line: Line, overrideColor: CGColor?) {
        var color = UIColor.black.cgColor
        if line.outOfBounds { color = UIColor.red.cgColor }
        else if let overrideColor = overrideColor { color = overrideColor }
        
        context.move(to: line.start)
        context.addLine(to: line.end)
        context.setStrokeColor(color)
        context.strokePath()
    }
}
