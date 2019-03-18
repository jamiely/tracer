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
        background.alpha = 0.5
        view.addSubview(traceView)
    }
}

