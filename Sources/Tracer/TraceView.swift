import UIKit

struct Line {
    let start: CGPoint
    let end: CGPoint
    let outOfBounds: Bool
}

public struct Path {
    let points: [CGPoint]
    
    public init(points: [CGPoint]) {
        self.points = points
    }
}

public class TraceView: UIView {
    private var lines: [Line] = []
    private var expectedPathView: UIImageView
    private var expectedPathsWithWaypoints: [Path]
    private var drawingView: UIImageView
    private var _backgroundView: UIImageView?
    private let maxDistance: CGFloat = 20
    private var pendingPoints: [CGPoint] = []
    private var isComplete: Bool { return pendingPoints.isEmpty }
    private var imageViews: [UIImageView] = []
    
    public var expectedPaths: [Path] {
        didSet {
            expectedPathsWithWaypoints = expectedPaths.map {
                let points = withAddedWayPoints(maxDistance: maxDistance, path: $0.points)
                return Path(points: points)
            }
            pendingPoints = Array(expectedPathsWithWaypoints.compactMap{$0.points}.joined())
            drawExpectedPaths(paths: expectedPaths)
        }
    }
    
    public var keyPointImage: UIImage? {
        didSet {
            guard let image = keyPointImage else {
                imageViews.forEach{$0.removeFromSuperview()}
                imageViews = []
                return
            }
            
            let frames = expectedPaths.compactMap{$0.points}.joined().map {
                TraceView.getFrameFrom(maxDistance: maxDistance, andPt: $0)
            }
            
            frames.forEach {
                let imageView = UIImageView(image: image)
                imageView.frame = $0
                addSubview(imageView)
            }
        }
    }
    
    public static func getFrameFrom(maxDistance: CGFloat, andPt pt: CGPoint) -> CGRect {
        let imageSize = CGSize(width: maxDistance, height: maxDistance)
        let offset = maxDistance / 2.0
        let offsetPt = CGPoint(x: pt.x - offset, y: pt.y - offset)
        return CGRect(origin: offsetPt, size: imageSize)
    }
    
    private func withAddedWayPoints(maxDistance: CGFloat, path: [CGPoint]) -> [CGPoint] {
        
        guard var last = path.first else {
            return path
        }
        
        var newPath = [CGPoint]()
        newPath.append(last)
        
        path[1..<path.count].forEach { pt in
            let waypoints = TraceView.calculateWaypoints(maxDistance: maxDistance, start: last, end: pt)
            newPath.append(contentsOf: waypoints)
            newPath.append(pt)
            last = pt
        }
        
        return newPath
    }
    
    /// Returns the waypoints that should be inserted
    /// between two points so that the resulting
    /// points are less than the given distance apart.
    public static func calculateWaypoints(maxDistance: CGFloat, start: CGPoint, end: CGPoint) -> [CGPoint] {
        
        let distance = TraceView.getDistance(start: start, end: end)
        
        if distance < maxDistance {
            return [CGPoint]()
        }
        
        // the points are too far apart, so we need to add
        // a waypoint
        let midpoint = TraceView.getMidpoint(start: start, end: end)
        // then we want to check recursively get the waypoints
        // between the midpoint and the start and end
        
        return
            TraceView.calculateWaypoints(maxDistance: maxDistance,
                         start: start, end: midpoint) +
            [midpoint] +
            TraceView.calculateWaypoints(maxDistance: maxDistance,
                        start: midpoint, end: end)
    }
    
    private static func getMidpoint(start: CGPoint, end: CGPoint) -> CGPoint {
        let x = (start.x + end.x) / 2.0
        let y = (start.y + end.y) / 2.0
        return CGPoint(x: x, y: y)
    }
    
    public var backgroundView: UIImageView? {
        didSet {
            oldValue?.removeFromSuperview()
            guard let view = backgroundView else { return }
            view.contentMode = .scaleAspectFit
            // we hard-code this for now so it looks the same on phones
            // other than the iPhone XR
            view.frame = CGRect(x: 0, y: 0, width: 414, height: 896)
            addSubview(view)
            sendSubviewToBack(view)
        }
    }
    
    private func drawExpectedPaths(paths: [Path]) {
        UIGraphicsBeginImageContext(expectedPathView.bounds.size)
        guard let context = UIGraphicsGetCurrentContext() else {
                print("Could not retrieve context")
                return
        }
        
        paths.forEach {
            drawExpectedPath(context: context, path: $0)
        }
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        expectedPathView.image = image
    }
    
    private func drawExpectedPath(context: CGContext, path: Path) {
        let points = path.points
        
        guard var last = points.first else {
            print("There should be at least one point")
            return
        }
        
        context.setLineWidth(maxDistance * 2)
        context.setLineCap(.round)
        context.setStrokeColor(UIColor.gray.cgColor)
        points[1..<points.count].forEach { pt in
            context.move(to: last)
            context.addLine(to: pt)
            context.strokePath()
            last = pt
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        expectedPathView = UIImageView(coder: aDecoder)!
        drawingView = UIImageView(coder: aDecoder)!
        
        super.init(coder: aDecoder)
        commonInit()
    }
    
    public override init(frame: CGRect) {
        expectedPathView = UIImageView(frame: frame)
        drawingView = UIImageView(frame: frame)
        
        super.init(frame: frame)
        commonInit()
    }
    
    private func commonInit() {
        addSubview(expectedPathView)
        
        expectedPathView.alpha = 0.5
        
        addSubview(drawingView)
        bringSubviewToFront(drawingView)
    }
    
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
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
            let distance = TraceView.getDistance(start: element, end: pt)
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
        return expectedPaths.contains { path in
            return path.points.contains { ept in
                return TraceView.getDistance(start: pt, end: ept) < maxDistance
            }
        }
    }
    
    public static func getDistance(start: CGPoint, end: CGPoint) -> CGFloat {
        let dx = start.x - end.x
        let dy = start.y - end.y
        let distance = sqrt(dx * dx + dy * dy)
        return distance
    }

    public override func draw(_ rect: CGRect) {
        let overrideColor = isComplete ? UIColor.green.cgColor : nil
        UIGraphicsBeginImageContext(drawingView.bounds.size)
        guard let context = UIGraphicsGetCurrentContext() else {
            print("ERROR: no context available")
            return
        }
        
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
