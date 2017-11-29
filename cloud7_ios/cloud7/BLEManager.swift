//
//  BLEManager.swift
//  cloud7
//
//  Created by Evan Knox on 2017-11-28.
//  Copyright © 2017 Evan Knox. All rights reserved.
//

import UIKit
import CoreBluetooth

class BLEManager {
    
    var manager: CBCentralManager!
    var handler: BLEHandler //This will be a delegate!
    
    init(){
        self.handler = BLEHandler()
        self.manager = CBCentralManager(delegate: self.handler, queue: DispatchQueue.main)
    }
}
