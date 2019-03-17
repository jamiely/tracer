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
}

class TraceView: UIView {
    private var lines: Array<Line>
    private var _expectedPath: Array<CGPoint>
    private var expectedPathView: UIImageView
    
    var expectedPath: Array<CGPoint> {
        get { return _expectedPath }
        set {
            _expectedPath = newValue
            drawExpectedPath(points: newValue)
        }
    }
    
    private func drawExpectedPath(points: Array<CGPoint>) {
        UIGraphicsBeginImageContext(expectedPathView.bounds.size)
        
        guard var last = points.first,
            let context = UIGraphicsGetCurrentContext() else {
            print("There should be at least one point")
            return
        }
        
        context.setFillColor(UIColor.red.cgColor)
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
            CGPoint(x: 1, y: 1),
            CGPoint(x: 100, y: 100),
            CGPoint(x: 1, y: 200),
            CGPoint(x: 100, y: 300)
        ]
        expectedPathView.alpha = 0.5
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        touches.forEach {
            let start = $0.previousLocation(in: self)
            let end = $0.location(in: self)
            self.lines.append(Line(start: start, end: end))
        }
        setNeedsDisplay()
    }

    override func draw(_ rect: CGRect) {
        lines.forEach(drawLine)
    }
    
    private func drawLine(line: Line) {
        guard let context = UIGraphicsGetCurrentContext() else {
            print("ERROR: no context available")
            return
        }
        context.move(to: line.start)
        context.addLine(to: line.end)
        context.setStrokeColor(UIColor.black.cgColor)
        context.strokePath()
        UIGraphicsEndImageContext()
    }
}
