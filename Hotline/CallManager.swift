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

class CallManager {
    
    var callsChangedHandler: (() -> Void)?
    var client: SINClient

    private(set) var calls = [SINCall]()
    
    private let callController = CXCallController()
    
    init(client: SINClient) {
        self.client = client
    }
    
    func callWithUUID(uuid: UUID) -> SINCall? {
        guard let index = calls.index(where: { UUID(uuidString: $0.callId)! == uuid }) else {
            return nil
        }
        return calls[index]
    }
    
    func add(call: SINCall) {
        calls.append(call)
//        call.stateChanged = { [unowned self] in
//            self.callsChangedHandler?()
//        }
        callsChangedHandler?()
    }
    
    func remove(call: SINCall) {
        guard let index = calls.index(where: { $0 === call }) else { return }
        calls.remove(at: index)
        callsChangedHandler?()
    }
    
    func removeAllCalls() {
        calls.removeAll()
        callsChangedHandler?()
    }
    
    func end(call: SINCall) {
        guard let uuid = UUID(uuidString: call.callId) else { return }
        
        let endCallAction = CXEndCallAction(call: uuid)
        
        let transaction = CXTransaction(action: endCallAction)
        
        requestTransaction(transaction)
    }
    
    private func requestTransaction(_ transaction: CXTransaction) {
        callController.request(transaction) { error in
            if let error = error {
                print("Error requesting transaction: \(error.localizedDescription)")
            } else {
                print("Requested transaction successfully")
            }
        }
    }
    
    func setHeld(call: SINCall, onHold: Bool) {
        let setHeldCallAction = CXSetHeldCallAction(call: call.uuid, onHold: onHold)
        let transaction = CXTransaction()
        transaction.addAction(setHeldCallAction)
        
        requestTransaction(transaction)
    }
    
    func startCall(handle: String, videoEnabled: Bool) {
        // TODO : add Sinch
        
        client.call().callUser(withId: handle)
        let handle = CXHandle(type: .phoneNumber, value: handle)
        let startCallAction = CXStartCallAction(call: UUID(), handle: handle)
        
        startCallAction.isVideo = videoEnabled
        let transaction = CXTransaction(action: startCallAction)
        
        requestTransaction(transaction)
    }
}