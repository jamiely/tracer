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
        let background = UIImageView(image: UIImage(named: "T"))
        traceView.backgroundView = background
        traceView.keyPointImage = UIImage(named: "Star")
        view.addSubview(traceView)
    }
}

