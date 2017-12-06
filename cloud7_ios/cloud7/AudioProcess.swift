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
    var audioData = [UInt8]()
    var count = 0
    
    //This gets called from BLEHandler when a new set of data comes into the system
    func newAudioData(data: [UInt8]) {
        count += 1
        print("COUNT: \(count), DATA: \(data)")
        for d in data{
           audioData.append(d)
        }
        
        //heres where things get interesting, basically depending on the data send information to view controller...
        //Add this data to the AudioProcessClass?
        if (count > 1999){
            //When we are done with all the data... we can now turn data to a file... and process it
            let dataString = self.transformDataToAudioFile()
            self.sendProcessedAudioData(data:dataString)
            count = 0
        }
    }
    
    func resetAudio(){
        self.count = 0
        self.audioData = [UInt8]()
    }
    
    func transformDataToAudioFile() -> String{
        let header = "RIFFeWAVEfmt00b0data"
        let buf = [UInt8](header.utf8)
        let array = buf + audioData
        let buff = Data(bytes: array)
        return buff.base64EncodedString()
    }
    
    func shortToByteArray(_ i: Int16) -> [UInt8] {
        //The following code, provided courtesy of Amro Guzlan, TA, McGill 2017
        return [
            //little endian
            UInt8(truncatingIfNeeded: (i      ) & 0xff),
            UInt8(truncatingIfNeeded: (i >>  8) & 0xff)
        ]
    }
    
    func intToByteArray(_ i: Int32) -> [UInt8] {
        //The following code, provided courtesy of Amro Guzlan, TA, McGill 2017
        return [
            //little endian
            
            UInt8(truncatingIfNeeded: (i      ) & 0xff),
            UInt8(truncatingIfNeeded: (i >>  8) & 0xff),
            UInt8(truncatingIfNeeded: (i >> 16) & 0xff),
            UInt8(truncatingIfNeeded: (i >> 24) & 0xff)
        ]
    }
    
    func pmcWaveConverter(rawData: [UInt8]) ->Data{
        //The following code, provided courtesy of Amro Guzlan, TA, McGill 2017
        let sampleRate:Int32 = 8000
        let chunkSize:Int32 = 36
        let subChunkSize:Int32 = 16
        let format:Int16 = 1
        let channels:Int16 = 1
        let bitsPerSample:Int16 = 16
        let byteRate:Int32 = sampleRate * Int32(channels * bitsPerSample / 8)
        let blockAlign: Int16 = channels * 2
        
        let header = NSMutableData()
        
        header.append([UInt8]("RIFF".utf8), length: 4)
        header.append(intToByteArray(chunkSize), length: 4)
        
        //WAVE
        header.append([UInt8]("WAVE".utf8), length: 4)
        
        //FMT
        header.append([UInt8]("fmt ".utf8), length: 4)
        
        header.append(intToByteArray(subChunkSize), length: 4)
        header.append(shortToByteArray(format), length: 2)
        header.append(shortToByteArray(channels), length: 2)
        header.append(intToByteArray(sampleRate), length: 4)
        header.append(intToByteArray(byteRate), length: 4)
        header.append(shortToByteArray(blockAlign), length: 2)
        header.append(shortToByteArray(bitsPerSample), length: 2)
        
        //DATA
        header.append([UInt8]("data".utf8), length: 4)
        
        header.append(intToByteArray(Int32(Data(rawData).count)), length: 4)
        
        header.append(Data(rawData))
        
        
        //Finally write these to the memory somehow...
        let bytes = header as Data
        return bytes
    }
    
    func sendProcessedAudioData(data:String){
        print("We have all of our audio data")
        let dataDict:[String: String] = ["data": data]
        NotificationCenter.default.post(name: Notification.Name(rawValue: AUDIO_DONE_NOTIFICATION_KEY), object: self, userInfo:dataDict)
    }
    
    
}
