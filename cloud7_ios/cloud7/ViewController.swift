//
//  ViewController.swift
//  cloud7
//
//  Created by Evan Knox on 2017-11-22.
//  Copyright © 2017 Evan Knox. All rights reserved.
//

import UIKit
import CoreBluetooth

import AVFoundation

class ViewController: UIViewController {
    
    @IBOutlet weak var InputField: UITextField!
    @IBOutlet weak var dataLabel: UILabel!
    let AUDIO_DONE_NOTIFICATION_KEY = "AUDIO_COMPLETE"
    
    //Delegates?
    var firebaseDelegate: Firebase_Delegate?
    
    var manager:BLEManager!
    var peripheral:CBPeripheral!
   
    //When you click the upload button... 
    @IBAction func upload(_ sender: Any) {
//        self.firebaseDelegate?.uploadToFirebase(data: "Evans default string")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Firebase configuration
        self.firebaseDelegate = FirebaseUploader()
        
        //Bluetooth configuration, this starts the bluetooth service...
        self.manager = BLEManager()
        
        //Wait for a completed audio notification
        NotificationCenter.default.addObserver(self, selector: #selector(self.receiveProcessedAudioData(_:)), name: NSNotification.Name(rawValue: AUDIO_DONE_NOTIFICATION_KEY), object: nil)

    }
    
    //This function gets called when we finally have all the data we want.
    @objc func receiveProcessedAudioData(_ notification:NSNotification){
        print("Notified")
//        print(notification.userInfo!["data"])
        let data = notification.userInfo!["data"]
        self.manager.manager.stopScan()
        self.firebaseDelegate?.upload(data: data as! Data)
    }

    //If we need to manually relaunch bluetooth
    @IBAction func relaunchBluetooth(_ sender: Any) {
        print("Relaunching bluetooth")
        if(!self.manager.manager.isScanning){
            print("Scanning for new peripherals")
            self.manager.handler.discoveredPeripherals = [String]()
            self.manager.manager.scanForPeripherals(withServices: nil, options: nil)
            self.manager.handler.audio_handler.resetAudio()
        }else{
            self.manager.restartBluetooth()
        }
    }
    
    //To play our raw audio
    @IBAction func playAudio(_ sender: Any) {
        print("Playing audio!!")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func uploadTestAudio(_ sender: Any) {
        self.firebaseDelegate?.uploadTestToFirebase()
    }
    
}

protocol Firebase_Delegate{
//    func uploadToFirebase(data: Data)
    func uploadToFirebase(data: String)
    
    func uploadTestToFirebase()
    
    func upload(data: Data)
}

