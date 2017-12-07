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
        if(count < 2000){
            print("COUNT: \(count), DATA: \(data)")
            for d in data{
                audioData.append(d)
            }
            
            //heres where things get interesting, basically depending on the data send information to view controller...
            //Add this data to the AudioProcessClass?
        }
      
        if (count == 1999){
            //When we are done with all the data... we can now turn data to a file... and process it
            let data = self.pmcWaveConverter(rawData: self.audioData)
            self.sendProcessedAudioData(data:data)
        }
    }
    
    func resetAudio(){
        self.count = 0
        self.audioData = [UInt8]()
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
        
        //DATA size and start
        header.append([UInt8]("data".utf8), length: 4)
        header.append(intToByteArray(Int32(Data(rawData).count*2)), length: 4)
        
        //OLD uint8 attempt
        //header.append(Data(rawData))
        
        // Uint16 attempt
        var uint16Array:[UInt16] = rawData.map{UInt16($0)}
        uint16Array = uint16Array.map{($0)*(2^16 - 1)}
        let d = Data(fromArray: uint16Array)
        header.append(d)
        
        //Finally write these to the memory somehow...
        let bytes = header as Data
        return bytes
    }
    
    func sendProcessedAudioData(data:Data){
        print("We have all of our audio data")
        let dataDict:[String: Data] = ["data": data]
        NotificationCenter.default.post(name: Notification.Name(rawValue: AUDIO_DONE_NOTIFICATION_KEY), object: self, userInfo:dataDict)
    }
    
    
}

extension Data {
    
    init<T>(fromArray values: [T]) {
        var values = values
        self.init(buffer: UnsafeBufferPointer(start: &values, count: values.count))
    }
    
    func toArray<T>(type: T.Type) -> [T] {
        return self.withUnsafeBytes {
            [T](UnsafeBufferPointer(start: $0, count: self.count/MemoryLayout<T>.stride))
        }
    }
}
