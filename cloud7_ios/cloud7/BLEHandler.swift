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
    
    //Audio handler delegate
    var audio_handler: AudioProcess
    
    //Peripherals that we've connected to
    var discoveredPeripherals = [String]()
    var connectedPeripherals = [CBPeripheral]()

    var audioData = [Data]()
    let DEVICE_UUID = CBUUID(string: "303CBFB6-C92A-30A3-5959-5F3845E09EE4")
    let DEVICE_NAME = "Cloud7"
    let SERVICE_UUID = CBUUID(string: "02366E80-CF3A-11E1-9AB4-0002A5D5C51B")
    let CHAR_UUID = CBUUID(string: "E23E78A0-CF4A-11E1-8FFC-0002A5D5C51B")
    
    var discovered = false;
    
    override init() {
        self.audio_handler = AudioProcess()
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch (central.state) {
        case .poweredOn:
            print("powered on")
            central.scanForPeripherals(withServices: [SERVICE_UUID], options: nil)
//            central.scanForPeripherals(withServices: nil, options: nil)
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
        let name = peripheral.name ??  "default";
        let id = peripheral.identifier.uuidString

        if (((advertisementData as NSDictionary).value(forKey: "kCBAdvDataLocalName")) != nil) {
            let peripheralLocalName_advertisement = ((advertisementData as NSDictionary).value(forKey: "kCBAdvDataLocalName")) as? String
            if(id == DEVICE_UUID.uuidString && peripheralLocalName_advertisement == "Cloud7!!"){
                print("Discovered the target device! Conecting...")
                print("\n\nNAME: \(name)\nDESC\(peripheral.debugDescription)\nADDATA:\(advertisementData.description)\nDEVUUID:\(peripheral.identifier.uuidString)\n");
                central.stopScan()
                central.connect(peripheral, options: nil)
                self.connectedPeripherals.append(peripheral)
            }else{
                if(!self.discoveredPeripherals.contains(name)){
                    print("Discovered Peripheral: " + name)
                    self.discoveredPeripherals.append(name)
                }
            }
            
        }
        
        
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
            peripheral.discoverCharacteristics(nil, for: s)
        }
    }
    
    //Notify when we have a new set of data coming in.
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        print("Discovering Characteristics")
        for char in service.characteristics! {
            let c = char as CBCharacteristic
            peripheral.setNotifyValue(true, for: c)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        //This gets called when we have new data coming into the system
        let array = characteristic.value?.withUnsafeBytes {
            [UInt32](UnsafeBufferPointer(start: $0, count: (characteristic.value?.count)!))
        }
        self.audio_handler.newAudioData(data: array!) //Send this data to our audio handler
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        central.scanForPeripherals(withServices: nil, options: nil)
    }

}

protocol BLEHandler_NewAudioDelegate {
    func newAudioData(data:[UInt32])
}

    
