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

class ViewController: UIViewController {
    
    @IBOutlet weak var InputField: UITextField!
    @IBOutlet weak var dataLabel: UILabel!
    
    var manager:BLEManager!
    var peripheral:CBPeripheral!
   
    
    //Firebase
    var ref: DatabaseReference!
    
    //Authentication, google
    let providers: [FUIAuthProvider] = [FUIGoogleAuth()]
    
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
        self.manager = BLEManager()
        
        //Firebase configuration
        self.ref = Database.database().reference()
        

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
   
}

