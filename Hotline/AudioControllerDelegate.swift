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
    
    func audioControllerMuted(_ audioController: SINAudioController!) {
        self.muted = true
    }
    
    func audioControllerUnmuted(_ audioController: SINAudioController!) {
        self.muted = false
    }
    
}
