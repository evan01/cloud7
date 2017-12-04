//
//  BLEHandler.swift
//  cloud7
//
//  Created by Evan Knox on 2017-11-28.
//  Copyright © 2017 Evan Knox. All rights reserved.
//

import UIKit
import CoreBluetooth

class BLEHandler: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate{
    var discoveredPeripherals = [String]()
    var connectedPeripherals = [CBPeripheral]()

    
    let DEVICE_UUID = CBUUID(string: "123A")
    let DEVICE_NAME = "Cloud7"
    let SERVICE_UUID = CBUUID(string: "02366E80-CF3A-11E1-9AB4-0002A5D5C51B")
    let CHAR_UUID = CBUUID(string: "E23E78A0-CF4A-11E1-8FFC-0002A5D5C51B")
    
    var discovered = false;
    
    override init() {
        super.init()
    }
    
    //The following functions happen in a sequence... if everything works.
    //First make sure that the bluetooth is on, then scan
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch (central.state) {
        case .poweredOn:
            print("powered on")
//            central.scanForPeripherals(withServices: [SERVICE_UUID], options: nil)
            central.scanForPeripherals(withServices: nil, options: nil)
        case .unsupported:
            print("unsupported")
        case .unauthorized:
            print("unauthorized")
        case .unknown:
            print("unknown")
        case .resetting:
            print("resetting")
        case .poweredOff:
            print("powered off")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi: NSNumber) {
        
        let name = peripheral.name ??  "default"
        
        if(name == DEVICE_NAME){
            print("\n\n\nDISCOVERED THE BLUETOOTH DEVICE WE WANTED\n")
            print(rssi)
            print(advertisementData)
            print(peripheral.name!)
            //Then lets connect to it
            print("Discovered the target device! Conecting...")
            for i in advertisementData{
                print(i)
            }
            print(advertisementData.debugDescription);
            central.stopScan()
            central.connect(peripheral, options: nil)
            
            self.connectedPeripherals.append(peripheral)
            peripheral.discoverServices(nil)
        }else{
//            self.discovered
            if(!self.discoveredPeripherals.contains(name)){
                print("Discovered Peripheral: " + name + "\n")
                self.discoveredPeripherals.append(name)
            }
        }
//        central.connect(self.connectedPeripheral, options: nil)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected...")
        peripheral.delegate = self
        peripheral.discoverServices(nil)
    }
    
    //Then discovery the characteristic of the service to get the actual data
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        print("Discovering Services")
        for service in peripheral.services! {
            let s = service as CBService
            print(s.uuid.uuidString)
            if s.uuid == SERVICE_UUID{
                peripheral.discoverCharacteristics(nil, for: s)
            }
        }
    }
    
    //Notify when we have a new set of data coming in.
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        print("Discovering Characteristics")

        for char in service.characteristics! {
            let c = char as CBCharacteristic
            if c.uuid == CHAR_UUID {
                peripheral.setNotifyValue(true, for: c)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        print("Raw Value: \(characteristic.properties.rawValue)")
        
    }
    
    
}
