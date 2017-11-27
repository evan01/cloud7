//
//  ViewController.swift
//  cloud7
//
//  Created by Evan Knox on 2017-11-22.
//  Copyright © 2017 Evan Knox. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {
    var manager:CBCentralManager!
    var peripheral:CBPeripheral!
    let DEVICE_UUID = CBUUID(string: "123A")
    let SERVICE_UUID = CBUUID(string: "a495ff21-c5b1-4b44-b512-1370f02d74de")
    let CHAR_UUID = CBUUID(string: "a495ff21-c5b1-4b44-b512-1370f02d74d1")
    
    //The following functions happen in a sequence... if everything works.
    
    //First make sure that the bluetooth is on, then scan
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == CBManagerState.poweredOn {
            central.scanForPeripherals(withServices: nil, options: nil)
        }else{
            print("Bluetooth not working...")
        }
    }
    
    //Then look for a peripheral with the UUID we setup
    func centralManager(_ central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, error: Error?) {
        if DEVICE_UUID.uuidString == peripheral.name {
            //Then we have a lock!!
            self.manager.stopScan()
            self.peripheral = peripheral
            self.peripheral.delegate = self
            manager.connect(peripheral, options: nil)
        }
    }
    
    //Then discover the services offered by this peripheral
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
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
            if c.uuid == CHAR_UUID{
                self.peripheral.setNotifyValue(true, for: c)
            }
        }
    }
    
    func peripheral (_peripheral: CBPeripheral,didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: Error?){
        
//        var bytes:UInt32 = 0;
        
        if characteristic.uuid == CHAR_UUID{
            print(characteristic.value?.debugDescription ?? "DEFAULT VAL")
            print(characteristic.value!)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        central.scanForPeripherals(withServices: nil, options: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.manager = CBCentralManager(delegate: self, queue: nil)
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
   
}

