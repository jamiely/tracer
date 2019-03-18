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
    let color: CGColor
}

class TraceView: UIView {
    private var lines: Array<Line>
    private var _expectedPath: Array<CGPoint>
    private var expectedPathView: UIImageView
    private var _backgroundView: UIImageView?
    
    var expectedPath: Array<CGPoint> {
        get { return _expectedPath }
        set {
            _expectedPath = newValue
            drawExpectedPath(points: newValue)
        }
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
        lines = Array<Line>()
        _expectedPath = Array<CGPoint>()
        expectedPathView = UIImageView(coder: aDecoder)!
        
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override init(frame: CGRect) {
        lines = Array<Line>()
        _expectedPath = Array<CGPoint>()
        expectedPathView = UIImageView(frame: frame)
        
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
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        touches.forEach {
            let start = $0.previousLocation(in: self)
            let end = $0.location(in: self)
            let color = colorForPoints(start, end)
            let line = Line(start: start, end: end, color: color)
            print("line: \(line)")
            self.lines.append(line)
        }
        setNeedsDisplay()
    }
    
    private func colorForPoints(_ pts: CGPoint...) -> CGColor {
        if pts.allSatisfy(isPointWithinBounds) {
            return UIColor.black.cgColor
        }
        
        return UIColor.red.cgColor
    }
    
    private func isPointWithinBounds(_ pt: CGPoint) -> Bool {
        let threshold: CGFloat = 75
        return expectedPath.contains { ept in
            let dx = pt.x - ept.x
            let dy = pt.y - ept.y
            let distance = sqrt(dx * dx + dy * dy)
            return distance < threshold
        }
    }

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else {
            print("ERROR: no context available")
            return
        }
        
        context.setFillColor(UIColor.white.cgColor)
        context.fill(bounds)
        
        lines.forEach {
            drawLine(context: context, line: $0)
        }
        
        UIGraphicsEndImageContext()
    }
    
    private func drawLine(context: CGContext, line: Line) {
        context.move(to: line.start)
        context.addLine(to: line.end)
        context.setStrokeColor(line.color)
        context.strokePath()
    }
}
