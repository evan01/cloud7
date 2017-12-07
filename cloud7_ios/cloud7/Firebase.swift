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
import AVKit

class FirebaseUploader: Firebase_Delegate {
    
    //Firebase
    var ref: DatabaseReference!
    var dataRef: Storage!
    
    //Authentication, google
    let providers: [FUIAuthProvider] = [FUIGoogleAuth()]
    
    init() {
        //Firebase configuration
        self.ref = Database.database().reference()
        self.dataRef = Storage.storage()
    }
    
    func upload(data: Data) {
        self.uploadFileToFirebase(data: data)
        self.uploadToFirebase(data: data.base64EncodedString())
    }
    
    //This uploads the files data only to firebase
    func uploadToFirebase(data: String){
        let email = "eknoxmobile@gmail.com"
        let password = "cloud7"
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            self.ref.child("audio").child("USER123").updateChildValues(["data2": data ]);
            print("Uploaded raw data to cloud functions")
            do {
                sleep(8)
                self.ref.child("audio").child("USER123").observeSingleEvent(of: .value, with: { (snapshot) in
                    // Get user value
//                    let value = snapshot.value as? NSDictionary
                }) { (error) in
                    print(error.localizedDescription)
                    print("Cloud function upload ERROR")
                }
            }
        }
    }
    
    //This uploads the file to persistent storage in firebase
    func uploadFileToFirebase(data: Data){
        
        let storageRef = self.dataRef.reference()
        let email = "eknoxmobile@gmail.com"
        let password = "cloud7"
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            let audioRef = storageRef.child("audio/recording.wav")
            _ = audioRef.putData(data,metadata: nil) {
                (metadata, error) in
                guard metadata != nil else {
                    print("Cloud storage upload ERROR")
                    print(error ?? "error")
                    return
                }
            }
            do {
                sleep(3)
                self.ref.child("audio").child("USER123").observeSingleEvent(of: .value, with: { (snapshot) in
                    // Get user value
//                    let value = snapshot.value as? NSDictionary
                }) { (error) in
                    print(error.localizedDescription)
                    print("Cloud function upload ERROR")
                }
            }
        }
        print("Uploaded audio file to cloud storage")
    }
    
    
    func uploadTestToFirebase() {
        print("Uploading test data")
//        let a = AudioProcess()
//        let wavData = a.pmcWaveConverter(rawData: getTestData()) as Data
        let wavData = getTestData2()
        uploadToFirebase(data: wavData.base64EncodedString())
        sleep(2)
        uploadFileToFirebase(data: wavData)
    }
    
    
    func getTestData() -> [UInt8]{
        do {
            let textFile = Bundle.main.url(forResource: "TESTVALUES", withExtension: "txt")
            let textFileString = try String(contentsOf: textFile!).replacingOccurrences(of: "\r\n", with: ",")
            
            // split the array by the ","
            var stringArray = textFileString.components(separatedBy: ",")
            stringArray.removeLast()
            
            // convert the array into uint array
            return stringArray.map{ UInt8($0)!}

        } catch {
            print("error reading array")
            return [1]
        }
    }
    
    func getTestData2() -> Data{
        do {
            let file = Bundle.main.url(forResource: "1234_uint8", withExtension: "wav")
            let d = try Data(contentsOf: file!)
            return d
        } catch {
            print("error reading array")
            return Data(bytes: [1])
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
