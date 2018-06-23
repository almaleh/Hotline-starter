//
//  ProviderDelegate.swift
//  Hotline
//
//  Created by Besher on 2018-05-28.
//  Copyright © 2018 Razeware LLC. All rights reserved.
//

import Foundation
import AVFoundation
import CallKit

class ProviderDelegate: NSObject {

    
    fileprivate let callManager: CallManager
    fileprivate let provider: CXProvider
    var client: SINClient
    var acDelegate: AudioControllerDelegate
    
    init(callManager: CallManager) {
        self.callManager = callManager
        provider = CXProvider(configuration: type(of: self).providerConfiguration)
        
        // SINCH STUFF
        self.acDelegate = AudioControllerDelegate()
        self.client = callManager.client
        client.audioController().delegate = acDelegate
        
        super.init()
       
        provider.setDelegate(self, queue: nil)
    }
    
    static var providerConfiguration: CXProviderConfiguration {
        let providerConfiguration = CXProviderConfiguration(localizedName: "Hotline")
        providerConfiguration.supportsVideo = false
        providerConfiguration.maximumCallGroups = 2
        providerConfiguration.supportedHandleTypes = [.phoneNumber, .generic]
        return providerConfiguration
    }

    func reportIncomingCall(_ call: SINCall) {
        guard let handle = call.remoteUserId, let uuid = UUID(uuidString: call.callId) else { return }
        
        let update = CXCallUpdate()
        
        
        update.remoteHandle = CXHandle(type: .generic, value: handle)
        
        provider.reportNewIncomingCall(with: uuid, update: update) { error in
            if error == nil {
                self.callManager.addIncoming(call: call)
            }
        }
    }

}

extension ProviderDelegate: CXProviderDelegate {
    
    func providerDidReset(_ provider: CXProvider) {
        client.audioController().mute()
        
        for call in callManager.calls {
            call.hangup()
        }
        
        callManager.removeAllCalls()
    }
    
    func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
        guard let call = callManager.callWithUUID(uuid: action.callUUID) else {
            action.fail()
            return
        }
        
        call.answer()
        
        action.fulfill()
        self.callManager.reloadTable?()
        
    }
    
    func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
        guard let call = callManager.callWithUUID(uuid: action.callUUID) else {
            action.fail()
            return
        }
        
        call.hangup()
        action.fulfill()
        
        callManager.remove(call: call)
    }
    
    func provider(_ provider: CXProvider, execute transaction: CXTransaction) -> Bool {
        // worth investigating further to add custom functionality
        callManager.reloadTable?()
        return false
    }
    
    func provider(_ provider: CXProvider, didActivate audioSession: AVAudioSession) {
        client.call().provider(provider, didActivate: audioSession)
        client.audioController().unmute()
        callManager.reloadTable?()
    }
    
    func provider(_ provider: CXProvider, didDeactivate audioSession: AVAudioSession) {
        client.audioController().mute()
        callManager.reloadTable?()
    }
    
    func provider(_ provider: CXProvider, perform action: CXSetHeldCallAction) {
        print("Are we holding???: \(action.isOnHold)")
        if action.isOnHold {
            client.audioController().mute()
        } else {
            client.audioController().unmute()
        }

        action.fulfill()
        callManager.reloadTable?()
    }
    
    func provider(_ provider: CXProvider, perform action: CXSetMutedCallAction) {
        if acDelegate.muted {
            client.audioController().unmute()
        } else {
            client.audioController().mute()
        }
        action.fulfill()
    }
    
    
    
    func provider(_ provider: CXProvider, perform action: CXStartCallAction) {
        
        print(action.callUUID)
        if callManager.currentCallStatus != .ended {
            action.fulfill()
            callManager.addCall()
        }

        
//        call.connectedStateChanged = { [unowned self, unowned call] in
//            if call.connectedState == .pending {
//                self.provider.reportOutgoingCall(with: call.uuid, startedConnectingAt: nil)
//            } else if call.connectedState == .complete {
//                self.provider.reportOutgoingCall(with: call.uuid, connectedAt: nil)
//            }
//        }
        
    
        
//        call.start { [unowned self, unowned call] success in
//            if success {
//                action.fulfill()
//                self.callManager.add(call: call)
//            } else {
//                action.fail()
//            }
//        }
    }
    
    func reportOutgoingStarted(uuid: UUID) {
        self.provider.reportOutgoingCall(with: uuid, startedConnectingAt: nil)
    }
    
    func reportOutoingConnected(uuid: UUID) {
        self.provider.reportOutgoingCall(with: uuid, connectedAt: nil)
    }
    
}
