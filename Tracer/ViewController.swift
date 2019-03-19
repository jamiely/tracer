//
//  ViewController.swift
//  Tracer
//
//  Created by Ly, Jamie on 3/13/19.
//  Copyright © 2019 Ly, Jamie. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    private var traceView: TraceView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        traceView = TraceView(frame: view.frame)
        traceView.expectedPaths = [
            Path(points: [
                CGPoint(x: 70, y: 245),
                CGPoint(x: 350, y: 245)]),
            Path(points: [
                CGPoint(x: 205, y: 245),
                CGPoint(x: 205, y: 650)])
        ]
        let background = UIImageView(image: UIImage(named: "T"))
        traceView.backgroundView = background
        traceView.keyPointImage = UIImage(named: "Star")
        view.addSubview(traceView)
    }
}

