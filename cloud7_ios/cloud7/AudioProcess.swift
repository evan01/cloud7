//
//  AudioProcess.swift
//  cloud7
//
//  Created by Evan Knox on 2017-12-04.
//  Copyright © 2017 Evan Knox. All rights reserved.
//

import UIKit
import AVKit

let AUDIO_DONE_NOTIFICATION_KEY = "AUDIO_COMPLETE"

class AudioProcess: NSObject, BLEHandler_NewAudioDelegate {
    var data = [Data]()
    
    //This gets called from BLEHandler when a new set of data comes into the system
    func newAudioData(data: [UInt32]) {
        print("New Data: \(data)")
        //heres where things get interesting, basically depending on the data send information to view controller...
        //Add this data to the AudioProcessClass?
        if (data[0] == 400){
            //When we are done with all the data... we can now turn data to a file... and process it
            self.transformDataToAudioFile()
            self.sendProcessedAudioData()
        }
    }
    
    func transformDataToAudioFile(){
//        let url = "audioFile.wav"
//        let SAMPLE_RATE =  Float64(16000.0)
//
//        let outputFormatSettings = [
//            AVFormatIDKey:kAudioFormatLinearPCM,
//            AVLinearPCMBitDepthKey:32,
//            AVLinearPCMIsFloatKey: true,
//            //  AVLinearPCMIsBigEndianKey: false,
//            AVSampleRateKey: SAMPLE_RATE,
//            AVNumberOfChannelsKey: 1
//            ] as [String : Any]
//
//        let audioFile = try? AVAudioFile(forWriting: url, settings: outputFormatSettings, commonFormat: AVAudioCommonFormat.pcmFormatFloat32, interleaved: true)
//
//        let bufferFormat = AVAudioFormat(settings: outputFormatSettings)
//
//        let outputBuffer = AVAudioPCMBuffer(pcmFormat: bufferFormat, frameCapacity: AVAudioFrameCount(buff.count))
//
//        // i had my samples in doubles, so convert then write
//
//        for i in 0..<buff.count {
//            outputBuffer.floatChannelData!.pointee[i] = Float( buff[i] )
//        }
//        outputBuffer.frameLength = AVAudioFrameCount( buff.count )
//
//        do{
//            try audioFile?.write(from: outputBuffer)
//
//        } catch let error as NSError {
//            print("error:", error.localizedDescription)
//        }
    }
    
    
    
    func sendProcessedAudioData(){
        print("We have all of our audio data")
        NotificationCenter.default.post(name: Notification.Name(rawValue: AUDIO_DONE_NOTIFICATION_KEY), object: self)
    }
    
    
}
