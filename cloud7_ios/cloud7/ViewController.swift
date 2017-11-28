//
//  ViewController.swift
//  cloud7
//
//  Created by Evan Knox on 2017-11-22.
//  Copyright © 2017 Evan Knox. All rights reserved.
//

import UIKit
import CoreBluetooth
import Firebase
import FirebaseAuthUI
import FirebaseGoogleAuthUI

class ViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    @IBOutlet weak var InputField: UITextField!
    @IBOutlet weak var dataLabel: UILabel!
    
    var manager:CBCentralManager!
    var peripheral:CBPeripheral!
    let USERNAME = "USER123"
    let DEVICE_UUID = CBUUID(string: "123A")
    let SERVICE_UUID = CBUUID(string: "a495ff21-c5b1-4b44-b512-1370f02d74de")
    let CHAR_UUID = CBUUID(string: "a495ff21-c5b1-4b44-b512-1370f02d74d1")
    
    //Firebase
    var ref: DatabaseReference!
    
    //Authentication, google
    let providers: [FUIAuthProvider] = [FUIGoogleAuth()]
    
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
        
        //Then upload the data to the database, and process cloud functions!
    }
    
    @IBAction func upload(_ sender: Any) {
        uploadToFirebase()
    }
    
    
    func uploadToFirebase(){
        let d = InputField.text;
        let email = "eknoxmobile@gmail.com"
        let password = "cloud7"
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            self.ref.child("audio").child("USER123").updateChildValues(["data2": d ?? ""]);
            print("Uploaded data to database")
            do {
                //Then read the return value...
                sleep(3)
                self.ref.child("audio").child("USER123").observeSingleEvent(of: .value, with: { (snapshot) in
                    // Get user value
                    let value = snapshot.value as? NSDictionary
                    let procVal = value?["return_value"] as? String ?? ""
                    self.dataLabel.text = procVal
                }) { (error) in
                    print(error.localizedDescription)
                }
                try Auth.auth().signOut()
            } catch let signOutError as NSError {
                print("Error signing out")
                print(signOutError)
            }
        }
        
    }
    
    func retrieveDataFromFirebase() -> Bool {
        return true;
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        central.scanForPeripherals(withServices: nil, options: nil)
    }
    
    //This will handle the google sign in
    func application(_ app: UIApplication, open url: URL,
                     options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
        let sourceApplication = options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String?
        if FUIAuth.defaultAuthUI()?.handleOpen(url, sourceApplication: sourceApplication) ?? false {
            return true
        }
        return false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Bluetooth configuration
//        self.manager = CBCentralManager(delegate: self, queue: nil)
        
        //Firebase configuration
        self.ref = Database.database().reference()
        
        //Upload user data to firebase
        uploadToFirebase()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
   
}

