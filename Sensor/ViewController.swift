//
//  ViewController.swift
//  Sensor
//
//  Created by Damiaan Dufaux on 26/06/16.
//  Copyright © 2016 Damiaan Dufaux. All rights reserved.
//

import UIKit
import CoreMotion

class SensorViewController: UIViewController {
    @IBOutlet weak var roll: UIProgressView!
    @IBOutlet weak var pitch: UIProgressView!
    @IBOutlet weak var yaw: UIProgressView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillDisappear(animated)
        gyroManager.processors.append(self)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        if let index = gyroManager.processors.indexOf({$0.isEqual(self)}) {
            gyroManager.processors.removeAtIndex(index)
        }
    }
}

extension SensorViewController: GyroProcessor {
    func process(value: CMDeviceMotion) {
        roll.progress = Float(value.attitude.roll / M_PI + 0.5)
        pitch.progress = Float(value.attitude.pitch / M_PI + 0.5)
        yaw.progress = Float(value.attitude.yaw / M_PI + 0.5)
    }
}