//
//  BluetoothManager.swift
//  Sensor
//
//  Created by Damiaan Dufaux on 26/06/16.
//  Copyright © 2016 Damiaan Dufaux. All rights reserved.
//

import Foundation
import CoreBluetooth
import CoreMotion

var sensorServiceIsAdded = false

let bluetoothSesnorService = BluetoothSensorService()

class BluetoothSensorService: NSObject, CBPeripheralManagerDelegate {
    
    let peripheralManager = CBPeripheralManager(delegate: nil, queue: nil)
    let service = CBMutableService(
        type: CBUUID(data: NSData(bytes: [0xcd, 0xd4, 0x9c, 0xb8, 0x3d, 0x1a, 0x11, 0xe6, 0xac, 0x61, 0x9e, 0x71, 0x12, 0x8c, 0xae, 0x77] as Array<UInt8>, length: 16)),
        primary: true
    )
    let gyroCharacteristic = CBMutableCharacteristic(
        type: CBUUID(data: NSData(bytes: [0xb8, 0xd2, 0xaa, 0x98, 0x3d, 0x1b, 0x11, 0xe6, 0xac, 0x61, 0x9e, 0x71, 0x12, 0x8c, 0xae, 0x77] as Array<UInt8>, length: 16)),
        properties: .Notify,
        value: nil,
        permissions: .Readable
    )
    
    var centrals = Set<CBCentral>()
    
    override init() {
        super.init()
        service.characteristics = [gyroCharacteristic]
        peripheralManager.delegate = self
    }
    
    func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager) {
        switch peripheral.state {
        case .PoweredOn:
            print("Bluetooth is currently powered on.")

            if !sensorServiceIsAdded {
                peripheralManager.addService(service)
                sensorServiceIsAdded = true
            }
            start()
        case .PoweredOff:
            print("Bluetooth is currently powered off.")
            //TODO
        case .Resetting:
            print("The connection with the bluetooth system service was momentarily lost; an update is imminent.")
            //TODO
        case .Unauthorized:
            print("The app is not authorised to use Bluetooth LE.")
            //TODO
        case .Unknown:
            print("The current state of the bluetooth peripheral manager is unknown; an update is imminent.")
            //TODO
        case .Unsupported:
            print("The platform doesn't support the Bluetooth low energy peripheral/server role.")
            //TODO
        }
    }
    
    func peripheralManager(peripheral: CBPeripheralManager, central: CBCentral, didSubscribeToCharacteristic characteristic: CBCharacteristic) {
        if characteristic.UUID == gyroCharacteristic.UUID {
            if !gyroManager.processors.contains({$0.isEqual(self)}) {
                gyroManager.processors.append(self)
            }
            centrals.insert(central)
        }
    }
    
    func start() {
        peripheralManager.startAdvertising([
            CBAdvertisementDataServiceUUIDsKey: [service.UUID],
            CBAdvertisementDataLocalNameKey: "iPhone Sensors"
        ])
    }
    
    func stop() {
        peripheralManager.stopAdvertising()
    }
}

extension BluetoothSensorService: GyroProcessor {
    func round(value: Double) -> Int32 {
        return Int32(100000000 * value)
    }
    
    func process(value: CMDeviceMotion) {
        let r = value.attitude.rotationMatrix
        let gyroData = NSData(
            bytes: [
                round(atan2(r.m32, r.m33)+M_PI_2),
                round(-atan2(-r.m31, sqrt(pow(r.m32, 2)+pow(r.m33, 2)))),
                round(atan2(r.m21, r.m11))
            ],
            length: 12
        )
        peripheralManager.updateValue(gyroData, forCharacteristic: gyroCharacteristic, onSubscribedCentrals: Array(centrals))
    }
}