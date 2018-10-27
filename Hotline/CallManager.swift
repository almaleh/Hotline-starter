/**
 * Copyright (c) 2017 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import Foundation
import CallKit

private let sharedManager = CallManager.init()

class CallManager: NSObject {
    
    var reloadTable: (() -> Void)?
    var updateDelegates: (() -> Void)?
    var client: SINClient
    var audioController: SINAudioController {
        return client.audioController()
    }
    
    
    class var sharedInstance : CallManager {
        return sharedManager
    }

    private(set) var calls = [SINCall]()
    
    var currentCall: SINCall? {
        didSet {
                self.updateDelegates?()
        }
    }
    
    var currentCallStatus: SINCallState {
        return currentCall?.state ?? SINCallState.ended
    }
    
    override init() {
        
        
            client = Sinch.client(withApplicationKey: APPLICATION_KEY, applicationSecret: APPLICATION_SECRET, environmentHost: "sandbox.sinch.com", userId: AppDelegate.shared.user)
            client.setSupportCalling(true)
            client.setSupportMessaging(false)
            client.enableManagedPushNotifications()
            client.delegate = AppDelegate.shared // to be reviewed
            client.call().delegate = AppDelegate.shared // to be discussed
            client.start()
            client.startListeningOnActiveConnection()
        
        super.init()
        
    }
    
    func callWithHandle(_ handle: String) -> SINCall? {
        guard let index = calls.index(where: { $0.remoteUserId == handle }) else {
            return nil
        }
        return calls[index]
    }
    
    func callWithUUID(uuid: UUID) -> SINCall? {
        guard let index = calls.index(where: { UUID(uuidString: $0.callId)! == uuid }) else {
            return nil
        }
        return calls[index]
    }
    
    func addCall() {
        if let call = currentCall {
            calls.append(call)
            currentCall = nil
            reloadTable?()
        }
    }
    
    func addIncoming(call: SINCall) {
        calls.append(call)
        reloadTable?()
    }
    
    func remove(call: SINCall) {
        guard let index = calls.index(where: { $0 === call }) else { return }
        calls.remove(at: index)
        reloadTable?()
    }
    
    func removeAllCalls() {
        calls.removeAll()
        reloadTable?()
    }
}
