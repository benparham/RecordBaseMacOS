//
//  Playback.swift
//  RecordBaseMacOS
//
//  Created by Ruben Parham on 11/12/14.
//  Copyright (c) 2014 Ruben Parham. All rights reserved.
//

import Foundation
import AVFoundation

func playSong(song: MDSSong) -> AVAudioPlayer {
//    let basePath: String = NSUserDefaults.standardUserDefaults().URLForKey(prefsKeyStorageUrl)!.absoluteString!
//    let songFilePath = basePath + "/" + musicDirectory + "/" + song.filePath
    
    let basePath: NSURL = NSUserDefaults.standardUserDefaults().URLForKey(prefsKeyStorageUrl)!
    let songFilePath = basePath.URLByAppendingPathComponent(musicDirectory + "/" + song.filePath)
    
    println("Should play song at \(songFilePath.absoluteString!)")
    
    var error: NSError?
    var audioPlayer = AVAudioPlayer(contentsOfURL: songFilePath, error: &error)
    audioPlayer.prepareToPlay()
    audioPlayer.play()
    
    println("Should be playing now")
    return audioPlayer
}