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

enum CallState {
    case connecting
    case active
    case held
    case ended
}

enum ConnectedState {
    case pending
    case complete
}

extension SINCall {
    
    var uuid: UUID {
        return UUID(uuidString: self.callId)!
    }
    var outgoing: Bool {
        return self.direction == .outgoing
    }
    var handle: String {
        return self.remoteUserId!
    }
}

extension Notification.Name {
    static let SINCallStatusChange = Notification.Name("SINCallStatusChangeNotification")
}


//class Call {
//    
//    let uuid: UUID
//    let outgoing: Bool
//    let handle: String
//    
//    var state: CallState = .ended {
//        didSet {
//            stateChanged?()
//        }
//    }
//    
//    var connectedState: ConnectedState = .pending {
//        didSet {
//            connectedStateChanged?()
//        }
//    }
//    
//    var stateChanged: (() -> Void)?
//    var connectedStateChanged: (() -> Void)?
//    
//    init(uuid: UUID, outgoing: Bool = false, handle: String) {
//        self.uuid = uuid
//        self.outgoing = outgoing
//        self.handle = handle
//    }
//    
//    func start(completion: ((_ success: Bool) -> Void)?) {
//        completion?(true)
//        
//        DispatchQueue.main.asyncAfter(wallDeadline: DispatchWallTime.now() + 3) {
//            self.state = .connecting
//            self.connectedState = .pending
//            
//            DispatchQueue.main.asyncAfter(wallDeadline: DispatchWallTime.now() + 1.5) {
//                self.state = .active
//                self.connectedState = .complete
//            }
//        }
//    }
//    
//    func answer() {
//        state = .active
//    }
//    
//    func end() {
//        state = .ended
//    }
//    
//}
