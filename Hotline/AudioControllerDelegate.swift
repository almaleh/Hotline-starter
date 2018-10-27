//
//  AudioControllerDelegate.swift
//  Hotline
//
//  Created by Besher on 2018-06-03.
//  Copyright © 2018 Razeware LLC. All rights reserved.
//

import Foundation

class AudioControllerDelegate: NSObject, SINAudioControllerDelegate {
    
    var muted: Bool = true
    var speakerEnabled: Bool = false
    
    func audioControllerMuted(_ audioController: SINAudioController!) {
        self.muted = true
        print("Stopping audio")
    }
    
    func audioControllerUnmuted(_ audioController: SINAudioController!) {
        self.muted = false
        print("Starting audio")
    }
    
    func audioControllerSpeakerEnabled(_ audioController: SINAudioController!) {
        self.speakerEnabled = true
//        audioController.enableSpeaker()
        print("Speaker enabled!")
    }
    
    func audioControllerSpeakerDisabled(_ audioController: SINAudioController!) {
        self.speakerEnabled = false
//        audioController.disableSpeaker()
        print("Speaker disabled!")
    }
    
}
