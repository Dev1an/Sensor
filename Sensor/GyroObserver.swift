//
//  GyroObserver.swift
//  Sensor
//
//  Created by Damiaan Dufaux on 26/06/16.
//  Copyright © 2016 Damiaan Dufaux. All rights reserved.
//

import Foundation
import CoreMotion

let gyroManager = GyroManager()

class GyroManager {
    var manager = CMMotionManager()
    var processors = Array<GyroProcessor>()

    init() {
        manager.deviceMotionUpdateInterval = 0.1
    }
    
    func process(value: CMDeviceMotion) {
        for processor in processors {
            processor.process(value)
        }
    }
    
    func start() {
        if (manager.deviceMotionAvailable) {
            manager.startDeviceMotionUpdatesToQueue(NSOperationQueue.mainQueue(), withHandler: update)
        }
    }
    
    func stop() {
        manager.stopDeviceMotionUpdates()
    }
    
    func update(motion: CMDeviceMotion?, error: NSError?) {
        if let motion = motion {
            process(motion)
        }
    }
}

protocol GyroProcessor: NSObjectProtocol {
    func process(value: CMDeviceMotion)
}
