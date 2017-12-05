//
//  Firebase.swift
//  cloud7
//
//  Created by Evan Knox on 2017-12-04.
//  Copyright © 2017 Evan Knox. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuthUI
import FirebaseGoogleAuthUI

class Firebase: Firebase_Delegate {
    
    //Firebase
    var ref: DatabaseReference!
    //Authentication, google
    let providers: [FUIAuthProvider] = [FUIGoogleAuth()]
    
    init() {
        //Firebase configuration
        self.ref = Database.database().reference()
    }
    
    func uploadToFirebase(data:String){
        let email = "eknoxmobile@gmail.com"
        let password = "cloud7"
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            self.ref.child("audio").child("USER123").updateChildValues(["data2": data ]);
            print("Uploaded data to database")
            do {
                //Then read the return value...
                sleep(8)
                self.ref.child("audio").child("USER123").observeSingleEvent(of: .value, with: { (snapshot) in
                    // Get user value
                    let value = snapshot.value as? NSDictionary
                    let procVal = value?["return_value"] as? String ?? ""
                    print("The return value was \(procVal)")
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
}
