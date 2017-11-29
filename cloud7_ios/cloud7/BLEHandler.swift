//
//  BLEHandler.swift
//  cloud7
//
//  Created by Evan Knox on 2017-11-28.
//  Copyright © 2017 Evan Knox. All rights reserved.
//

import UIKit
import CoreBluetooth

class BLEHandler: NSObject, CBCentralManagerDelegate{
    let DEVICE_UUID = CBUUID(string: "123A")
    let DEVICE_NAME = "Blank"
    //    let SERVICE_UUID = CBUUID(string: "A495FF21-C5B1-4B44-B512-137AfA2D74D1")
    let SERVICE_UUID = CBUUID(string: "2222")
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
            central.connect(peripheral, options: nil)
            peripheral.discoverServices(nil)
        }else{
            print("Discovered Peripheral: " + name + "\n")
        }
//        central.connect(self.connectedPeripheral, options: nil)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected...")
        peripheral.discoverServices(nil)
    }
    
    //Then discovery the characteristic of the service to get the actual data
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        for service in peripheral.services! {
            let s = service as CBService
            if s.uuid == SERVICE_UUID{
                peripheral.discoverCharacteristics(nil, for: s)
            }
        }
    }
    
    //Notify when we have a new set of data coming in.
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        for char in service.characteristics! {
            let c = char as CBCharacteristic
//            if c.uuid == CHAR_UUID{
//                print(c)
//            }
        }
    }
//
//    func peripheral (_peripheral: CBPeripheral,didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: Error?){
//
//        //        var bytes:UInt32 = 0;
//
////        if characteristic.uuid == CHAR_UUID{
////            print(characteristic.value?.debugDescription ?? "DEFAULT VAL")
////            print(characteristic.value!)
////        }
//
//        //Then upload the data to the database, and process cloud functions!
//    }
    
    
}
