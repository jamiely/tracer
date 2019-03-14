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
    
    required init?(coder aDecoder: NSCoder) {
        lines = Array<Line>()
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        lines = Array<Line>()
        super.init(frame: frame)
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
