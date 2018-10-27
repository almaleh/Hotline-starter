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

private let sharedProviderDelegate = ProviderDelegate()

class ProviderDelegate: NSObject {

    
    class var sharedInstance : ProviderDelegate {
        return sharedProviderDelegate
    }
    fileprivate let provider: CXProvider?
    fileprivate let callController: CXCallController
    
    var client: SINClient {
        return CallManager.sharedInstance.client
    }
    var acDelegate: AudioControllerDelegate
    
    override init() {
        provider = CXProvider(configuration: type(of: self).providerConfiguration)
        
        // SINCH STUFF
        self.acDelegate = AudioControllerDelegate()
        CallManager.sharedInstance.client.audioController().delegate = acDelegate
       
        callController = CXCallController.init()
        super.init()
        
        provider?.setDelegate(self, queue: nil)
//        provider.setDelegate(self, queue: nil)
        
    }
    
    static var providerConfiguration: CXProviderConfiguration {
        let providerConfiguration = CXProviderConfiguration(localizedName: "Hotline")
        providerConfiguration.supportsVideo = false
        providerConfiguration.maximumCallGroups = 2
        if #available(iOS 11.0, *) {
            providerConfiguration.includesCallsInRecents = true
        }
        providerConfiguration.supportedHandleTypes = [.phoneNumber, .generic]
        return providerConfiguration
    }

    func reportIncomingCall(_ call: SINCall) {
        guard let handle = call.remoteUserId, let uuid = UUID(uuidString: call.callId) else { return }
        
        let update = CXCallUpdate()
        
        
        update.remoteHandle = CXHandle(type: .generic, value: handle)
        
        provider?.reportNewIncomingCall(with: uuid, update: update) { error in
            if error == nil {
                call.delegate = self
                CallManager.sharedInstance.addIncoming(call: call)
            }
        }
    }

}

extension ProviderDelegate: CXProviderDelegate {
    
    func providerDidReset(_ provider: CXProvider) {
        client.audioController().mute()
        
        for call in CallManager.sharedInstance.calls {
            call.hangup()
        }
        
        CallManager.sharedInstance.removeAllCalls()
    }
    
    func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
        guard let call = CallManager.sharedInstance.callWithUUID(uuid: action.callUUID) else {
            action.fail()
            return
        }
        
        call.answer()
        
        action.fulfill()
        CallManager.sharedInstance.reloadTable?()
        
    }
    
    func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
        guard let call = CallManager.sharedInstance.callWithUUID(uuid: action.callUUID) else {
            action.fail()
            return
        }
        
        call.hangup()
        action.fulfill()
        
        CallManager.sharedInstance.remove(call: call)
    }
    
    func provider(_ provider: CXProvider, execute transaction: CXTransaction) -> Bool {
        // worth investigating further to add custom functionality
        CallManager.sharedInstance.reloadTable?()
        for action in transaction.actions {
            print(action)
        }
        return false
    }
    
    func provider(_ provider: CXProvider, didActivate audioSession: AVAudioSession) {
        client.call().provider(provider, didActivate: audioSession)
        client.audioController().unmute()
        CallManager.sharedInstance.reloadTable?()
    }
    
    func provider(_ provider: CXProvider, didDeactivate audioSession: AVAudioSession) {
        client.audioController().mute()
        
        CallManager.sharedInstance.reloadTable?()
    }
    
    func provider(_ provider: CXProvider, perform action: CXSetHeldCallAction) {
        print("Are we holding???: \(action.isOnHold)")
//        if action.isOnHold {
//            client.audioController().mute()
//        } else {
//            client.audioController().unmute()
//        }

        action.fulfill()
        CallManager.sharedInstance.reloadTable?()
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
        if CallManager.sharedInstance.currentCallStatus != .ended {
            CallManager.sharedInstance.currentCall?.delegate = self
            action.fulfill()
            CallManager.sharedInstance.addCall()
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
        provider?.reportOutgoingCall(with: uuid, startedConnectingAt: nil)
    }
    
    func reportOutoingConnected(uuid: UUID) {
        provider?.reportOutgoingCall(with: uuid, connectedAt: nil)
    }
    
}

extension ProviderDelegate: SINCallDelegate {
    
    
    func callDidProgress(_ call: SINCall!) {
        CallManager.sharedInstance.reloadTable?()
        reportOutgoingStarted(uuid: call.uuid)
        print("RINGING")
    }
    
    func callDidEstablish(_ call: SINCall!) {
        CallManager.sharedInstance.reloadTable?()
        reportOutoingConnected(uuid: call.uuid)
        print("STARTING CALL")
    }
    
    func callDidEnd(_ call: SINCall!) {
        end(call: call)
        
        CallManager.sharedInstance.reloadTable?()
        print("CALL ENDED")
    }
    
    func call(_ call: SINCall!, shouldSendPushNotifications pushPairs: [Any]!) {
        //        TODO
    }
    
}

extension ProviderDelegate {
    
    
    func end(call: SINCall) {
        let endCallAction = CXEndCallAction(call: call.uuid)
        let transaction = CXTransaction(action: endCallAction)
        requestTransaction(transaction)
    }
    
    private func requestTransaction(_ transaction: CXTransaction) {
        
        callController.request(transaction, completion: { (error : Error?) in
            
            if error != nil {
                print("\(String(describing: error?.localizedDescription))")
                //                self.end(call: self.currentCall!)
            }
        })
        
        
        
        //        callController.request(transaction) { error in
        //            if let error = error {
        //                print("Error requesting transaction: \(error.localizedDescription)")
        //            } else {
        //                print("Requested transaction successfully:") // \(transaction.actions.first?.description ?? "")")
        //            }
        //        }
    }
    
    func setHeld(call: SINCall, onHold: Bool) {
        let setHeldCallAction = CXSetHeldCallAction(call: call.uuid, onHold: onHold)
        let transaction = CXTransaction()
        transaction.addAction(setHeldCallAction)
        
        requestTransaction(transaction)
    }
    
    func setMute(call: SINCall, mute: Bool) {
        let setMuteCallAction = CXSetMutedCallAction(call: call.uuid, muted: mute)
        let transaction = CXTransaction()
        transaction.addAction(setMuteCallAction)
        
        requestTransaction(transaction)
    }
    
    func setSpeaker(call: SINCall, loud: Bool) {
        
    }
    
    func startCall(handle: String) {
        
        CallManager.sharedInstance.currentCall = client.call().callUser(withId: handle)
        guard let uuid = UUID(uuidString: CallManager.sharedInstance.currentCall?.callId ?? "" ) else {
            return
        }
        
        let handle = CXHandle(type: CXHandle.HandleType.generic, value: handle)
        let startCallAction = CXStartCallAction.init(call: uuid, handle: handle)
        let transaction = CXTransaction.init()
        transaction.addAction(startCallAction)
        requestTransaction(transaction)
    }
}
