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

class CallManager: NSObject {
    
    var reloadTable: (() -> Void)?
    var updateData: (() -> Void)?
    var client: SINClient
    var audioController: SINAudioController {
        return client.audioController()
    }

    private(set) var calls = [SINCall]()
    
    private let callController = CXCallController()
    
    var currentCall: SINCall? {
        didSet {
            if currentCall != nil {
                self.updateData?()
            }
        }
    }
    
    var currentCallStatus: SINCallState {
        return currentCall?.state ?? SINCallState.ended
    }
    
    init(client: SINClient) {
        self.client = client
        super.init()
        
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
    
    func end(call: SINCall) {
        let endCallAction = CXEndCallAction(call: call.uuid)
        let transaction = CXTransaction(action: endCallAction)
        requestTransaction(transaction)
    }
    
    private func requestTransaction(_ transaction: CXTransaction) {
        callController.request(transaction) { error in
            if let error = error {
                print("Error requesting transaction: \(error.localizedDescription)")
            } else {
                print("Requested transaction successfully:") // \(transaction.actions.first?.description ?? "")")
            }
        }
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
    
    func startCall(handle: String) {
        
        currentCall = client.call().callUser(withId: handle)
        guard let uuid = UUID(uuidString: currentCall?.callId ?? "" ) else {
            return
        }
        
        let handle = CXHandle(type: .phoneNumber, value: handle)
        let startCallAction = CXStartCallAction(call: uuid, handle: handle)
        
        let transaction = CXTransaction(action: startCallAction)
        
        requestTransaction(transaction)
    }
}
