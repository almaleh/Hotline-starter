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

import UIKit

private let presentIncomingCallViewControllerSegue = "PresentIncomingCallViewController"
private let presentOutgoingCallViewControllerSegue = "PresentOutgoingCallViewController"
private let callCellIdentifier = "CallCell"

class CallsViewController: UITableViewController {
    
    var callManager: CallManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        callManager = AppDelegate.shared.callManager
        
        callManager.callsChangedHandler = {
            [unowned self] in
            self.tableView.reloadData()
        }
    }
    
    @IBAction private func unwindForNewCall(_ segue: UIStoryboardSegue) {       
        guard let newCallController = segue.source as? NewCallViewController else { return }
        guard let handle = newCallController.handle else { return }
        let incoming = newCallController.incoming
        let videoEnabled = newCallController.videoEnabled

        if incoming {
//            DispatchQueue.main.asyncAfter(wallDeadline: DispatchWallTime.now() + 1.5) {
//                AppDelegate.shared.displayIncomingCall(uuid: UUID(), handle: handle)
//            }
        } else {
            callManager.startCall(handle: handle, videoEnabled: videoEnabled)
        }
    }
}

// MARK: - UITableViewDataSource

extension CallsViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return callManager.calls.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let call = callManager.calls[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: callCellIdentifier) as! CallTableViewCell
        cell.callerHandle = call.remoteUserId
        cell.callState = call.state
        cell.incoming = (call.direction == .incoming)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        let call = callManager.calls[indexPath.row]
        callManager.end(call: call)
    }
}

// MARK - UITableViewDelegate

extension CallsViewController {
    override func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "End"
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let call = callManager.calls[indexPath.row]
        // TODO: clarify hold situation with SINkit
        call.hangup()
//        call.state = call.state == .held ? .active : .held
        callManager?.setHeld(call: call, onHold: call.state == .progressing)
        
        tableView.reloadData()
    }
}

extension CallsViewController: SINCallDelegate, SINCallClientDelegate {
    
    
    
}
